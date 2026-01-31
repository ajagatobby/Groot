import SwiftUI

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Groot Color Palette

enum GrootColors {
    
    // MARK: - Core Brand Colors
    
    /// Primary green - Protection, security, "safe"
    static let shield = Color(hex: "#58CC02")
    
    /// Lighter green for accents
    static let leaf = Color(hex: "#89E219")
    
    /// Dark green for button shadows
    static let forest = Color(hex: "#58A700")
    
    /// Pure white background
    static let snow = Color(hex: "#FFFFFF")
    
    /// Primary text color
    static let bark = Color(hex: "#4B4B4B")
    
    // MARK: - Secondary Colors
    
    /// Blue - Info, settings, secondary actions
    static let sky = Color(hex: "#1CB0F6")
    static let ocean = Color(hex: "#1899D6")
    
    /// Red - Blocked calls, danger, delete
    static let flame = Color(hex: "#FF4B4B")
    static let ember = Color(hex: "#EA2B2B")
    
    /// Yellow - Warnings, attention
    static let sun = Color(hex: "#FFC800")
    static let gold = Color(hex: "#FFB100")
    
    /// Orange - Streaks, achievements
    static let amber = Color(hex: "#FF9600")
    
    /// Purple - Premium features
    static let violet = Color(hex: "#CE82FF")
    static let grape = Color(hex: "#9069CD")
    
    // MARK: - Neutrals
    
    /// Secondary text
    static let stone = Color(hex: "#777777")
    
    /// Disabled text, placeholders
    static let pebble = Color(hex: "#AFAFAF")
    
    /// Borders, dividers
    static let mist = Color(hex: "#E5E5E5")
    
    /// Subtle backgrounds
    static let cloud = Color(hex: "#F7F7F7")
    
    // MARK: - Semantic Colors
    
    /// Success states
    static let success = shield
    static let successBackground = Color(hex: "#D7FFB8")
    
    /// Error states
    static let error = flame
    static let errorBackground = Color(hex: "#FFDFE0")
    
    /// Warning states
    static let warning = sun
    static let warningBackground = Color(hex: "#FFF5D3")
    
    /// Info states
    static let info = sky
    static let infoBackground = Color(hex: "#DDF4FF")
    
    // MARK: - Functional Colors
    
    /// Blocked call indicator
    static let blocked = flame
    
    /// Whitelisted/allowed indicator
    static let allowed = shield
    
    /// Pattern/rule indicator
    static let pattern = violet
    
    /// Country block indicator
    static let country = sky
}

// MARK: - Color Extensions for SwiftUI

extension Color {
    
    // MARK: - Brand
    
    static let grootShield = GrootColors.shield
    static let grootLeaf = GrootColors.leaf
    static let grootForest = GrootColors.forest
    static let grootSnow = GrootColors.snow
    static let grootBark = GrootColors.bark
    
    // MARK: - Secondary
    
    static let grootSky = GrootColors.sky
    static let grootOcean = GrootColors.ocean
    static let grootFlame = GrootColors.flame
    static let grootEmber = GrootColors.ember
    static let grootSun = GrootColors.sun
    static let grootGold = GrootColors.gold
    static let grootAmber = GrootColors.amber
    static let grootViolet = GrootColors.violet
    static let grootGrape = GrootColors.grape
    
    // MARK: - Neutrals
    
    static let grootStone = GrootColors.stone
    static let grootPebble = GrootColors.pebble
    static let grootMist = GrootColors.mist
    static let grootCloud = GrootColors.cloud
    
    // MARK: - Semantic
    
    static let grootSuccess = GrootColors.success
    static let grootSuccessBg = GrootColors.successBackground
    static let grootError = GrootColors.error
    static let grootErrorBg = GrootColors.errorBackground
    static let grootWarning = GrootColors.warning
    static let grootWarningBg = GrootColors.warningBackground
    static let grootInfo = GrootColors.info
    static let grootInfoBg = GrootColors.infoBackground
}

// MARK: - Button Color Pairs

struct GrootButtonColors {
    let background: Color
    let shadow: Color
    let foreground: Color
    
    static let primary = GrootButtonColors(
        background: .grootShield,
        shadow: .grootForest,
        foreground: .white
    )
    
    static let secondary = GrootButtonColors(
        background: .grootSky,
        shadow: .grootOcean,
        foreground: .white
    )
    
    static let danger = GrootButtonColors(
        background: .grootFlame,
        shadow: .grootEmber,
        foreground: .white
    )
    
    static let warning = GrootButtonColors(
        background: .grootSun,
        shadow: .grootGold,
        foreground: .grootBark
    )
    
    static let premium = GrootButtonColors(
        background: .grootViolet,
        shadow: .grootGrape,
        foreground: .white
    )
    
    static let disabled = GrootButtonColors(
        background: .grootMist,
        shadow: .grootPebble,
        foreground: .grootStone
    )
}
