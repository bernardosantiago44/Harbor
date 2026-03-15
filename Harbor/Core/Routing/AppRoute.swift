import Foundation

/// All navigable destinations in the app.
enum AppRoute: Hashable {
    case accounts
    case accountDetail(id: UUID)
    case createAccount
    case editAccount(id: UUID)
}
