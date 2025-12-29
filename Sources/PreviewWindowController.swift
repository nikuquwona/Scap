import Cocoa

final class PreviewWindowController: NSWindowController {
    private let image: NSImage

    init(image: NSImage, keepOnTop: Bool) {
        self.image = image

        let size = image.size
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = keepOnTop ? .floating : .normal
        window.backgroundColor = .black

        super.init(window: window)

        let imageView = NSImageView(frame: window.contentView?.bounds ?? .zero)
        imageView.image = image
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.autoresizingMask = [.width, .height]
        window.contentView = imageView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window = window else { return }
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    func updateWindowLevel(keepOnTop: Bool) {
        window?.level = keepOnTop ? .floating : .normal
    }
}
