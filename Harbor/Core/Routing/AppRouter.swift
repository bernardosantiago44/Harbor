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
    func view(for route: AppRoute) -> some View {
        switch route {
        case .accounts:
            Text("Accounts")
        case .accountDetail(let id):
            Text("Account \(id.uuidString)")
        case .createAccount:
            Text("Create Account")
        case .editAccount(let id):
            Text("Edit Account \(id.uuidString)")
        }
    }
}
