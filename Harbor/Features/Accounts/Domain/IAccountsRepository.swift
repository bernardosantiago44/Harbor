import Foundation

/// Abstraction for account persistence operations.
protocol IAccountsRepository: Sendable {
    func getAccounts() async throws -> [AccountSummary]
    func getAccountDetail(id: UUID) async throws -> AccountDetail
    func createAccount(input: SaveAccountInput) async throws -> AccountDetail
    func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail
}
