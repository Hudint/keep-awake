import AppKit
import IOKit.pwr_mgt

/// Keeps the display awake for as long as the assertion is held.
final class SleepBlocker {
    private var assertionID: IOPMAssertionID = 0

    var isActive: Bool { assertionID != 0 }

    @discardableResult
    func enable() -> Bool {
        guard !isActive else { return true }
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "KeepAwake: keeping the display on" as CFString,
            &id
        )
        guard result == kIOReturnSuccess else { return false }
        assertionID = id
        return true
    }

    func disable() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let blocker = SleepBlocker()
    private let toggleItem = NSMenuItem(
        title: "Keep Display Awake",
        action: #selector(toggle),
        keyEquivalent: ""
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        updateUI()
    }

    func applicationWillTerminate(_ notification: Notification) {
        blocker.disable()
    }

    @objc private func toggle() {
        if blocker.isActive {
            blocker.disable()
        } else if !blocker.enable() {
            let alert = NSAlert()
            alert.messageText = "Could not prevent sleep"
            alert.informativeText = "The system rejected the power assertion."
            alert.runModal()
        }
        updateUI()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func updateUI() {
        let on = blocker.isActive
        let symbol = on ? "cup.and.saucer.fill" : "cup.and.saucer"
        let label = on ? "Awake – display stays on" : "Off – display may sleep"

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)

            // Filled vs. outlined is hard to spot at menu bar size, so the active state is
            // colored too. The menu bar draws template images in its own color and ignores
            // contentTintColor, so the color has to be baked into the symbol itself — and it
            // is a fixed color, not the accent color, which is invisible on a black accent.
            if on {
                let colored = image?.withSymbolConfiguration(
                    NSImage.SymbolConfiguration(paletteColors: [.systemOrange])
                )
                colored?.isTemplate = false
                button.image = colored
            } else {
                image?.isTemplate = true
                button.image = image
            }

            button.toolTip = "KeepAwake – \(label)"
        }
        toggleItem.state = on ? .on : .off
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
