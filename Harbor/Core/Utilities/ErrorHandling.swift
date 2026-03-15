import Foundation
import Logging

/// Describes a user-facing error suitable for display in an ``ErrorStateView``.
struct DisplayableError: Sendable, Equatable {
    let message: String
}

/// Protocol for ViewModels that need standardized error handling and logging.
protocol ErrorHandling: AnyObject {
    var logger: Logger { get }
    var currentError: DisplayableError? { get set }

    func displayError(_ error: Error, context: String)
    func clearError()
}

extension ErrorHandling {
    /// Logs the error and sets a user-visible error message.
    func displayError(_ error: Error, context: String) {
        logger.error("[\(context)] \(error.localizedDescription)")
        currentError = DisplayableError(message: error.localizedDescription)
    }

    /// Clears the current error state.
    func clearError() {
        currentError = nil
    }
}
