//
//  BlockedNumberRow.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Cached Formatters (Performance Optimization)

private enum FormatterCache {
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}

// MARK: - Blocked Number Row

struct BlockedNumberRow: View {
    let blockedNumber: BlockedNumber
    let onUnblock: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        GrootSwipeableListItem(
            trailingActions: [
                .init(icon: "checkmark.circle.fill", color: .grootShield) {
                    onUnblock()
                }
            ]
        ) {
            HStack(spacing: 14) {
                reasonIcon
                contentStack
                Spacer()
                trailingContent
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                onViewDetails()
            }
        }
    }
    
    // MARK: - View Components
    
    private var reasonIcon: some View {
        ZStack {
            Circle()
                .fill(reasonColor.opacity(0.15))
                .frame(width: 48, height: 48)
            
            Image(systemName: blockedNumber.reason.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(reasonColor)
        }
    }
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(blockedNumber.label ?? blockedNumber.displayNumber)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootBark)
            
            if blockedNumber.label != nil {
                Text(blockedNumber.displayNumber)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            
            HStack(spacing: 8) {
                ReasonBadge(reason: blockedNumber.reason)
                
                Text("•")
                    .foregroundStyle(Color.grootPebble)
                
                Text(timeAgo)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
        }
    }
    
    private var trailingContent: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if blockedNumber.callCount > 1 {
                HStack(spacing: 4) {
                    Text("\(blockedNumber.callCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color.grootFlame)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.grootPebble)
        }
    }
    
    // MARK: - Computed Properties
    
    private var reasonColor: Color {
        switch blockedNumber.reason {
        case .manual: return .grootFlame
        case .pattern: return .grootViolet
        case .country: return .grootSky
        case .spam: return .grootSun
        }
    }
    
    private var timeAgo: String {
        FormatterCache.relativeDateFormatter.localizedString(for: blockedNumber.blockedAt, relativeTo: Date())
    }
}

// MARK: - Reason Badge

struct ReasonBadge: View {
    let reason: BlockReason
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: reason.icon)
                .font(.system(size: 10, weight: .bold))
            
            Text(reason.rawValue)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var color: Color {
        switch reason {
        case .manual: return .grootFlame
        case .pattern: return .grootViolet
        case .country: return .grootSky
        case .spam: return .grootSun
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        BlockedNumberRow(
            blockedNumber: BlockedNumber(
                phoneNumber: "+15551234567",
                reason: .spam,
                label: "Spam Caller"
            ),
            onUnblock: { },
            onViewDetails: { }
        )
        
        Divider().padding(.leading, 78)
        
        BlockedNumberRow(
            blockedNumber: BlockedNumber(
                phoneNumber: "+919876543210",
                reason: .country
            ),
            onUnblock: { },
            onViewDetails: { }
        )
    }
    .background(Color.grootSnow)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color.grootCloud)
}
