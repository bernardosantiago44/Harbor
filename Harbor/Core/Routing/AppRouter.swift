import SwiftUI

/// Manages the NavigationStack path and resolves routes to views.
@Observable
final class AppRouter {
    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    @ViewBuilder
    func view(for route: AppRoute, container: DependencyContainer) -> some View {
        switch route {
        case .accounts:
            AccountsView(viewModel: AccountsViewModel(
                repository: container.accountsRepository
            ))
        case .accountDetail(let id):
            AccountDetailView(
                viewModel: AccountDetailViewModel(
                    accountId: id,
                    repository: container.accountsRepository
                )
            )
        case .createAccount:
            CreateAccountView(
                viewModel: CreateAccountViewModel(
                    repository: container.accountsRepository
                )
            )
        case .editAccount(let id):
            EditAccountView(
                viewModel: EditAccountViewModel(
                    accountId: id,
                    repository: container.accountsRepository
                )
            )
        }
    }
}
