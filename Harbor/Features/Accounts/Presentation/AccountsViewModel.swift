import Foundation
import Logging

/// Possible states of the Accounts screen.
enum AccountsScreenState: Sendable, Equatable {
    case loading
    case loaded([AccountSummary])
    case empty
    case error(DisplayableError)
}

/// Drives the Accounts list screen: fetches accounts, manages screen state,
/// and exposes navigation intents for the view layer.
@Observable
@MainActor
final class AccountsViewModel: ErrorHandling {
    let logger = Logger(label: "com.harbor.accounts")

    private let repository: IAccountsRepository

    private(set) var state: AccountsScreenState = .loading
    var currentError: DisplayableError?

    init(repository: IAccountsRepository) {
        self.repository = repository
    }

    /// Loads accounts from the repository and transitions to the appropriate state.
    func loadAccounts() async {
        state = .loading
        clearError()

        do {
            let accounts = try await repository.getAccounts()
            state = accounts.isEmpty ? .empty : .loaded(accounts)
        } catch {
            displayError(error, context: "AccountsViewModel.loadAccounts")
            state = .error(currentError ?? DisplayableError(message: "An unexpected error occurred."))
        }
    }
}
