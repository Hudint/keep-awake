# KeepAwake

A tiny macOS menu bar app that keeps your display from going to sleep.

Click the cup icon in the menu bar and toggle **Keep Display Awake**. While it's on, macOS
won't dim or sleep the screen due to inactivity. Toggle it off — or quit the app — and normal
power management resumes immediately.

- No dock icon, no window, no preferences.
- Single Swift file, no dependencies.
- Uses the standard IOKit power assertion (`kIOPMAssertionTypeNoDisplaySleep`), the same
  mechanism `caffeinate` uses.

## Build

Requires Xcode command line tools (Swift 5.9+) and macOS 13 or later.

```bash
./build.sh
```

This produces `build/KeepAwake.app`. To install it:

```bash
cp -R build/KeepAwake.app /Applications/
```

## Start at login

System Settings → General → Login Items → add `KeepAwake`.

## Verify it's working

While the toggle is on, the assertion shows up in:

```bash
pmset -g assertions
```

## License

MIT
