//
//  CallDirectoryStatusCard.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Call Directory Status Card

struct CallDirectoryStatusCard: View {
    let status: CallBlockingService.ExtensionStatus
    let isSyncing: Bool
    let onOpenSettings: () -> Void
    let onSync: () -> Void
    
    var body: some View {
        GrootCard(padding: 16) {
            HStack(spacing: 14) {
                statusIcon
                statusInfo
                Spacer()
                actionButton
            }
        }
    }
    
    // MARK: - View Components
    
    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 48, height: 48)
            
            Image(systemName: statusIconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(statusColor)
        }
    }
    
    private var statusInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("call blocking")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootBark)
            
            Text(status.statusMessage.lowercased())
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(statusColor)
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if status.isEnabled {
            Button {
                onSync()
            } label: {
                if isSyncing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.grootSky)
                }
            }
            .disabled(isSyncing)
        } else {
            Button {
                onOpenSettings()
            } label: {
                Text("enable")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.grootShield)
                    .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch status {
        case .enabled: return .grootShield
        case .disabled: return .grootSun
        case .error: return .grootFlame
        case .unknown: return .grootStone
        }
    }
    
    private var statusIconName: String {
        switch status {
        case .enabled: return "checkmark.shield.fill"
        case .disabled: return "shield.slash"
        case .error: return "exclamationmark.shield"
        case .unknown: return "shield"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        CallDirectoryStatusCard(
            status: .enabled,
            isSyncing: false,
            onOpenSettings: { },
            onSync: { }
        )
        
        CallDirectoryStatusCard(
            status: .disabled,
            isSyncing: false,
            onOpenSettings: { },
            onSync: { }
        )
        
        CallDirectoryStatusCard(
            status: .enabled,
            isSyncing: true,
            onOpenSettings: { },
            onSync: { }
        )
    }
    .padding()
    .background(Color.grootCloud)
}
