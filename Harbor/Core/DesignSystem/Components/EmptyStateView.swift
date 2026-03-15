import SwiftUI

/// Reusable empty state with an icon, title, and optional message.
struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(ColorTokens.labelTertiary)

            Text(title)
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.labelPrimary)

            if let message {
                Text(message)
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.labelSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview {
    EmptyStateView(
        icon: "tray",
        title: "Nothing here yet",
        message: "Add your first item to get started."
    )
}
