import SwiftUI

/// A card displaying an account's name, balance, type, and tracking status.
/// Used inside the accounts grid on the main Accounts screen.
struct AccountCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let account: AccountSummary
    
    var internalPadding: CGFloat {
        return dynamicTypeSize < .xxLarge ? Spacing.sm : Spacing.md
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)

                Spacer()

                if !account.isTracked {
                    Text("Untracked")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.labelTertiary)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(ColorTokens.neutral.opacity(0.15))
                        )
                }
            }

            Text(account.name)
                .font(Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ColorTokens.labelPrimary)
                .lineLimit(1)

            Text(formattedBalance)
                .font(Typography.headline)
                .foregroundStyle(balanceColor)
                .lineLimit(1)
        }
        .padding(internalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(ColorTokens.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    // MARK: - Computed Helpers

    private var formattedBalance: String {
        MoneyFormatter.format(amount: account.balance, currency: account.currency)
    }

    private var balanceColor: Color {
        if account.balance > 0 { return ColorTokens.positive }
        if account.balance < 0 { return ColorTokens.negative }
        return ColorTokens.labelSecondary
    }

    private var iconName: String {
        switch account.type {
        case .cash: return "banknote"
        case .bank: return "building.columns"
        case .creditCard: return "creditcard"
        case .loan: return "signature"
        case .insurance: return "shield"
        case .general: return "folder"
        }
    }

    private var iconColor: Color {
        switch account.type {
        case .cash: return ColorTokens.positive
        case .bank: return ColorTokens.accent
        case .creditCard: return ColorTokens.warning
        case .loan: return ColorTokens.negative
        case .insurance: return ColorTokens.neutral
        case .general: return ColorTokens.labelSecondary
        }
    }
}

#Preview {
    AccountCardView(account: AccountSummary(
        id: UUID(),
        name: "Checking Account",
        type: .bank,
        currency: "USD",
        balance: 245_00,
        isTracked: false
    ))
//    .frame(width: 180, height: 160)
    .padding()
}

#Preview("Accounts List") {
    @Previewable @State var router = AppRouter()

    NavigationStack {
        AccountsView(viewModel: AccountsViewModel(
            repository: PreviewAccountsRepository()
        ))
    }
    .environment(router)
}
