import Foundation

/// Centralizes object creation and provides services to ViewModels.
/// Views must never directly instantiate repositories or services.
@Observable
final class DependencyContainer {
    // Repositories and services will be registered here as features are developed.
    // Example: let accountRepository: AccountRepositoryProtocol = AccountRepository()
}
