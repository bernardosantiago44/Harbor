import Foundation

/// Input required to create or update an account.
struct SaveAccountInput: Sendable, Equatable {
    let name: String
    let type: AccountType
    let currency: String
    let isTracked: Bool
    let metadata: [String: String]
}
