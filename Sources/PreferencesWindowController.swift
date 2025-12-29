import Cocoa
import Carbon

final class PreferencesWindowController: NSWindowController {
    private let config = AppConfig.shared
    private var savePathField: NSTextField!
    private var hotkeyField: NSTextField!
    private var recordButton: NSButton!
    private var keepOnTopCheckbox: NSButton!
    private var keyMonitor: Any?

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.isReleasedWhenClosed = false

        super.init(window: window)

        setupUI()
        refreshUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window else { return }
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        let saveRow = labeledRow(title: "Save Folder")
        savePathField = NSTextField(labelWithString: "")
        savePathField.lineBreakMode = .byTruncatingMiddle
        let chooseButton = NSButton(title: "Choose…", target: self, action: #selector(chooseFolder))
        saveRow.addArrangedSubview(savePathField)
        saveRow.addArrangedSubview(chooseButton)

        let hotkeyRow = labeledRow(title: "Hotkey")
        hotkeyField = NSTextField(labelWithString: "")
        recordButton = NSButton(title: "Record", target: self, action: #selector(recordHotkey))
        hotkeyRow.addArrangedSubview(hotkeyField)
        hotkeyRow.addArrangedSubview(recordButton)

        keepOnTopCheckbox = NSButton(checkboxWithTitle: "Preview always on top", target: self, action: #selector(toggleKeepOnTop))

        stack.addArrangedSubview(saveRow)
        stack.addArrangedSubview(hotkeyRow)
        stack.addArrangedSubview(keepOnTopCheckbox)

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ])
    }

    private func labeledRow(title: String) -> NSStackView {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 12, weight: .semibold)

        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        label.widthAnchor.constraint(equalToConstant: 90).isActive = true
        row.addArrangedSubview(label)
        return row
    }

    private func refreshUI() {
        savePathField.stringValue = config.saveDirectory.path
        hotkeyField.stringValue = HotkeyFormatter.string(from: config.hotkey)
        keepOnTopCheckbox.state = config.keepPreviewOnTop ? .on : .off
    }

    @objc private func chooseFolder() {
        guard let window else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { [weak self] response in
            guard let self, response == .OK, let url = panel.url else { return }
            self.config.saveDirectory = url
            self.savePathField.stringValue = url.path
        }
    }

    @objc private func recordHotkey() {
        if keyMonitor != nil {
            stopRecording()
            return
        }

        hotkeyField.stringValue = "Press keys…"
        recordButton.title = "Stop"

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 { // Escape
                self.stopRecording()
                self.refreshUI()
                return nil
            }

            let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
            if modifiers.isEmpty {
                return nil
            }

            let carbonModifiers = CarbonModifierFlags.from(modifiers)
            let newHotkey = HotkeyDefinition(keyCode: event.keyCode, modifiers: carbonModifiers)
            self.config.hotkey = newHotkey
            self.hotkeyField.stringValue = HotkeyFormatter.string(from: newHotkey)
            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
            self.stopRecording()
            return nil
        }
    }

    @objc private func toggleKeepOnTop() {
        config.keepPreviewOnTop = (keepOnTopCheckbox.state == .on)
        NotificationCenter.default.post(name: .keepOnTopChanged, object: nil)
    }

    private func stopRecording() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        keyMonitor = nil
        recordButton.title = "Record"
    }
}

private enum CarbonModifierFlags {
    static func from(_ flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        if flags.contains(.shift) { carbon |= UInt32(shiftKey) }
        if flags.contains(.option) { carbon |= UInt32(optionKey) }
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        return carbon
    }
}
