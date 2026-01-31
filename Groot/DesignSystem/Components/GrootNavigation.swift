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
                    Button {
                        withAnimation(.grootSnappy) {
                            selectedTab = index
                        }
                        GrootHaptics.selection()
                    } label: {
                        VStack(spacing: 4) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedTab == index ? Color.grootShield : Color.grootPebble)
                                
                                if let badge = tabs[index].badge, badge > 0 {
                                    Text(badge > 99 ? "99+" : "\(badge)")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.grootFlame)
                                        .clipShape(Capsule())
                                        .offset(x: 8, y: -4)
                                }
                            }
                            
                            Text(tabs[index].label.lowercased())
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(selectedTab == index ? Color.grootShield : Color.grootPebble)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(Color.grootSnow)
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
