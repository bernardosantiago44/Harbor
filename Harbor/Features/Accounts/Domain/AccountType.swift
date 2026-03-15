import Foundation

/// Classification of financial accounts.
enum AccountType: String, Codable, CaseIterable, Sendable {
    case cash
    case bank
    case creditCard
    case loan
    case insurance
    case general
}
