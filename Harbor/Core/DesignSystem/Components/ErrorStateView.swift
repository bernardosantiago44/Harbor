import SwiftUI

/// Reusable error state with a retry callback.
struct ErrorStateView: View {
    let message: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(ColorTokens.negative)

            Text("Something went wrong")
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.labelPrimary)

            Text(message)
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.labelSecondary)
                .multilineTextAlignment(.center)

            if let onRetry {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview {
    ErrorStateView(message: "Could not load data.") {
        print("Retry tapped")
    }
}
