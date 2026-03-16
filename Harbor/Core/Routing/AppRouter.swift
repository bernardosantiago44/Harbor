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
            AccountDetailView(accountId: id)
        case .createAccount:
            Text("Create Account")
        case .editAccount(let id):
            Text("Edit Account \(id.uuidString)")
        }
    }
}
