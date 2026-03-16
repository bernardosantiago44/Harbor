import SwiftUI

/// Placeholder detail screen for a single account.
/// Will be expanded with full account details in a future iteration.
struct AccountDetailView: View {
    let accountId: UUID

    var body: some View {
        Text("Account Detail")
            .font(Typography.title)
            .foregroundStyle(ColorTokens.labelPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ColorTokens.backgroundPrimary)
            .navigationTitle("Account")
    }
}

#Preview {
    NavigationStack {
        AccountDetailView(accountId: UUID())
    }
}
