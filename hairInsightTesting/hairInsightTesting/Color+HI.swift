//
//  Color+HI.swift
//  hairInsightTesting
//
//  Created by Assistant on 4/16/26.
//

import SwiftUI

extension Color {
    /// Initialize a Color from a hex string like "#RRGGBB" or "RRGGBB" with optional alpha ("#RRGGBBAA").
    init(hex hexString: String) {
        let cleaned = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 8: // RRGGBBAA
            r = (int & 0xFF00_0000) >> 24
            g = (int & 0x00FF_0000) >> 16
            b = (int & 0x0000_FF00) >> 8
            a = (int & 0x0000_00FF)
        case 6: // RRGGBB
            r = (int & 0xFF00_00) >> 16
            g = (int & 0x00FF_00) >> 8
            b = (int & 0x0000_FF)
            a = 0xFF
        default:
            // Fallback to a neutral gray if parsing fails
            self = Color.gray
            return
        }

        self = Color(.sRGB,
                     red: Double(r) / 255.0,
                     green: Double(g) / 255.0,
                     blue: Double(b) / 255.0,
                     opacity: Double(a) / 255.0)
    }

    // MARK: - Hair Insight Palette
    static let hiWarm       = Color(hex: "#F6EFE6")
    static let hiBackground = Color(hex: "#FCFAF7")
    static let hiAccent     = Color(hex: "#7C5A3A")
    static let hiMuted      = Color(hex: "#A39486")
    static let hiInk        = Color(hex: "#2F2A26")
    static let hiRed        = Color(hex: "#D84C4C")
    static let hiBorder     = Color(hex: "#E6DED4")
}
