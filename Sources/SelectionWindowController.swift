import Cocoa

final class SelectionWindowController: NSWindowController {
    var onSelection: ((CGRect?) -> Void)?

    private let selectionView = SelectionView(frame: .zero)

    init() {
        let screenFrame = NSScreen.main?.frame ?? .zero
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.ignoresMouseEvents = false
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        super.init(window: window)

        selectionView.frame = window.contentView?.bounds ?? .zero
        selectionView.autoresizingMask = [.width, .height]
        selectionView.onComplete = { [weak self] rect in
            guard let self else { return }
            self.close()
            if let rect, let window = self.window {
                let screenRect = window.convertToScreen(rect)
                self.onSelection?(screenRect)
            } else {
                self.onSelection?(nil)
            }
        }
        window.contentView = selectionView
        window.makeFirstResponder(selectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        guard let window = window else { return }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
