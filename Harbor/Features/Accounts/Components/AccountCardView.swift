import SwiftUI

/// A card displaying an account's name, balance, type, and tracking status.
/// Used inside the accounts grid on the main Accounts screen.
struct AccountCardView: View {
    let account: AccountSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
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

            Spacer()

            Text(account.name)
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.labelPrimary)
                .lineLimit(1)

            Text(formattedBalance)
                .font(Typography.title3)
                .foregroundStyle(balanceColor)
                .lineLimit(1)

            Text(account.type.displayName)
                .font(Typography.caption)
                .foregroundStyle(ColorTokens.labelSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
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
        isTracked: true
    ))
    .frame(width: 180, height: 160)
    .padding()
}
