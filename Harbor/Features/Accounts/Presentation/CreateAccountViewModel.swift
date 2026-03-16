import Foundation
import Logging

/// Possible states of the Create Account screen.
enum CreateAccountScreenState: Sendable, Equatable {
    case idle
    case saving
    case saved(AccountDetail)
}

/// Drives the Create Account screen: manages form state, validates input,
/// and delegates persistence to the repository.
@Observable
@MainActor
final class CreateAccountViewModel: ErrorHandling {
    let logger = Logger(label: "com.harbor.createAccount")

    private let repository: IAccountsRepository

    // MARK: - Form fields

    var name: String = ""
    var accountType: AccountType = .bank
    var currency: String = "USD"
    var isTracked: Bool = true
    var metadata: [String: String] = [:]

    // MARK: - State

    private(set) var state: CreateAccountScreenState = .idle
    var currentError: DisplayableError?

    /// Validation errors keyed by field name.
    private(set) var validationErrors: [String: String] = [:]

    init(repository: IAccountsRepository) {
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

    /// Validates input and creates the account via the repository.
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
            let created = try await repository.createAccount(input: input)
            state = .saved(created)
        } catch {
            displayError(error, context: "CreateAccountViewModel.save")
            // Return to idle so the user can retry without losing form data.
            state = .idle
        }
    }
}
