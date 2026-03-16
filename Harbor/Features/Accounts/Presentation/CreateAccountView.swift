import SwiftUI

/// Screen for creating a new account.
struct CreateAccountView: View {
    @Environment(AppRouter.self) private var router
    let viewModel: CreateAccountViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                AccountFormView(
                    name: Bindable(viewModel).name,
                    accountType: Bindable(viewModel).accountType,
                    currency: Bindable(viewModel).currency,
                    isTracked: Bindable(viewModel).isTracked,
                    metadata: Bindable(viewModel).metadata,
                    validationErrors: viewModel.validationErrors
                )

            case .saving:
                LoadingStateView(message: "Creating account…")

            case .saved:
                Color.clear
                    .onAppear { router.pop() }
            }
        }
        .navigationTitle("New Account")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    router.pop()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
                .disabled(!viewModel.isValid || viewModel.state == .saving)
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
    }

    // MARK: - Helpers

    /// Binding that presents the alert when a save error occurs while in idle state.
    private var saveErrorBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                if case .idle = viewModel.state, viewModel.currentError != nil {
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

#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                repository: PreviewAccountsRepository()
            )
        )
    }
    .environment(router)
}
