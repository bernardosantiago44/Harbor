import Foundation
import Logging

/// Possible states of the Account Detail screen.
enum AccountDetailScreenState: Sendable, Equatable {
    case loading
    case loaded(AccountDetail)
    case error(DisplayableError)
}

/// Drives the Account Detail screen: fetches account details, manages screen state,
/// and exposes navigation intents for edit.
@Observable
@MainActor
final class AccountDetailViewModel: ErrorHandling {
    let logger = Logger(label: "com.harbor.accountDetail")

    private let repository: IAccountsRepository
    let accountId: UUID

    private(set) var state: AccountDetailScreenState = .loading
    var currentError: DisplayableError?

    init(accountId: UUID, repository: IAccountsRepository) {
        self.accountId = accountId
        self.repository = repository
    }

    /// Loads account detail from the repository.
    func loadAccount() async {
        state = .loading
        clearError()

        do {
            let detail = try await repository.getAccountDetail(id: accountId)
            state = .loaded(detail)
        } catch {
            displayError(error, context: "AccountDetailViewModel.loadAccount")
            state = .error(currentError ?? DisplayableError(message: "An unexpected error occurred."))
        }
    }
}
