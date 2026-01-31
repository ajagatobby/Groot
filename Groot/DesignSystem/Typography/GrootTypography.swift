import SwiftUI

// MARK: - Groot Typography

enum GrootTypography {
    
    // MARK: - Font Styles
    
    /// Large display text - 32pt bold rounded
    static func display(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Page titles - 24pt bold rounded
    static func title(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Section headers - 20pt bold rounded
    static func heading(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Subheadings - 16pt semibold rounded
    static func subheading(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Body text - 16pt regular rounded
    static func body(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Secondary body - 14pt regular rounded
    static func bodySmall(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundStyle(Color.grootStone)
    }
    
    /// Caption text - 12pt medium rounded
    static func caption(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(Color.grootStone)
    }
    
    /// Button text - 16pt bold rounded
    static func button(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 16, weight: .bold, design: .rounded))
    }
    
    /// Large button text - 18pt bold rounded
    static func buttonLarge(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 18, weight: .bold, design: .rounded))
    }
    
    /// Small button text - 14pt bold rounded
    static func buttonSmall(_ text: String) -> some View {
        Text(text.lowercased())
            .font(.system(size: 14, weight: .bold, design: .rounded))
    }
    
    /// Number display - 28pt bold rounded (for stats)
    static func number(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    /// Large number display - 40pt bold rounded (for hero stats)
    static func numberLarge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
}

// MARK: - View Modifiers for Typography

extension View {
    
    func grootDisplay() -> some View {
        self
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    func grootTitle() -> some View {
        self
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    func grootHeading() -> some View {
        self
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    func grootSubheading() -> some View {
        self
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    func grootBody() -> some View {
        self
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
    
    func grootBodySmall() -> some View {
        self
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundStyle(Color.grootStone)
    }
    
    func grootCaption() -> some View {
        self
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(Color.grootStone)
    }
    
    func grootButton() -> some View {
        self
            .font(.system(size: 16, weight: .bold, design: .rounded))
    }
    
    func grootNumber() -> some View {
        self
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Color.grootBark)
    }
}

// MARK: - Text Styles Enum

enum GrootTextStyle {
    case display
    case title
    case heading
    case subheading
    case body
    case bodySmall
    case caption
    case button
    case buttonLarge
    case buttonSmall
    case number
    case numberLarge
    
    var font: Font {
        switch self {
        case .display:
            return .system(size: 32, weight: .bold, design: .rounded)
        case .title:
            return .system(size: 24, weight: .bold, design: .rounded)
        case .heading:
            return .system(size: 20, weight: .bold, design: .rounded)
        case .subheading:
            return .system(size: 16, weight: .semibold, design: .rounded)
        case .body:
            return .system(size: 16, weight: .regular, design: .rounded)
        case .bodySmall:
            return .system(size: 14, weight: .regular, design: .rounded)
        case .caption:
            return .system(size: 12, weight: .medium, design: .rounded)
        case .button:
            return .system(size: 16, weight: .bold, design: .rounded)
        case .buttonLarge:
            return .system(size: 18, weight: .bold, design: .rounded)
        case .buttonSmall:
            return .system(size: 14, weight: .bold, design: .rounded)
        case .number:
            return .system(size: 28, weight: .bold, design: .rounded)
        case .numberLarge:
            return .system(size: 40, weight: .bold, design: .rounded)
        }
    }
    
    var color: Color {
        switch self {
        case .bodySmall, .caption:
            return .grootStone
        default:
            return .grootBark
        }
    }
}

// MARK: - Styled Text View

struct GrootText: View {
    let text: String
    let style: GrootTextStyle
    let color: Color?
    
    init(_ text: String, style: GrootTextStyle = .body, color: Color? = nil) {
        self.text = text
        self.style = style
        self.color = color
    }
    
    private var displayText: String {
        switch style {
        case .display, .title, .heading, .subheading, .caption, .button, .buttonLarge, .buttonSmall:
            return text.lowercased()
        default:
            return text
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(style.font)
            .foregroundStyle(color ?? style.color)
    }
}
