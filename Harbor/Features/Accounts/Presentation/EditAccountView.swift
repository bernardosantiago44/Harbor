import SwiftUI

/// Screen for editing an existing account.
struct EditAccountView: View {
    @Environment(AppRouter.self) private var router
    let viewModel: EditAccountViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingStateView(message: "Loading account…")

            case .editing:
                AccountFormView(
                    name: Bindable(viewModel).name,
                    accountType: Bindable(viewModel).accountType,
                    currency: Bindable(viewModel).currency,
                    isTracked: Bindable(viewModel).isTracked,
                    metadata: Bindable(viewModel).metadata,
                    validationErrors: viewModel.validationErrors
                )

            case .saving:
                LoadingStateView(message: "Saving changes…")

            case .saved:
                Color.clear
                    .onAppear { router.pop() }

            case .error(let displayableError):
                ErrorStateView(message: displayableError.message) {
                    Task { await viewModel.loadAccount() }
                }
            }
        }
        .navigationTitle("Edit Account")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    router.pop()
                }
            }
            if case .editing = viewModel.state {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
        .alert(
            "Error",
            isPresented: saveErrorBinding,
            actions: {
                Button("OK") { }
            },
            message: {
                if let error = viewModel.currentError {
                    Text(error.message)
                }
            }
        )
        .task { await viewModel.loadAccount() }
    }

    // MARK: - Helpers

    /// Binding that presents the alert when a save error occurs while in editing state.
    private var saveErrorBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                if case .editing = viewModel.state, viewModel.currentError != nil {
                    return true
                }
                return false
            },
            set: { newValue in
                if !newValue {
                    viewModel.clearError()
                }
            }
        )
    }
    }
}

#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack {
        EditAccountView(
            viewModel: EditAccountViewModel(
                accountId: UUID(),
                repository: PreviewAccountsRepository()
            )
        )
    }
    .environment(router)
}
