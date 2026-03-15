import SwiftUI

/// Root container view. Owns the NavigationStack and resolves routes.
struct RootView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var bindableRouter = router
        NavigationStack(path: $bindableRouter.path) {
            List {
                Button("Accounts") {
                    bindableRouter.navigate(to: .accounts)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                bindableRouter.view(for: route)
            }
        }
    }
}

#Preview {
    @Previewable @State var router = AppRouter()
    @Previewable @State var container = DependencyContainer()
    
    RootView()
        .environment(router)
        .environment(container)
}
