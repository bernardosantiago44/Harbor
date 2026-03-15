import Foundation

/// Persistence representation of an account, mapped from the backend.
struct AccountDTO: Codable, Sendable {
    let id: UUID
    let name: String
    let type: String
    let currency: String
    let balance: Int64
    let isTracked: Bool
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case currency
        case balance
        case isTracked = "is_tracked"
        case metadata
    }
}
