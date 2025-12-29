# Scap

Scap is a lightweight macOS menu bar screen capture app.

## Features
- Global hotkey to start a resizable capture region.
- Toggle preview window level: always on top or normal.
- Save captured images to disk (PNG).

## Build (no Xcode project)
Requires Xcode installed for the macOS SDK and `swiftc`.

```bash
./scripts/build.sh
open build/Scap.app
```

Or with make:

```bash
make build
make run
```

## Package (.dmg)
Creates a drag-and-drop DMG with the app and an Applications shortcut:

```bash
./scripts/package.sh
```

Or with make:

```bash
make package
```

## Notes
- macOS will request Screen Recording permission the first time you capture.
- If capture shows no result, open System Settings → Privacy & Security → Screen Recording and enable Scap.

## Default Shortcuts
- Capture: Command + Shift + 7
- You can change the hotkey in Preferences.

## License
MIT
