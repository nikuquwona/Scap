import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let captureCoordinator = CaptureCoordinator()
    private let config = AppConfig.shared
    private var hotkeyManager: HotkeyManager?
    private var keepOnTopItem: NSMenuItem?
    private var preferencesController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("Scap launched")
        let showDock = UserDefaults.standard.bool(forKey: "ScapShowDock")
        NSApp.setActivationPolicy(showDock ? .regular : .accessory)
        if UserDefaults.standard.bool(forKey: "ScapDebugAlert") {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Scap launched"
                alert.informativeText = "Debug alert is enabled."
                alert.runModal()
            }
        }
        setupStatusItem()

        hotkeyManager = HotkeyManager { [weak self] in
            self?.captureCoordinator.beginCapture()
        }
        hotkeyManager?.register()

        NotificationCenter.default.addObserver(self, selector: #selector(hotkeyChanged), name: .hotkeyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keepOnTopChanged), name: .keepOnTopChanged, object: nil)
        
        setupMainMenu()
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu
        
        // App Menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About Scap", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Scap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        // File Menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        
        // Edit Menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        
        // Window Menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        
        // Help Menu
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        helpMenu.addItem(withTitle: "Scap Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?")
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregister()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Scap"
        if let image = NSImage(named: "StatusIcon") {
            image.isTemplate = true
            statusItem.button?.image = image
            statusItem.button?.imagePosition = .imageLeading
        } else if let fallback = NSImage(systemSymbolName: "scissors", accessibilityDescription: "Scap") {
            statusItem.button?.image = fallback
            statusItem.button?.imagePosition = .imageLeading
        }

        let menu = NSMenu()
        let captureItem = NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: "6")
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        let keepOnTopItem = NSMenuItem(title: "Preview Always On Top", action: #selector(toggleKeepOnTop), keyEquivalent: "")
        keepOnTopItem.target = self
        keepOnTopItem.state = config.keepPreviewOnTop ? .on : .off
        menu.addItem(keepOnTopItem)
        self.keepOnTopItem = keepOnTopItem

        let preferencesItem = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        let openFolderItem = NSMenuItem(title: "Open Save Folder", action: #selector(openSaveFolder), keyEquivalent: "")
        openFolderItem.target = self
        menu.addItem(openFolderItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit Scap", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

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

    @objc private func openPreferences() {
        if preferencesController == nil {
            preferencesController = PreferencesWindowController()
        }
        preferencesController?.show()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func hotkeyChanged() {
        hotkeyManager?.register()
    }

    @objc private func keepOnTopChanged() {
        keepOnTopItem?.state = config.keepPreviewOnTop ? .on : .off
        captureCoordinator.updatePreviewWindowLevel()
    }
}
