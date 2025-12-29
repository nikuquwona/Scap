import Cocoa

final class SelectionView: NSView {
    var onComplete: ((CGRect?) -> Void)?

    private var dragStart: CGPoint?
    private var dragEnd: CGPoint?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.25).setFill()
        dirtyRect.fill()

        guard let rect = selectionRect else { return }

        NSColor.clear.setFill()
        NSBezierPath(rect: rect).fill()

        let path = NSBezierPath(rect: rect)
        NSColor.white.setStroke()
        path.lineWidth = 2
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        dragStart = convert(event.locationInWindow, from: nil)
        dragEnd = dragStart
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        dragEnd = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        dragEnd = convert(event.locationInWindow, from: nil)
        let rect = selectionRect
        dragStart = nil
        dragEnd = nil
        needsDisplay = true
        onComplete?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onComplete?(nil)
        }
    }

    private var selectionRect: CGRect? {
        guard let start = dragStart, let end = dragEnd else { return nil }
        let x = min(start.x, end.x)
        let y = min(start.y, end.y)
        let width = abs(start.x - end.x)
        let height = abs(start.y - end.y)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
