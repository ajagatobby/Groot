import SwiftUI

// MARK: - Groot Navigation Bar

struct GrootNavBar<Leading: View, Trailing: View>: View {
    let title: String?
    let subtitle: String?
    let leading: Leading
    let trailing: Trailing
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            leading
                .frame(minWidth: 44)
            
            Spacer()
            
            if let title {
                VStack(spacing: 2) {
                    Text(title.lowercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    if let subtitle {
                        Text(subtitle.lowercased())
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                }
            }
            
            Spacer()
            
            trailing
                .frame(minWidth: 44)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.grootSnow)
    }
}

// MARK: - Back Button

struct GrootBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.grootBark)
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Close Button

struct GrootCloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.grootStone)
                .frame(width: 36, height: 36)
                .background(Color.grootCloud)
                .clipShape(Circle())
        }
    }
}

// MARK: - Tab Bar

struct GrootTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [GrootTab]
    
    @Namespace private var tabNamespace
    
    struct GrootTab {
        let icon: String
        let selectedIcon: String
        let label: String
        let badge: Int?
        
        init(icon: String, selectedIcon: String? = nil, label: String, badge: Int? = nil) {
            self.icon = icon
            self.selectedIcon = selectedIcon ?? icon
            self.label = label
            self.badge = badge
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.grootMist)
                .frame(height: 1)
            
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    GrootTabItem(
                        tab: tabs[index],
                        isSelected: selectedTab == index,
                        namespace: tabNamespace
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                        GrootHaptics.selection()
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(Color.grootSnow)
    }
}

// MARK: - Tab Item

struct GrootTabItem: View {
    let tab: GrootTabBar.GrootTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var iconBounce = false
    
    var body: some View {
        Button {
            action()
            triggerIconBounce()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Selection indicator background
                    if isSelected {
                        Capsule()
                            .fill(Color.grootShield.opacity(0.12))
                            .frame(width: 56, height: 32)
                            .matchedGeometryEffect(id: "tabIndicator", in: namespace)
                    }
                    
                    // Icon with badge
                    ZStack(alignment: .topTrailing) {
                        // Animated icon
                        ZStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(Color.grootPebble)
                                .opacity(isSelected ? 0 : 1)
                                .scaleEffect(isSelected ? 0.6 : 1)
                            
                            Image(systemName: tab.selectedIcon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color.grootShield)
                                .opacity(isSelected ? 1 : 0)
                                .scaleEffect(isSelected ? 1 : 0.6)
                        }
                        .scaleEffect(iconBounce ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: iconBounce)
                        
                        // Badge
                        if let badge = tab.badge, badge > 0 {
                            BadgeView(count: badge)
                                .offset(x: 10, y: -6)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .frame(height: 32)
                
                // Label
                Text(tab.label.lowercased())
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.grootShield : Color.grootPebble)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(TabButtonStyle(isPressed: $isPressed))
    }
    
    private func triggerIconBounce() {
        iconBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            iconBounce = false
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let count: Int
    
    @State private var appeared = false
    
    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.grootFlame)
            .clipShape(Capsule())
            .scaleEffect(appeared ? 1.0 : 0.5)
            .opacity(appeared ? 1.0 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Tab Button Style

struct TabButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Segmented Control

struct GrootSegmentedControl: View {
    @Binding var selectedIndex: Int
    let segments: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                Button {
                    withAnimation(.grootSnappy) {
                        selectedIndex = index
                    }
                    GrootHaptics.selection()
                } label: {
                    Text(segments[index].lowercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedIndex == index ? .white : Color.grootStone)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedIndex == index ? Color.grootShield : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color.grootCloud)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Page Indicator

struct GrootPageIndicator: View {
    let totalPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.grootShield : Color.grootMist)
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.grootSnappy, value: currentPage)
            }
        }
    }
}

// MARK: - Preview

#Preview("Groot Navigation") {
    VStack(spacing: 0) {
        GrootNavBar(title: "blocked numbers", subtitle: "127 total") {
            GrootBackButton { }
        } trailing: {
            GrootIconButton("plus", variant: .primary, size: .small) { }
        }
        
        Divider()
        
        ScrollView {
            VStack(spacing: 24) {
                GrootText("segmented control", style: .heading)
                
                GrootSegmentedControl(
                    selectedIndex: .constant(0),
                    segments: ["all", "manual", "patterns", "countries"]
                )
                
                GrootText("page indicator", style: .heading)
                
                GrootPageIndicator(totalPages: 4, currentPage: 1)
                
                Spacer()
            }
            .padding(20)
        }
        
        GrootTabBar(
            selectedTab: .constant(0),
            tabs: [
                .init(icon: "shield", selectedIcon: "shield.fill", label: "blocked", badge: 5),
                .init(icon: "checkmark.shield", selectedIcon: "checkmark.shield.fill", label: "allowed"),
                .init(icon: "globe", selectedIcon: "globe", label: "countries"),
                .init(icon: "gearshape", selectedIcon: "gearshape.fill", label: "settings")
            ]
        )
    }
    .background(Color.grootCloud)
}
