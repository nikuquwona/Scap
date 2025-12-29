import Cocoa

final class LauncherWindowController: NSWindowController {
    private let onCapture: () -> Void
    private let onPreferences: () -> Void

    init(onCapture: @escaping () -> Void, onPreferences: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onPreferences = onPreferences

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 180),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Scap"
        window.isReleasedWhenClosed = false

        super.init(window: window)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window else { return }
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let title = NSTextField(labelWithString: "Scap is running")
        title.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = NSTextField(labelWithString: "Use the buttons below or the menu bar icon.")
        subtitle.textColor = .secondaryLabelColor
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let captureButton = NSButton(title: "Capture", target: self, action: #selector(capture))
        let preferencesButton = NSButton(title: "Preferences…", target: self, action: #selector(preferences))
        captureButton.bezelStyle = .rounded
        preferencesButton.bezelStyle = .rounded

        let buttonStack = NSStackView(views: [captureButton, preferencesButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),

            subtitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),

            buttonStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonStack.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20)
        ])
    }

    @objc private func capture() {
        onCapture()
    }

    @objc private func preferences() {
        onPreferences()
    }
}
