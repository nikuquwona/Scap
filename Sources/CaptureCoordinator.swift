import Cocoa

final class CaptureCoordinator {
    private let config = AppConfig.shared
    private var previewController: PreviewWindowController?

    func beginCapture() {
        let selector = SelectionWindowController()
        selector.onSelection = { [weak self] rect in
            guard let self else { return }
            guard let rect, rect.width > 2, rect.height > 2 else { return }

            if let image = ScreenCapture.capture(rect: rect) {
                self.showPreview(image: image)
                ImageWriter.save(image: image, to: self.config.saveDirectory)
            }
        }
        selector.present()
    }

    func updatePreviewWindowLevel() {
        previewController?.updateWindowLevel(keepOnTop: config.keepPreviewOnTop)
    }

    private func showPreview(image: NSImage) {
        previewController?.close()
        let controller = PreviewWindowController(image: image, keepOnTop: config.keepPreviewOnTop)
        controller.show()
        previewController = controller
    }
}
