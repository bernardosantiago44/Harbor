import Testing
import Foundation
@testable import Harbor

@MainActor
struct AccountsViewModelTests {

    // MARK: - Helpers

    /// A controllable in-memory repository for testing.
    private final class StubAccountsRepository: IAccountsRepository {
        var accountsToReturn: [AccountSummary] = []
        var errorToThrow: Error?

        func getAccounts() async throws -> [AccountSummary] {
            if let error = errorToThrow { throw error }
            return accountsToReturn
        }

        func getAccountDetail(id: UUID) async throws -> AccountDetail {
            AccountDetail(id: id, name: "", type: .general, currency: "USD", balance: 0, isTracked: true, metadata: [:])
        }

        func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
            AccountDetail(id: UUID(), name: input.name, type: input.type, currency: input.currency, balance: 0, isTracked: input.isTracked, metadata: input.metadata)
        }

        func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
            AccountDetail(id: id, name: input.name, type: input.type, currency: input.currency, balance: 0, isTracked: input.isTracked, metadata: input.metadata)
        }
    }

    private enum TestError: Error, LocalizedError {
        case networkFailure

        var errorDescription: String? { "Network request failed" }
    }

    // MARK: - Tests

    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let repo = StubAccountsRepository()
        let vm = AccountsViewModel(repository: repo)
        #expect(vm.state == .loading)
    }

    @Test("loadAccounts transitions to loaded state with accounts")
    func loadAccountsSuccess() async {
        let repo = StubAccountsRepository()
        repo.accountsToReturn = [
            AccountSummary(id: UUID(), name: "Checking", type: .bank, currency: "USD", balance: 100_00, isTracked: true),
            AccountSummary(id: UUID(), name: "Cash", type: .cash, currency: "USD", balance: 50_00, isTracked: true),
        ]

        let vm = AccountsViewModel(repository: repo)
        await vm.loadAccounts()

        guard case .loaded(let accounts) = vm.state else {
            Issue.record("Expected loaded state, got \(vm.state)")
            return
        }
        #expect(accounts.count == 2)
        #expect(accounts[0].name == "Checking")
        #expect(accounts[1].name == "Cash")
    }

    @Test("loadAccounts transitions to empty state when no accounts")
    func loadAccountsEmpty() async {
        let repo = StubAccountsRepository()
        repo.accountsToReturn = []

        let vm = AccountsViewModel(repository: repo)
        await vm.loadAccounts()

        #expect(vm.state == .empty)
    }

    @Test("loadAccounts transitions to error state on failure")
    func loadAccountsError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountsViewModel(repository: repo)
        await vm.loadAccounts()

        guard case .error(let displayableError) = vm.state else {
            Issue.record("Expected error state, got \(vm.state)")
            return
        }
        #expect(displayableError.message == "Network request failed")
    }

    @Test("loadAccounts sets currentError on failure")
    func loadAccountsSetsCurrentError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountsViewModel(repository: repo)
        await vm.loadAccounts()

        #expect(vm.currentError != nil)
        #expect(vm.currentError?.message == "Network request failed")
    }

    @Test("loadAccounts clears previous error on retry success")
    func loadAccountsClearsErrorOnRetry() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountsViewModel(repository: repo)
        await vm.loadAccounts()

        // Verify error state first
        guard case .error = vm.state else {
            Issue.record("Expected error state first")
            return
        }

        // Now succeed on retry
        repo.errorToThrow = nil
        repo.accountsToReturn = [
            AccountSummary(id: UUID(), name: "Savings", type: .bank, currency: "USD", balance: 300_00, isTracked: true),
        ]

        await vm.loadAccounts()

        guard case .loaded(let accounts) = vm.state else {
            Issue.record("Expected loaded state after retry, got \(vm.state)")
            return
        }
        #expect(accounts.count == 1)
        #expect(vm.currentError == nil)
    }
}
