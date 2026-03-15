import Testing
@testable import Harbor

struct DependencyContainerTests {

    @Test("DependencyContainer can be instantiated")
    func containerInstantiates() {
        // Verifies that the initializer completes without crashing or throwing.
        _ = DependencyContainer()
    }
}
