import Foundation
import Supabase

/// Supabase-backed implementation of ``AccountsRepository``.
final class AccountsRepository: IAccountsRepository {

    private let client: SupabaseClient
    private let table = "accounts"

    init(client: SupabaseClient = SupabaseInstance.shared.supabase) {
        self.client = client
    }

    func getAccounts() async throws -> [AccountSummary] {
        let dtos: [AccountDTO] = try await client
            .from(table)
            .select()
            .execute()
            .value
        return dtos.map(AccountMapper.toSummary)
    }

    func getAccountDetail(id: UUID) async throws -> AccountDetail {
        let dto: AccountDTO = try await client
            .from(table)
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return AccountMapper.toDetail(dto)
    }

    func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
        let newId = UUID()
        let dto = AccountMapper.toDTO(id: newId, balance: 0, input: input)
        let created: AccountDTO = try await client
            .from(table)
            .insert(dto)
            .select()
            .single()
            .execute()
            .value
        return AccountMapper.toDetail(created)
    }

    func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
        let current: AccountDTO = try await client
            .from(table)
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        let dto = AccountMapper.toDTO(id: id, balance: current.balance, input: input)
        let updated: AccountDTO = try await client
            .from(table)
            .update(dto)
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return AccountMapper.toDetail(updated)
    }
}
