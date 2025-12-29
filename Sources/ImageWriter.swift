import Cocoa

enum ImageWriter {
    static func save(image: NSImage, to directory: URL) {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let data = rep.representation(using: .png, properties: [:]) else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "Scap_\(formatter.string(from: Date())).png"
        let url = directory.appendingPathComponent(filename)

        do {
            try data.write(to: url)
        } catch {
            NSLog("Failed to save image: \(error)")
        }
    }
}
