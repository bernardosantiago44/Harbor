import Foundation
import Logging

/// Possible states of the Edit Account screen.
enum EditAccountScreenState: Sendable, Equatable {
    case loading
    case editing
    case saving
    case saved(AccountDetail)
    case error(DisplayableError)
}

/// Drives the Edit Account screen: preloads account data, manages form state,
/// validates input, and delegates persistence to the repository.
@Observable
@MainActor
final class EditAccountViewModel: ErrorHandling {
    let logger = Logger(label: "com.harbor.editAccount")

    private let repository: IAccountsRepository
    let accountId: UUID

    // MARK: - Form fields

    var name: String = ""
    var accountType: AccountType = .bank
    var currency: String = "USD"
    var isTracked: Bool = true
    var metadata: [String: String] = [:]

    // MARK: - State

    private(set) var state: EditAccountScreenState = .loading
    var currentError: DisplayableError?

    /// Validation errors keyed by field name.
    private(set) var validationErrors: [String: String] = [:]

    init(accountId: UUID, repository: IAccountsRepository) {
        self.accountId = accountId
        self.repository = repository
    }

    /// Whether the current form input passes validation.
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Validates form fields and populates `validationErrors`.
    /// - Returns: `true` if all fields are valid.
    @discardableResult
    func validate() -> Bool {
        var errors: [String: String] = [:]

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors["name"] = "Name is required."
        }

        validationErrors = errors
        return errors.isEmpty
    }

    /// Loads existing account data into the form fields.
    func loadAccount() async {
        state = .loading
        clearError()

        do {
            let detail = try await repository.getAccountDetail(id: accountId)
            name = detail.name
            accountType = detail.type
            currency = detail.currency
            isTracked = detail.isTracked
            metadata = detail.metadata
            state = .editing
        } catch {
            displayError(error, context: "EditAccountViewModel.loadAccount")
            state = .error(currentError ?? DisplayableError(message: "An unexpected error occurred."))
        }
    }

    /// Validates input and updates the account via the repository.
    func save() async {
        guard validate() else { return }

        state = .saving
        clearError()

        let input = SaveAccountInput(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: accountType,
            currency: currency,
            isTracked: isTracked,
            metadata: metadata
        )

        do {
            let updated = try await repository.updateAccount(id: accountId, input: input)
            state = .saved(updated)
        } catch {
            displayError(error, context: "EditAccountViewModel.save")
            // Return to editing so the user can retry without losing form data.
            state = .editing
        }
    }
}
