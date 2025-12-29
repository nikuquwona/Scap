import Cocoa

enum PermissionAlert {
    static func showScreenRecording() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "Enable Screen Recording for Scap in System Settings to capture the screen."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenRecording") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
