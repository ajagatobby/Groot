import SwiftUI

// MARK: - Progress Ring

struct GrootProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let trackColor: Color
    let showPercentage: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        size: CGFloat = 80,
        lineWidth: CGFloat = 8,
        color: Color = .grootShield,
        trackColor: Color = .grootMist,
        showPercentage: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.trackColor = trackColor
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Progress Bar

struct GrootProgressBar: View {
    let progress: Double
    let height: CGFloat
    let color: Color
    let trackColor: Color
    let showLabel: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        height: CGFloat = 10,
        color: Color = .grootShield,
        trackColor: Color = .grootMist,
        showLabel: Bool = false
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.color = color
        self.trackColor = trackColor
        self.showLabel = showLabel
    }
    
    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(trackColor)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * animatedProgress)
                }
            }
            .frame(height: height)
            
            if showLabel {
                HStack {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Milestone Progress

struct GrootMilestoneProgress: View {
    let current: Int
    let milestones: [Int]
    let color: Color
    
    init(
        current: Int,
        milestones: [Int] = [10, 50, 100, 500, 1000],
        color: Color = .grootShield
    ) {
        self.current = current
        self.milestones = milestones
        self.color = color
    }
    
    private var nextMilestone: Int {
        milestones.first { $0 > current } ?? milestones.last ?? 100
    }
    
    private var previousMilestone: Int {
        milestones.last { $0 <= current } ?? 0
    }
    
    private var progress: Double {
        let range = Double(nextMilestone - previousMilestone)
        let currentProgress = Double(current - previousMilestone)
        return range > 0 ? currentProgress / range : 1.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(current)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                
                Spacer()
                
                Text("next: \(nextMilestone)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            
            GrootProgressBar(progress: progress, color: color)
            
            HStack {
                ForEach(milestones, id: \.self) { milestone in
                    if milestone <= nextMilestone {
                        MilestoneMarker(
                            value: milestone,
                            isReached: current >= milestone,
                            color: color
                        )
                        
                        if milestone != milestones.last && milestone < nextMilestone {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Milestone Marker

private struct MilestoneMarker: View {
    let value: Int
    let isReached: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isReached ? color : Color.grootMist)
                    .frame(width: 24, height: 24)
                
                if isReached {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            
            Text("\(value)")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(isReached ? color : Color.grootPebble)
        }
    }
}

// MARK: - Activity Indicator

struct GrootActivityIndicator: View {
    let color: Color
    let size: CGFloat
    
    @State private var isAnimating = false
    
    init(color: Color = .grootShield, size: CGFloat = 24) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Preview

#Preview("Groot Progress") {
    ScrollView {
        VStack(spacing: 32) {
            GrootText("progress rings", style: .heading)
            
            HStack(spacing: 24) {
                GrootProgressRing(progress: 0.75, size: 80, color: .grootShield)
                GrootProgressRing(progress: 0.45, size: 80, color: .grootSky)
                GrootProgressRing(progress: 0.90, size: 80, color: .grootFlame)
            }
            
            GrootText("progress bars", style: .heading)
            
            VStack(spacing: 16) {
                GrootProgressBar(progress: 0.65, color: .grootShield, showLabel: true)
                GrootProgressBar(progress: 0.30, color: .grootSky)
                GrootProgressBar(progress: 0.85, color: .grootFlame)
            }
            
            GrootText("milestone progress", style: .heading)
            
            GrootMilestoneProgress(current: 73, milestones: [10, 50, 100, 250, 500])
                .padding(16)
                .background(Color.grootSnow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            GrootText("activity indicator", style: .heading)
            
            HStack(spacing: 24) {
                GrootActivityIndicator(color: .grootShield)
                GrootActivityIndicator(color: .grootSky, size: 32)
                GrootActivityIndicator(color: .grootFlame, size: 40)
            }
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
