import SwiftUI

// MARK: - Groot List Item

struct GrootListItem: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    let accessory: AccessoryType
    let action: (() -> Void)?
    
    enum AccessoryType {
        case none
        case chevron
        case checkmark
        case badge(String)
        case toggle(Binding<Bool>)
        case custom(AnyView)
    }
    
    init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = .grootShield,
        accessory: AccessoryType = .chevron,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
            if action != nil {
                GrootHaptics.selection()
            }
        } label: {
            HStack(spacing: 14) {
                if let icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title.lowercased())
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                accessoryView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil && !isToggleAccessory)
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
            
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.grootPebble)
            
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.grootShield)
            
        case .badge(let text):
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.grootFlame)
                .clipShape(Capsule())
            
        case .toggle(let isOn):
            GrootToggleSwitch(isOn: isOn)
            
        case .custom(let view):
            view
        }
    }
    
    private var isToggleAccessory: Bool {
        if case .toggle = accessory {
            return true
        }
        return false
    }
}

// MARK: - Grouped List

struct GrootListSection<Content: View>: View {
    let title: String?
    let footer: String?
    let content: Content
    
    init(
        _ title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title.lowercased())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if let footer {
                Text(footer)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - List Divider

struct GrootListDivider: View {
    let leadingPadding: CGFloat
    
    init(leadingPadding: CGFloat = 70) {
        self.leadingPadding = leadingPadding
    }
    
    var body: some View {
        Divider()
            .padding(.leading, leadingPadding)
    }
}

// MARK: - Swipeable List Item

struct GrootSwipeableListItem<Content: View>: View {
    let content: Content
    let leadingActions: [SwipeAction]
    let trailingActions: [SwipeAction]
    
    struct SwipeAction {
        let icon: String
        let color: Color
        let action: () -> Void
    }
    
    @State private var offset: CGFloat = 0
    @State private var initialOffset: CGFloat = 0
    
    private var maxLeadingOffset: CGFloat {
        CGFloat(leadingActions.count) * 70
    }
    
    private var maxTrailingOffset: CGFloat {
        CGFloat(trailingActions.count) * -70
    }
    
    init(
        leadingActions: [SwipeAction] = [],
        trailingActions: [SwipeAction] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(leadingActions.indices, id: \.self) { index in
                    Button {
                        leadingActions[index].action()
                        closeSwipe()
                    } label: {
                        Image(systemName: leadingActions[index].icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 70)
                            .frame(maxHeight: .infinity)
                            .background(leadingActions[index].color)
                    }
                }
                
                Spacer()
                
                ForEach(trailingActions.indices, id: \.self) { index in
                    Button {
                        trailingActions[index].action()
                        closeSwipe()
                    } label: {
                        Image(systemName: trailingActions[index].icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 70)
                            .frame(maxHeight: .infinity)
                            .background(trailingActions[index].color)
                    }
                }
            }
            
            content
                .background(Color.grootSnow)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = initialOffset + value.translation.width
                            
                            // Allow swiping in both directions
                            // Clamp offset between maxTrailing and maxLeading
                            if !leadingActions.isEmpty && !trailingActions.isEmpty {
                                // Has both actions - allow full range
                                offset = min(max(newOffset, maxTrailingOffset), maxLeadingOffset)
                            } else if !leadingActions.isEmpty {
                                // Only leading actions - allow 0 to maxLeading with rubber band for negative
                                if newOffset < 0 {
                                    offset = newOffset * 0.3 // Rubber band effect
                                } else {
                                    offset = min(newOffset, maxLeadingOffset)
                                }
                            } else if !trailingActions.isEmpty {
                                // Only trailing actions - allow maxTrailing to 0 with rubber band for positive
                                if newOffset > 0 {
                                    offset = newOffset * 0.3 // Rubber band effect
                                } else {
                                    offset = max(newOffset, maxTrailingOffset)
                                }
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            let velocity = value.velocity.width
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                // Use velocity to help determine intent
                                if velocity > 500 {
                                    // Fast swipe right
                                    if !leadingActions.isEmpty {
                                        offset = maxLeadingOffset
                                    } else {
                                        offset = 0
                                    }
                                } else if velocity < -500 {
                                    // Fast swipe left
                                    if !trailingActions.isEmpty {
                                        offset = maxTrailingOffset
                                    } else {
                                        offset = 0
                                    }
                                } else {
                                    // Slow swipe - use position threshold
                                    if offset > threshold && !leadingActions.isEmpty {
                                        offset = maxLeadingOffset
                                    } else if offset < -threshold && !trailingActions.isEmpty {
                                        offset = maxTrailingOffset
                                    } else {
                                        offset = 0
                                    }
                                }
                                
                                initialOffset = offset
                            }
                        }
                )
                .onTapGesture {
                    // Tap to close if swiped open
                    if offset != 0 {
                        closeSwipe()
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    private func closeSwipe() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            offset = 0
            initialOffset = 0
        }
    }
}

// MARK: - Preview

#Preview("Groot List Items") {
    ScrollView {
        VStack(spacing: 24) {
            GrootListSection("blocking settings") {
                GrootListItem(
                    "blocked numbers",
                    subtitle: "127 numbers blocked",
                    icon: "hand.raised.fill",
                    iconColor: .grootFlame
                ) { }
                
                GrootListDivider()
                
                GrootListItem(
                    "country blocking",
                    subtitle: "3 countries blocked",
                    icon: "globe",
                    iconColor: .grootSky
                ) { }
                
                GrootListDivider()
                
                GrootListItem(
                    "pattern rules",
                    subtitle: "5 active patterns",
                    icon: "number",
                    iconColor: .grootViolet,
                    accessory: .badge("new")
                ) { }
            }
            
            GrootListSection("whitelist", footer: "Contacts in your whitelist will never be blocked") {
                GrootListItem(
                    "allowed contacts",
                    subtitle: "42 contacts",
                    icon: "checkmark.shield.fill",
                    iconColor: .grootShield
                ) { }
                
                GrootListDivider()
                
                GrootListItem(
                    "allow contacts only",
                    icon: "person.2.fill",
                    iconColor: .grootAmber,
                    accessory: .toggle(.constant(false))
                )
            }
            
            GrootListSection("preferences") {
                GrootListItem(
                    "notifications",
                    icon: "bell.fill",
                    iconColor: .grootSun,
                    accessory: .toggle(.constant(true))
                )
                
                GrootListDivider()
                
                GrootListItem(
                    "haptic feedback",
                    icon: "waveform",
                    iconColor: .grootViolet,
                    accessory: .toggle(.constant(true))
                )
            }
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
