import SwiftUI

enum StarWarsColors {
    static let primary = Color("SWYellow")
    static let background = Color("SWBackground")
    static let surface = Color("SWCard")
}

extension Int {
    func toRomanNumeral() -> String {
        switch self {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        case 5: return "V"
        case 6: return "VI"
        default: return String(self)
        }
    }
}
