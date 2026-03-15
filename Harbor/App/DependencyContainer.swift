import Foundation

/// Centralizes object creation and provides services to ViewModels.
/// Views must never directly instantiate repositories or services.
@Observable
final class DependencyContainer {
    let accountsRepository: IAccountsRepository

    init(accountsRepository: IAccountsRepository = AccountsRepository()) {
        self.accountsRepository = accountsRepository
    }
}
