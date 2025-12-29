import Cocoa

final class CaptureCoordinator {
    private let config = AppConfig.shared
    private var previewController: PreviewWindowController?
    private var selectionController: SelectionWindowController?

    func beginCapture() {
        selectionController?.close()
        let selector = SelectionWindowController()
        selectionController = selector
        selector.onSelection = { [weak self] rect in
            guard let self else { return }
            self.selectionController = nil
            guard let rect, rect.width > 2, rect.height > 2 else { return }

            guard let image = ScreenCapture.capture(rect: rect) else {
                PermissionAlert.showScreenRecording()
                return
            }

            self.showPreview(image: image)
            ImageWriter.save(image: image, to: self.config.saveDirectory)
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
