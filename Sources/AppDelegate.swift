import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let captureCoordinator = CaptureCoordinator()
    private let config = AppConfig.shared
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()

        hotkeyManager = HotkeyManager { [weak self] in
            self?.captureCoordinator.beginCapture()
        }
        hotkeyManager?.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregister()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "scissors", accessibilityDescription: "Scap")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: "6"))
        menu.items.last?.keyEquivalentModifierMask = [.command, .shift]

        let keepOnTopItem = NSMenuItem(title: "Preview Always On Top", action: #selector(toggleKeepOnTop), keyEquivalent: "")
        keepOnTopItem.state = config.keepPreviewOnTop ? .on : .off
        menu.addItem(keepOnTopItem)

        menu.addItem(NSMenuItem(title: "Open Save Folder", action: #selector(openSaveFolder), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Scap", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func capture() {
        captureCoordinator.beginCapture()
    }

    @objc private func toggleKeepOnTop(_ sender: NSMenuItem) {
        config.keepPreviewOnTop.toggle()
        sender.state = config.keepPreviewOnTop ? .on : .off
        captureCoordinator.updatePreviewWindowLevel()
    }

    @objc private func openSaveFolder() {
        NSWorkspace.shared.open(config.saveDirectory)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
