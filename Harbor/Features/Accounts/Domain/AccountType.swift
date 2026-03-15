import Foundation

/// Classification of financial accounts.
enum AccountType: String, Codable, CaseIterable, Sendable {
    case cash
    case bank
    case creditCard
    case loan
    case insurance
    case general

    /// Human-readable name for display in the UI.
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .bank: return "Bank"
        case .creditCard: return "Credit Card"
        case .loan: return "Loan"
        case .insurance: return "Insurance"
        case .general: return "General"
        }
    }
}
