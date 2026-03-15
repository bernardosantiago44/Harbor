import Foundation

/// Lightweight account representation used in list views.
struct AccountSummary: Identifiable, Sendable, Equatable {
    let id: UUID
    let name: String
    let type: AccountType
    let currency: String
    let balance: Int64
    let isTracked: Bool
}
