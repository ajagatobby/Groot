import SwiftUI

// MARK: - Whitelist Contact Row

struct WhitelistContactRow: View {
    let name: String
    let phoneNumber: String
    let contactImage: Image?
    let addedDate: Date
    let callsAllowed: Int
    let onRemove: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        GrootSwipeableListItem(
            trailingActions: [
                .init(icon: "trash.fill", color: .grootFlame) {
                    onRemove()
                }
            ]
        ) {
            HStack(spacing: 14) {
                ContactAvatar(name: name, image: contactImage)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text(phoneNumber)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                    
                    if callsAllowed > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("\(callsAllowed) calls allowed")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color.grootShield)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.grootShield)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.grootPebble)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                onViewDetails()
            }
        }
    }
}

// MARK: - Contact Avatar

struct ContactAvatar: View {
    let name: String
    let image: Image?
    let size: CGFloat
    
    init(name: String, image: Image? = nil, size: CGFloat = 48) {
        self.name = name
        self.image = image
        self.size = size
    }
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(avatarColor)
                    .frame(width: size, height: size)
                
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            Circle()
                .stroke(Color.grootShield, lineWidth: 2)
                .frame(width: size, height: size)
        }
    }
    
    private var initials: String {
        let components = name.components(separatedBy: " ")
        let first = components.first?.prefix(1) ?? ""
        let last = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
    
    private var avatarColor: Color {
        let colors: [Color] = [.grootShield, .grootSky, .grootViolet, .grootAmber, .grootFlame]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - Add Contact Card

struct AddWhitelistContactCard: View {
    let onAddFromContacts: () -> Void
    let onAddManually: () -> Void
    
    var body: some View {
        GrootCard(padding: 20) {
            VStack(spacing: 16) {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.grootShield)
                
                VStack(spacing: 4) {
                    Text("add trusted contacts")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text("these contacts will always get through")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    GrootButton(
                        "from contacts",
                        variant: .primary,
                        icon: "person.crop.circle.badge.plus"
                    ) {
                        onAddFromContacts()
                    }
                    
                    GrootButton(
                        "enter manually",
                        variant: .secondary,
                        icon: "keyboard"
                    ) {
                        onAddManually()
                    }
                }
            }
        }
    }
}

// MARK: - Whitelist Stats

struct WhitelistStatsRow: View {
    let totalContacts: Int
    let callsAllowed: Int
    
    var body: some View {
        HStack(spacing: 16) {
            StatBadge(
                value: "\(totalContacts)",
                label: "contacts",
                icon: "person.2.fill",
                color: .grootShield
            )
            
            StatBadge(
                value: "\(callsAllowed)",
                label: "allowed",
                icon: "phone.arrow.down.left.fill",
                color: .grootSky
            )
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                Text(label.lowercased())
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview("Whitelist Components") {
    ScrollView {
        VStack(spacing: 24) {
            WhitelistStatsRow(totalContacts: 42, callsAllowed: 156)
            
            AddWhitelistContactCard(
                onAddFromContacts: { },
                onAddManually: { }
            )
            
            GrootText("trusted contacts", style: .heading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                WhitelistContactRow(
                    name: "Mom",
                    phoneNumber: "+1 (555) 123-4567",
                    contactImage: nil,
                    addedDate: Date(),
                    callsAllowed: 23,
                    onRemove: { },
                    onViewDetails: { }
                )
                
                Divider().padding(.leading, 78)
                
                WhitelistContactRow(
                    name: "John Smith",
                    phoneNumber: "+1 (555) 987-6543",
                    contactImage: nil,
                    addedDate: Date(),
                    callsAllowed: 5,
                    onRemove: { },
                    onViewDetails: { }
                )
                
                Divider().padding(.leading, 78)
                
                WhitelistContactRow(
                    name: "Work Office",
                    phoneNumber: "+1 (800) 555-0100",
                    contactImage: nil,
                    addedDate: Date(),
                    callsAllowed: 0,
                    onRemove: { },
                    onViewDetails: { }
                )
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
