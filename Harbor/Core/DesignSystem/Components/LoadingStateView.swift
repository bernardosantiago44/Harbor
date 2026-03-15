import SwiftUI

/// Reusable full-screen loading indicator.
struct LoadingStateView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .controlSize(.regular)
            Text(message)
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.labelSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview {
    LoadingStateView()
}
