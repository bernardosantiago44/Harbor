import SwiftUI

/// Detail screen for a single account displaying all account information.
struct AccountDetailView: View {
    @Environment(AppRouter.self) private var router
    let viewModel: AccountDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingStateView(message: "Loading account…")

            case .loaded(let account):
                accountContent(account)

            case .error(let displayableError):
                ErrorStateView(message: displayableError.message) {
                    Task { await viewModel.loadAccount() }
                }
            }
        }
        .navigationTitle("Account")
        .toolbar {
            if case .loaded = viewModel.state {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        router.navigate(to: .editAccount(id: viewModel.accountId))
                    }
                }
            }
        }
        .task { await viewModel.loadAccount() }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func accountContent(_ account: AccountDetail) -> some View {
        List {
            Section {
                detailRow(label: "Name", value: account.name)
                detailRow(label: "Type", value: account.type.displayName)
                detailRow(
                    label: "Balance",
                    value: MoneyFormatter.format(amount: account.balance, currency: account.currency)
                )
                detailRow(label: "Currency", value: account.currency)
                detailRow(label: "Status", value: account.isTracked ? "Tracked" : "Untracked")
            }

            if !account.metadata.isEmpty {
                Section {
                    ForEach(account.metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        detailRow(label: metadataDisplayLabel(key), value: value)
                    }
                } header: {
                    Text("Details")
                }
            }
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(ColorTokens.labelSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(ColorTokens.labelPrimary)
        }
    }

    /// Converts a camelCase metadata key into a human-readable label.
    private func metadataDisplayLabel(_ key: String) -> String {
        key.replacingOccurrences(
            of: "([a-z])([A-Z])",
            with: "$1 $2",
            options: .regularExpression
        ).capitalized
    }
}

#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack {
        AccountDetailView(
            viewModel: AccountDetailViewModel(
                accountId: UUID(),
                repository: PreviewAccountsRepository()
            )
        )
    }
    .environment(router)
}
