import Carbon

enum HotkeyFormatter {
    static func string(from hotkey: HotkeyDefinition) -> String {
        var parts: [String] = []
        if hotkey.modifiers & UInt32(cmdKey) != 0 { parts.append("Cmd") }
        if hotkey.modifiers & UInt32(shiftKey) != 0 { parts.append("Shift") }
        if hotkey.modifiers & UInt32(optionKey) != 0 { parts.append("Option") }
        if hotkey.modifiers & UInt32(controlKey) != 0 { parts.append("Control") }

        let keyName = keyName(for: hotkey.keyCode)
        parts.append(keyName)
        return parts.joined(separator: "+")
    }

    private static func keyName(for keyCode: UInt16) -> String {
        switch keyCode {
        case UInt16(kVK_ANSI_A): return "A"
        case UInt16(kVK_ANSI_B): return "B"
        case UInt16(kVK_ANSI_C): return "C"
        case UInt16(kVK_ANSI_D): return "D"
        case UInt16(kVK_ANSI_E): return "E"
        case UInt16(kVK_ANSI_F): return "F"
        case UInt16(kVK_ANSI_G): return "G"
        case UInt16(kVK_ANSI_H): return "H"
        case UInt16(kVK_ANSI_I): return "I"
        case UInt16(kVK_ANSI_J): return "J"
        case UInt16(kVK_ANSI_K): return "K"
        case UInt16(kVK_ANSI_L): return "L"
        case UInt16(kVK_ANSI_M): return "M"
        case UInt16(kVK_ANSI_N): return "N"
        case UInt16(kVK_ANSI_O): return "O"
        case UInt16(kVK_ANSI_P): return "P"
        case UInt16(kVK_ANSI_Q): return "Q"
        case UInt16(kVK_ANSI_R): return "R"
        case UInt16(kVK_ANSI_S): return "S"
        case UInt16(kVK_ANSI_T): return "T"
        case UInt16(kVK_ANSI_U): return "U"
        case UInt16(kVK_ANSI_V): return "V"
        case UInt16(kVK_ANSI_W): return "W"
        case UInt16(kVK_ANSI_X): return "X"
        case UInt16(kVK_ANSI_Y): return "Y"
        case UInt16(kVK_ANSI_Z): return "Z"
        case UInt16(kVK_ANSI_0): return "0"
        case UInt16(kVK_ANSI_1): return "1"
        case UInt16(kVK_ANSI_2): return "2"
        case UInt16(kVK_ANSI_3): return "3"
        case UInt16(kVK_ANSI_4): return "4"
        case UInt16(kVK_ANSI_5): return "5"
        case UInt16(kVK_ANSI_6): return "6"
        case UInt16(kVK_ANSI_7): return "7"
        case UInt16(kVK_ANSI_8): return "8"
        case UInt16(kVK_ANSI_9): return "9"
        case UInt16(kVK_Space): return "Space"
        default: return "Key\(keyCode)"
        }
    }
}
