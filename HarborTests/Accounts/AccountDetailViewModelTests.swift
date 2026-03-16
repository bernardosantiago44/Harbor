import Testing
import Foundation
@testable import Harbor

@MainActor
struct AccountDetailViewModelTests {

    // MARK: - Helpers

    private final class StubAccountsRepository: IAccountsRepository {
        var detailToReturn: AccountDetail?
        var errorToThrow: Error?

        func getAccounts() async throws -> [AccountSummary] { [] }

        func getAccountDetail(id: UUID) async throws -> AccountDetail {
            if let error = errorToThrow { throw error }
            return detailToReturn ?? AccountDetail(
                id: id, name: "", type: .general, currency: "USD",
                balance: 0, isTracked: true, metadata: [:]
            )
        }

        func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
            fatalError("Not expected in detail tests")
        }

        func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
            fatalError("Not expected in detail tests")
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
        let vm = AccountDetailViewModel(accountId: UUID(), repository: repo)
        #expect(vm.state == .loading)
    }

    @Test("loadAccount transitions to loaded state with account detail")
    func loadAccountSuccess() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Checking", type: .bank, currency: "USD",
            balance: 1_250_00, isTracked: true, metadata: ["institution": "Chase"]
        )

        let vm = AccountDetailViewModel(accountId: id, repository: repo)
        await vm.loadAccount()

        guard case .loaded(let detail) = vm.state else {
            Issue.record("Expected loaded state, got \(vm.state)")
            return
        }
        #expect(detail.id == id)
        #expect(detail.name == "Checking")
        #expect(detail.type == .bank)
        #expect(detail.currency == "USD")
        #expect(detail.balance == 1_250_00)
        #expect(detail.isTracked == true)
        #expect(detail.metadata == ["institution": "Chase"])
    }

    @Test("loadAccount transitions to error state on failure")
    func loadAccountError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountDetailViewModel(accountId: UUID(), repository: repo)
        await vm.loadAccount()

        guard case .error(let displayableError) = vm.state else {
            Issue.record("Expected error state, got \(vm.state)")
            return
        }
        #expect(displayableError.message == "Network request failed")
    }

    @Test("loadAccount sets currentError on failure")
    func loadAccountSetsCurrentError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountDetailViewModel(accountId: UUID(), repository: repo)
        await vm.loadAccount()

        #expect(vm.currentError != nil)
        #expect(vm.currentError?.message == "Network request failed")
    }

    @Test("loadAccount clears previous error on retry success")
    func loadAccountClearsErrorOnRetry() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.networkFailure

        let vm = AccountDetailViewModel(accountId: id, repository: repo)
        await vm.loadAccount()

        guard case .error = vm.state else {
            Issue.record("Expected error state first")
            return
        }

        repo.errorToThrow = nil
        repo.detailToReturn = AccountDetail(
            id: id, name: "Savings", type: .bank, currency: "USD",
            balance: 5_000_00, isTracked: true, metadata: [:]
        )

        await vm.loadAccount()

        guard case .loaded(let detail) = vm.state else {
            Issue.record("Expected loaded state after retry, got \(vm.state)")
            return
        }
        #expect(detail.name == "Savings")
        #expect(vm.currentError == nil)
    }

    @Test("accountId is stored correctly")
    func accountIdIsStored() {
        let id = UUID()
        let repo = StubAccountsRepository()
        let vm = AccountDetailViewModel(accountId: id, repository: repo)
        #expect(vm.accountId == id)
    }
}
