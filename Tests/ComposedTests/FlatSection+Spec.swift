import Quick
import Nimble
import Foundation

@testable import Composed

final class FlatSection_Spec: QuickSpec {

    override func spec() {
        describe("FlatSection") {
            var global: FlatSection!
            var child1: ComposedSectionProvider!
                var child1a: ArraySection<String>!
                var child1b: ArraySection<String>!
            var child2: ComposedSectionProvider!
                var child2a: ComposedSectionProvider!
                    var child2b: ArraySection<String>!
                    var child2c: ArraySection<String>!
                    var child2d: ArraySection<String>!
                var child2e: ComposedSectionProvider!
                var child2f: ArraySection<String>!
                var child2g: ComposedSectionProvider!
                    var child2h: ArraySection<String>!

            beforeEach {
                global = FlatSection()

                child1 = ComposedSectionProvider()
                    child1a = ArraySection<String>(["child1a index 0", "child1a index 1"])
                    child1b = ArraySection<String>(["child1ba index 0", "child1b index 1", "child1b index 2"])
                child2 = ComposedSectionProvider()
                    child2a = ComposedSectionProvider()
                        child2b = ArraySection<String>()
                        child2c = ArraySection<String>()
                        child2d = ArraySection<String>()
                    child2e = ComposedSectionProvider()
                    child2f = ArraySection<String>()
                    child2g = ComposedSectionProvider()
                        child2h = ArraySection<String>()

                child1.append(child1a)
                child1.insert(child1b, after: child1a)

                child2.append(child2a)
                child2a.append(child2c)
                child2a.insert(child2b, before: child2c)
                child2a.insert(child2d, after: child2c)

                child2.insert(child2e, after: child2a)
                child2.append(child2f)
                child2g.append(child2h)
                child2.append(child2g)
                global.append(child1)
                global.append(child2)
            }

            it("should contain 0 elements") {
                expect(global.numberOfElements) == 5
            }
        }
    }

}

private final class MockSectionProviderUpdateDelegate: SectionProviderUpdateDelegate {
    private(set) var willBeginUpdatingCalls: [SectionProvider] = []
    private(set) var didEndUpdatingCalls: [SectionProvider] = []
    private(set) var invalidateAllCalls: [SectionProvider] = []
    private(set) var didInsertSectionsCalls: [(SectionProvider, [Section], IndexSet)] = []
    private(set) var didRemoveSectionsCalls: [(SectionProvider, [Section], IndexSet)] = []

    func willBeginUpdating(_ provider: SectionProvider) {
        willBeginUpdatingCalls.append(provider)
    }

    func didEndUpdating(_ provider: SectionProvider) {
        didEndUpdatingCalls.append(provider)
    }

    func invalidateAll(_ provider: SectionProvider) {
        invalidateAllCalls.append(provider)
    }

    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        didInsertSectionsCalls.append((provider, sections, indexes))
    }

    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        didRemoveSectionsCalls.append((provider, sections, indexes))
    }
}
