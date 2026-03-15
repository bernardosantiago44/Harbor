import SwiftUI

/// Main Accounts screen displaying all user accounts in a 2-row horizontal paging grid.
struct AccountsView: View {
    @Environment(AppRouter.self) private var router
    let viewModel: AccountsViewModel

    private let rows = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
    ]

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingStateView(message: "Loading accounts…")

            case .loaded(let accounts):
                accountsGrid(accounts)

            case .empty:
                EmptyStateView(
                    icon: "tray",
                    title: "No accounts yet",
                    message: "Add your first account to start tracking your finances."
                )

            case .error(let displayableError):
                ErrorStateView(message: displayableError.message) {
                    Task { await viewModel.loadAccounts() }
                }
            }
        }
        .navigationTitle("Accounts")
        .task { await viewModel.loadAccounts() }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func accountsGrid(_ accounts: [AccountSummary]) -> some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: Spacing.sm) {
                ForEach(accounts) { account in
                    AccountCardView(account: account)
                        .containerRelativeFrame(
                            .horizontal,
                            count: 2,
                            spacing: Spacing.sm
                        )
                        .onTapGesture {
                            router.navigate(to: .accountDetail(id: account.id))
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack {
        AccountsView(viewModel: AccountsViewModel(
            repository: PreviewAccountsRepository()
        ))
    }
    .environment(router)
}

// MARK: - Preview Helpers

/// An in-memory repository used only for SwiftUI previews.
private struct PreviewAccountsRepository: IAccountsRepository {
    func getAccounts() async throws -> [AccountSummary] {
        [
            AccountSummary(id: UUID(), name: "Checking", type: .bank, currency: "USD", balance: 1_250_00, isTracked: true),
            AccountSummary(id: UUID(), name: "Savings", type: .bank, currency: "USD", balance: 5_000_00, isTracked: true),
            AccountSummary(id: UUID(), name: "Cash", type: .cash, currency: "USD", balance: 200_00, isTracked: true),
            AccountSummary(id: UUID(), name: "Visa", type: .creditCard, currency: "USD", balance: -450_00, isTracked: true),
            AccountSummary(id: UUID(), name: "Home Loan", type: .loan, currency: "USD", balance: -150_000_00, isTracked: false),
        ]
    }

    func getAccountDetail(id: UUID) async throws -> AccountDetail {
        AccountDetail(id: id, name: "Preview", type: .general, currency: "USD", balance: 0, isTracked: true, metadata: [:])
    }

    func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
        AccountDetail(id: UUID(), name: input.name, type: input.type, currency: input.currency, balance: 0, isTracked: input.isTracked, metadata: input.metadata)
    }

    func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
        AccountDetail(id: id, name: input.name, type: input.type, currency: input.currency, balance: 0, isTracked: input.isTracked, metadata: input.metadata)
    }
}
