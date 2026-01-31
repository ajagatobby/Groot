//
//  BlockedStatsCard.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Blocked Stats Card

struct BlockedStatsCard: View {
    let totalBlocked: Int
    let blockedToday: Int
    let blockedThisWeek: Int
    let topBlockedCountry: String?
    
    @State private var animatedTotal: Int = 0
    @State private var showDetails = false
    
    var body: some View {
        GrootCard(padding: 20) {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.grootShield)
                            
                            Text("protected")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.grootShield)
                        }
                        
                        Text("\(animatedTotal)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.grootBark)
                            .contentTransition(.numericText())
                        
                        Text("calls blocked")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                    
                    Spacer()
                    
                    ShieldAnimation()
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    StatItem(
                        value: "\(blockedToday)",
                        label: "today",
                        color: .grootFlame
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    StatItem(
                        value: "\(blockedThisWeek)",
                        label: "this week",
                        color: .grootSky
                    )
                    
                    if let country = topBlockedCountry {
                        Divider()
                            .frame(height: 40)
                        
                        StatItem(
                            value: country,
                            label: "top source",
                            color: .grootViolet
                        )
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedTotal = totalBlocked
            }
        }
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(label.lowercased())
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootStone)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shield Animation

private struct ShieldAnimation: View {
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.grootShield.opacity(0.1))
                .frame(width: 80, height: 80)
                .scaleEffect(pulseScale)
            
            Circle()
                .fill(Color.grootShield.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.grootShield)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
                pulseScale = 1.1
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        BlockedStatsCard(
            totalBlocked: 127,
            blockedToday: 5,
            blockedThisWeek: 23,
            topBlockedCountry: "🇮🇳"
        )
        
        BlockedStatsCard(
            totalBlocked: 0,
            blockedToday: 0,
            blockedThisWeek: 0,
            topBlockedCountry: nil
        )
    }
    .padding(20)
    .background(Color.grootCloud)
}
