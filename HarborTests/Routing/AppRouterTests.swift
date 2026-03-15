import Testing
@testable import Harbor

@MainActor
struct AppRouterTests {

    @Test("Router starts with empty path")
    func routerStartsEmpty() {
        let router = AppRouter()
        #expect(router.path.isEmpty)
    }

    @Test("Navigate appends a route to path")
    func navigateAppendsRoute() {
        let router = AppRouter()
        router.navigate(to: .accounts)
        #expect(router.path.count == 1)
    }

    @Test("Pop removes last route")
    func popRemovesLast() {
        let router = AppRouter()
        router.navigate(to: .accounts)
        router.navigate(to: .createAccount)
        router.pop()
        #expect(router.path.count == 1)
    }

    @Test("Pop on empty path does not crash")
    func popOnEmptyPathIsSafe() {
        let router = AppRouter()
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test("PopToRoot clears entire path")
    func popToRootClearsPath() {
        let router = AppRouter()
        router.navigate(to: .accounts)
        router.navigate(to: .createAccount)
        router.navigate(to: .accountDetail(id: UUID()))
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
}
