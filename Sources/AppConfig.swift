import Foundation
import Carbon

final class AppConfig {
    static let shared = AppConfig()

    private let defaults = UserDefaults.standard
    private let keepPreviewOnTopKey = "keepPreviewOnTop"
    private let saveDirectoryKey = "saveDirectory"
    private let hotkeyKeyCodeKey = "hotkeyKeyCode"
    private let hotkeyModifiersKey = "hotkeyModifiers"

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

    var hotkey: HotkeyDefinition {
        get {
            let keyCode = defaults.object(forKey: hotkeyKeyCodeKey) as? Int ?? Int(kVK_ANSI_6)
            let modifiers = defaults.object(forKey: hotkeyModifiersKey) as? Int ?? Int(cmdKey | shiftKey)
            return HotkeyDefinition(keyCode: UInt32(keyCode), modifiers: UInt32(modifiers))
        }
        set {
            defaults.set(Int(newValue.keyCode), forKey: hotkeyKeyCodeKey)
            defaults.set(Int(newValue.modifiers), forKey: hotkeyModifiersKey)
        }
    }

    private init() {
        if defaults.object(forKey: keepPreviewOnTopKey) == nil {
            defaults.set(true, forKey: keepPreviewOnTopKey)
        }
    }
}
