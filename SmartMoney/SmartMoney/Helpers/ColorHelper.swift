import UIKit
import SwiftUI

extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, cgColor.numberOfComponents == 4 else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        let hexString = String(format: "#%02X%02X%02X",
                              Int(r * 255),
                              Int(g * 255),
                              Int(b * 255))
        return hexString
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        return uiColor.toHex()
    }
}
