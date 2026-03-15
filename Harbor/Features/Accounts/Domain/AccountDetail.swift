import Foundation

/// Full account representation used in detail and edit screens.
struct AccountDetail: Identifiable, Sendable, Equatable {
    let id: UUID
    let name: String
    let type: AccountType
    let currency: String
    let balance: Int64
    let isTracked: Bool
    let metadata: [String: String]
}
