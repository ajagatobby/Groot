import SwiftUI

// MARK: - Groot Empty State

struct GrootEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    @State private var isAnimating = false
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.grootCloud)
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color.grootPebble)
            }
            
            VStack(spacing: 8) {
                Text(title.lowercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            
            if let actionTitle, let action {
                GrootButton(actionTitle, variant: .primary, isFullWidth: false) {
                    action()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Empty State Presets

extension GrootEmptyState {
    
    static func noBlockedNumbers(action: @escaping () -> Void) -> GrootEmptyState {
        GrootEmptyState(
            icon: "hand.raised.slash",
            title: "no blocked numbers",
            message: "Numbers you block will appear here. Add a number to get started.",
            actionTitle: "block a number",
            action: action
        )
    }
    
    static func noWhitelistContacts(action: @escaping () -> Void) -> GrootEmptyState {
        GrootEmptyState(
            icon: "person.badge.shield.checkmark",
            title: "no trusted contacts",
            message: "Add contacts to your whitelist to ensure their calls always get through.",
            actionTitle: "add contact",
            action: action
        )
    }
    
    static func noBlockedCountries(action: @escaping () -> Void) -> GrootEmptyState {
        GrootEmptyState(
            icon: "globe",
            title: "no countries blocked",
            message: "Block entire countries to stop international spam calls.",
            actionTitle: "block a country",
            action: action
        )
    }
    
    static func noPatterns(action: @escaping () -> Void) -> GrootEmptyState {
        GrootEmptyState(
            icon: "number",
            title: "no patterns set",
            message: "Create patterns to automatically block numbers matching certain criteria.",
            actionTitle: "create pattern",
            action: action
        )
    }
    
    static func noRecentCalls() -> GrootEmptyState {
        GrootEmptyState(
            icon: "phone.badge.checkmark",
            title: "all clear!",
            message: "No spam calls blocked recently. Groot is keeping your phone safe.",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func searchNoResults(query: String) -> GrootEmptyState {
        GrootEmptyState(
            icon: "magnifyingglass",
            title: "no results",
            message: "We couldn't find anything matching \"\(query)\". Try a different search.",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func callKitNotEnabled(action: @escaping () -> Void) -> GrootEmptyState {
        GrootEmptyState(
            icon: "exclamationmark.shield",
            title: "call blocking disabled",
            message: "Enable Groot in Settings → Phone → Call Blocking & Identification to start blocking spam calls.",
            actionTitle: "open settings",
            action: action
        )
    }
}

// MARK: - Loading State

struct GrootLoadingState: View {
    let message: String
    
    init(_ message: String = "loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            GrootActivityIndicator(size: 40)
            
            Text(message.lowercased())
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootStone)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Error State

struct GrootErrorState: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    init(
        title: String = "something went wrong",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.grootErrorBg)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.grootFlame)
            }
            
            VStack(spacing: 8) {
                Text(title.lowercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            if let retryAction {
                GrootButton("try again", variant: .danger, isFullWidth: false) {
                    retryAction()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// MARK: - Preview

#Preview("Groot Empty States") {
    ScrollView {
        VStack(spacing: 32) {
            GrootText("empty states", style: .heading)
            
            GrootEmptyState.noBlockedNumbers { }
            
            Divider()
            
            GrootEmptyState.noWhitelistContacts { }
            
            Divider()
            
            GrootEmptyState.noRecentCalls()
            
            Divider()
            
            GrootEmptyState.searchNoResults(query: "john")
            
            GrootText("loading state", style: .heading)
            
            GrootLoadingState("syncing block list...")
            
            GrootText("error state", style: .heading)
            
            GrootErrorState(
                message: "We couldn't load your blocked numbers. Please check your connection and try again.",
                retryAction: { }
            )
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
