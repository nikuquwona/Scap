import Cocoa
import Carbon

final class HotkeyManager {
    private let onHotkey: () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let config = AppConfig.shared

    init(onHotkey: @escaping () -> Void) {
        self.onHotkey = onHotkey
    }

    func register() {
        unregister()
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, _, userData in
            guard let userData else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.onHotkey()
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventSpec, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        let hotkey = config.hotkey
        let hotKeyID = EventHotKeyID(signature: OSType(0x53434150), id: 1) // "SCAP"

        RegisterEventHotKey(UInt32(hotkey.keyCode), hotkey.modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRef = nil
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
        eventHandler = nil
    }
}
