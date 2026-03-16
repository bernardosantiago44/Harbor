import Testing
import Foundation
@testable import Harbor

@MainActor
struct EditAccountViewModelTests {

    // MARK: - Helpers

    private final class StubAccountsRepository: IAccountsRepository {
        var detailToReturn: AccountDetail?
        var updatedInput: SaveAccountInput?
        var getDetailError: Error?
        var updateError: Error?

        func getAccounts() async throws -> [AccountSummary] { [] }

        func getAccountDetail(id: UUID) async throws -> AccountDetail {
            if let error = getDetailError { throw error }
            return detailToReturn ?? AccountDetail(
                id: id, name: "", type: .general, currency: "USD",
                balance: 0, isTracked: true, metadata: [:]
            )
        }

        func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
            fatalError("Not expected in edit tests")
        }

        func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
            if let error = updateError { throw error }
            updatedInput = input
            return AccountDetail(
                id: id, name: input.name, type: input.type,
                currency: input.currency, balance: detailToReturn?.balance ?? 0,
                isTracked: input.isTracked, metadata: input.metadata
            )
        }
    }

    private enum TestError: Error, LocalizedError {
        case networkFailure
        case saveFailed
        var errorDescription: String? {
            switch self {
            case .networkFailure: return "Network request failed"
            case .saveFailed: return "Save failed"
            }
        }
    }

    // MARK: - Tests

    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        #expect(vm.state == .loading)
    }

    @Test("accountId is stored correctly")
    func accountIdIsStored() {
        let id = UUID()
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: id, repository: repo)
        #expect(vm.accountId == id)
    }

    @Test("loadAccount populates form fields from account detail")
    func loadAccountPopulatesFields() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Visa", type: .creditCard, currency: "EUR",
            balance: -450_00, isTracked: false, metadata: ["issuer": "Chase"]
        )

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()

        #expect(vm.state == .editing)
        #expect(vm.name == "Visa")
        #expect(vm.accountType == .creditCard)
        #expect(vm.currency == "EUR")
        #expect(vm.isTracked == false)
        #expect(vm.metadata == ["issuer": "Chase"])
    }

    @Test("loadAccount transitions to error state on failure")
    func loadAccountError() async {
        let repo = StubAccountsRepository()
        repo.getDetailError = TestError.networkFailure

        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        await vm.loadAccount()

        guard case .error(let displayableError) = vm.state else {
            Issue.record("Expected error state, got \(vm.state)")
            return
        }
        #expect(displayableError.message == "Network request failed")
    }

    @Test("isValid is false when name is empty")
    func isValidWithEmptyName() {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        vm.name = ""
        #expect(vm.isValid == false)
    }

    @Test("isValid is true when name is provided")
    func isValidWithName() {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        vm.name = "Checking"
        #expect(vm.isValid == true)
    }

    @Test("validate populates errors when name is empty")
    func validateEmptyName() {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        vm.name = ""
        let result = vm.validate()
        #expect(result == false)
        #expect(vm.validationErrors["name"] == "Name is required.")
    }

    @Test("validate clears errors when name is provided")
    func validateValidName() {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        vm.name = "Savings"
        let result = vm.validate()
        #expect(result == true)
        #expect(vm.validationErrors.isEmpty)
    }

    @Test("save does not call repository when validation fails")
    func saveDoesNotCallRepositoryWhenInvalid() async {
        let repo = StubAccountsRepository()
        let vm = EditAccountViewModel(accountId: UUID(), repository: repo)
        vm.name = ""

        await vm.save()

        #expect(repo.updatedInput == nil)
    }

    @Test("save transitions to saved state on success")
    func saveSuccess() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Old Name", type: .bank, currency: "USD",
            balance: 100_00, isTracked: true, metadata: [:]
        )

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()

        vm.name = "New Name"
        vm.accountType = .cash
        vm.isTracked = false

        await vm.save()

        guard case .saved(let detail) = vm.state else {
            Issue.record("Expected saved state, got \(vm.state)")
            return
        }
        #expect(detail.name == "New Name")
        #expect(detail.type == .cash)
        #expect(detail.isTracked == false)
    }

    @Test("save passes trimmed name to repository")
    func saveTrimmedName() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Test", type: .bank, currency: "USD",
            balance: 0, isTracked: true, metadata: [:]
        )

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()
        vm.name = "  Trimmed  "

        await vm.save()

        #expect(repo.updatedInput?.name == "Trimmed")
    }

    @Test("save transitions to editing state with currentError on failure")
    func saveError() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Test", type: .bank, currency: "USD",
            balance: 0, isTracked: true, metadata: [:]
        )
        repo.updateError = TestError.saveFailed

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()
        vm.name = "Updated"

        await vm.save()

        #expect(vm.state == .editing)
        #expect(vm.currentError?.message == "Save failed")
    }

    @Test("save sets currentError on failure")
    func saveSetsCurrentError() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Test", type: .bank, currency: "USD",
            balance: 0, isTracked: true, metadata: [:]
        )
        repo.updateError = TestError.saveFailed

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()
        vm.name = "Updated"

        await vm.save()

        #expect(vm.currentError != nil)
        #expect(vm.currentError?.message == "Save failed")
    }

    @Test("save preserves form data on failure")
    func savePreservesFormDataOnFailure() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.detailToReturn = AccountDetail(
            id: id, name: "Original", type: .bank, currency: "USD",
            balance: 0, isTracked: true, metadata: [:]
        )
        repo.updateError = TestError.saveFailed

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()
        vm.name = "Updated Name"
        vm.accountType = .cash

        await vm.save()

        #expect(vm.name == "Updated Name")
        #expect(vm.accountType == .cash)
    }

    @Test("loadAccount clears previous error on retry success")
    func loadAccountClearsErrorOnRetry() async {
        let id = UUID()
        let repo = StubAccountsRepository()
        repo.getDetailError = TestError.networkFailure

        let vm = EditAccountViewModel(accountId: id, repository: repo)
        await vm.loadAccount()

        guard case .error = vm.state else {
            Issue.record("Expected error state first")
            return
        }

        repo.getDetailError = nil
        repo.detailToReturn = AccountDetail(
            id: id, name: "Recovered", type: .bank, currency: "USD",
            balance: 0, isTracked: true, metadata: [:]
        )

        await vm.loadAccount()

        #expect(vm.state == .editing)
        #expect(vm.name == "Recovered")
        #expect(vm.currentError == nil)
    }
}
