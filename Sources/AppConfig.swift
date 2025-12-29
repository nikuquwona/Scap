import Foundation

final class AppConfig {
    static let shared = AppConfig()

    private let defaults = UserDefaults.standard
    private let keepPreviewOnTopKey = "keepPreviewOnTop"
    private let saveDirectoryKey = "saveDirectory"

    var keepPreviewOnTop: Bool {
        get { defaults.bool(forKey: keepPreviewOnTopKey) }
        set { defaults.set(newValue, forKey: keepPreviewOnTopKey) }
    }

    var saveDirectory: URL {
        get {
            if let path = defaults.string(forKey: saveDirectoryKey) {
                return URL(fileURLWithPath: path, isDirectory: true)
            }
            let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            return desktop ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }
        set {
            defaults.set(newValue.path, forKey: saveDirectoryKey)
        }
    }

    private init() {
        if defaults.object(forKey: keepPreviewOnTopKey) == nil {
            defaults.set(true, forKey: keepPreviewOnTopKey)
        }
    }
}
