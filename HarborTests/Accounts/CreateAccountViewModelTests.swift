import Testing
import Foundation
@testable import Harbor

@MainActor
struct CreateAccountViewModelTests {

    // MARK: - Helpers

    private final class StubAccountsRepository: IAccountsRepository {
        var createdInput: SaveAccountInput?
        var errorToThrow: Error?

        func getAccounts() async throws -> [AccountSummary] { [] }

        func getAccountDetail(id: UUID) async throws -> AccountDetail {
            fatalError("Not expected in create tests")
        }

        func createAccount(input: SaveAccountInput) async throws -> AccountDetail {
            if let error = errorToThrow { throw error }
            createdInput = input
            return AccountDetail(
                id: UUID(), name: input.name, type: input.type,
                currency: input.currency, balance: 0,
                isTracked: input.isTracked, metadata: input.metadata
            )
        }

        func updateAccount(id: UUID, input: SaveAccountInput) async throws -> AccountDetail {
            fatalError("Not expected in create tests")
        }
    }

    private enum TestError: Error, LocalizedError {
        case saveFailed
        var errorDescription: String? { "Save failed" }
    }

    // MARK: - Tests

    @Test("Initial state is idle")
    func initialStateIsIdle() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        #expect(vm.state == .idle)
    }

    @Test("Default form values")
    func defaultFormValues() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        #expect(vm.name == "")
        #expect(vm.accountType == .bank)
        #expect(vm.currency == "USD")
        #expect(vm.isTracked == true)
        #expect(vm.metadata == [:])
    }

    @Test("isValid is false when name is empty")
    func isValidWithEmptyName() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = ""
        #expect(vm.isValid == false)
    }

    @Test("isValid is false when name is only whitespace")
    func isValidWithWhitespaceName() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "   "
        #expect(vm.isValid == false)
    }

    @Test("isValid is true when name is provided")
    func isValidWithName() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "Checking"
        #expect(vm.isValid == true)
    }

    @Test("validate populates errors when name is empty")
    func validateEmptyName() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = ""
        let result = vm.validate()
        #expect(result == false)
        #expect(vm.validationErrors["name"] == "Name is required.")
    }

    @Test("validate clears errors when name is provided")
    func validateValidName() {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "Savings"
        let result = vm.validate()
        #expect(result == true)
        #expect(vm.validationErrors.isEmpty)
    }

    @Test("save does not call repository when validation fails")
    func saveDoesNotCallRepositoryWhenInvalid() async {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = ""

        await vm.save()

        #expect(repo.createdInput == nil)
        #expect(vm.state == .idle)
    }

    @Test("save transitions to saved state on success")
    func saveSuccess() async {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "Cash"
        vm.accountType = .cash
        vm.currency = "EUR"
        vm.isTracked = false
        vm.metadata = ["note": "petty cash"]

        await vm.save()

        guard case .saved(let detail) = vm.state else {
            Issue.record("Expected saved state, got \(vm.state)")
            return
        }
        #expect(detail.name == "Cash")
        #expect(detail.type == .cash)
        #expect(detail.currency == "EUR")
        #expect(detail.isTracked == false)
        #expect(detail.metadata == ["note": "petty cash"])
    }

    @Test("save passes trimmed name to repository")
    func saveTrimmedName() async {
        let repo = StubAccountsRepository()
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "  Checking  "

        await vm.save()

        #expect(repo.createdInput?.name == "Checking")
    }

    @Test("save transitions to idle state with currentError on failure")
    func saveError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.saveFailed
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "Visa"

        await vm.save()

        #expect(vm.state == .idle)
        #expect(vm.currentError?.message == "Save failed")
    }

    @Test("save sets currentError on failure")
    func saveSetsCurrentError() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.saveFailed
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "Visa"

        await vm.save()

        #expect(vm.currentError != nil)
        #expect(vm.currentError?.message == "Save failed")
    }

    @Test("save preserves form data on failure")
    func savePreservesFormDataOnFailure() async {
        let repo = StubAccountsRepository()
        repo.errorToThrow = TestError.saveFailed
        let vm = CreateAccountViewModel(repository: repo)
        vm.name = "My Card"
        vm.accountType = .creditCard
        vm.currency = "EUR"

        await vm.save()

        #expect(vm.name == "My Card")
        #expect(vm.accountType == .creditCard)
        #expect(vm.currency == "EUR")
    }
}
