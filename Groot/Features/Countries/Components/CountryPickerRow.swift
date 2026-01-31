import SwiftUI

// MARK: - Country Picker Row

struct CountryPickerRow: View {
    let flag: String
    let name: String
    let code: String
    let isBlocked: Bool
    let blockedCalls: Int
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                Text(flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name.lowercased())
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text(code)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                }
                
                Spacer()
                
                if isBlocked {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.grootFlame)
                        
                        if blockedCalls > 0 {
                            Text("\(blockedCalls) blocked")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.grootFlame)
                        }
                    }
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.grootPebble)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isBlocked ? Color.grootErrorBg : Color.grootSnow)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.grootSnappy, value: isBlocked)
    }
}

// MARK: - Blocked Country Card

struct BlockedCountryCard: View {
    let flag: String
    let name: String
    let code: String
    let blockedCalls: Int
    let blockedSince: Date
    let onUnblock: () -> Void
    
    var body: some View {
        GrootCard(variant: .flat, padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.grootFlame.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Text(flag)
                        .font(.system(size: 28))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.lowercased())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text(code)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 10))
                            Text("\(blockedCalls)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.grootFlame)
                        
                        Text("•")
                            .foregroundStyle(Color.grootPebble)
                        
                        Text("since \(formattedDate)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                }
                
                Spacer()
                
                Button(action: onUnblock) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.grootPebble)
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: blockedSince)
    }
}

// MARK: - Country Search Header

struct CountrySearchHeader: View {
    @Binding var searchText: String
    let blockedCount: Int
    let totalCount: Int
    
    init(searchText: Binding<String>, blockedCount: Int, totalCount: Int = CountryDataService.shared.countryCount) {
        self._searchText = searchText
        self.blockedCount = blockedCount
        self.totalCount = totalCount
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.grootSky.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "globe")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.grootSky)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("country blocking")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    HStack(spacing: 4) {
                        Text("\(blockedCount) blocked")
                            .foregroundStyle(blockedCount > 0 ? Color.grootFlame : Color.grootStone)
                        
                        Text("•")
                            .foregroundStyle(Color.grootPebble)
                        
                        Text("\(totalCount) countries")
                            .foregroundStyle(Color.grootStone)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                
                Spacer()
            }
            
            GrootSearchField("search \(totalCount) countries", text: $searchText)
        }
    }
}

// MARK: - Region Section

struct CountryRegionSection: View {
    let region: String
    let countries: [CountryItem]
    let onToggle: (CountryItem) -> Void
    
    struct CountryItem: Identifiable {
        let id = UUID()
        let flag: String
        let name: String
        let code: String
        var isBlocked: Bool
        var blockedCalls: Int
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(region.lowercased())
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootStone)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ForEach(Array(countries.enumerated()), id: \.element.id) { index, country in
                    CountryPickerRow(
                        flag: country.flag,
                        name: country.name,
                        code: country.code,
                        isBlocked: country.isBlocked,
                        blockedCalls: country.blockedCalls
                    ) {
                        onToggle(country)
                    }
                    
                    if index < countries.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview("Country Picker Components") {
    ScrollView {
        VStack(spacing: 24) {
            CountrySearchHeader(
                searchText: .constant(""),
                blockedCount: 3
            )
            
            GrootText("blocked countries", style: .heading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                BlockedCountryCard(
                    flag: "🇮🇳",
                    name: "India",
                    code: "+91",
                    blockedCalls: 45,
                    blockedSince: Date().addingTimeInterval(-604800),
                    onUnblock: { }
                )
                
                BlockedCountryCard(
                    flag: "🇵🇰",
                    name: "Pakistan",
                    code: "+92",
                    blockedCalls: 12,
                    blockedSince: Date().addingTimeInterval(-1209600),
                    onUnblock: { }
                )
            }
            
            CountryRegionSection(
                region: "North America",
                countries: [
                    .init(flag: "🇺🇸", name: "United States", code: "+1", isBlocked: false, blockedCalls: 0),
                    .init(flag: "🇨🇦", name: "Canada", code: "+1", isBlocked: false, blockedCalls: 0),
                    .init(flag: "🇲🇽", name: "Mexico", code: "+52", isBlocked: true, blockedCalls: 8)
                ]
            ) { _ in }
            
            CountryRegionSection(
                region: "Asia",
                countries: [
                    .init(flag: "🇨🇳", name: "China", code: "+86", isBlocked: true, blockedCalls: 23),
                    .init(flag: "🇯🇵", name: "Japan", code: "+81", isBlocked: false, blockedCalls: 0),
                    .init(flag: "🇰🇷", name: "South Korea", code: "+82", isBlocked: false, blockedCalls: 0)
                ]
            ) { _ in }
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
