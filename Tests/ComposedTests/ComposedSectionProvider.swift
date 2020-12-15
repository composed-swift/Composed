import Quick
import Nimble
import Foundation

@testable import Composed

final class ComposedSectionProvider_Spec: QuickSpec {

    override func spec() {
        describe("ComposedSectionProvider") {
            var global: ComposedSectionProvider!
            var child1: ComposedSectionProvider!
                var child1a: ArraySection<String>!
                var child1b: ArraySection<String>!
            var child2: ComposedSectionProvider!
                var child2a: ComposedSectionProvider!
                    var child2b: ArraySection<String>!
                    var child2c: ArraySection<String>!
                var child2z: ComposedSectionProvider!
                var child2d: ArraySection<String>!
                var child2e: ComposedSectionProvider!
                    var child2f: ArraySection<String>!

            beforeEach {
                global = ComposedSectionProvider()

                child1 = ComposedSectionProvider()
                    child1a = ArraySection<String>()
                    child1b = ArraySection<String>()
                child2 = ComposedSectionProvider()
                    child2a = ComposedSectionProvider()
                        child2b = ArraySection<String>()
                        child2c = ArraySection<String>()
                    child2z = ComposedSectionProvider()
                    child2d = ArraySection<String>()
                    child2e = ComposedSectionProvider()
                        child2f = ArraySection<String>()

                child1.append(child1a)
                child1.insert(child1b, after: child1a)

                child2.append(child2a)
                child2a.append(child2c)
                child2a.insert(child2b, before: child2c)

                child2.insert(child2z, after: child2a)
                child2.append(child2d)
                child2e.append(child2f)
                child2.append(child2e)
                global.append(child1)
                global.append(child2)
            }

            it("should contain 6 global sections") {
                expect(global.numberOfSections) == 6
            }

            it("cache should contain 2 providers") {
                expect(global.providers.count) == 2
            }

            it("should return the right offsets") {
                expect(global.sectionOffset(for: child1)) == 0
                expect(global.sectionOffset(for: child2)) == 2
                expect(global.sectionOffset(for: child2a)) == 2
                expect(global.sectionOffset(for: child2z)) == 4
                expect(global.sectionOffset(for: child2e)) == 5
                
                expect(child2.sectionOffset(for: child2a)) == 0
                expect(child2.sectionOffset(for: child2z)) == 2
                expect(child2.sectionOffset(for: child2e)) == 3
            }

            context("when a section is inserted after a section provider with multiple sections") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    let newSection = ArraySection<String>()
                    countBefore = global.numberOfSections

                    global.append(newSection)
                }

                it("should pass the correct indexes to the delegate") {
                    expect(mockDelegate.didInsertSectionsCalls.last!.2) == IndexSet(integer: countBefore)
                }
            }

            context("when a section provider is inserted after a section provider with multiple sections") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!
                var sectionProvider: ComposedSectionProvider!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate
                    sectionProvider = ComposedSectionProvider()
                    sectionProvider.append(ArraySection<String>())
                    sectionProvider.append(ArraySection<String>())

                    countBefore = global.numberOfSections

                    global.append(sectionProvider)
                }

                it("should pass the correct indexes to the delegate") {
                    expect(mockDelegate.didInsertSectionsCalls.last!.2) == IndexSet(integersIn: countBefore..<(countBefore + sectionProvider.numberOfSections))
                }
            }

            context("when a section located after a section provider with multiple sections is removed") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    let newSection = ArraySection<String>()
                    global.append(newSection)

                    countBefore = global.numberOfSections

                    global.remove(newSection)
                }

                it("should pass the correct indexes to the delegate") {
                    expect(mockDelegate.didRemoveSectionsCalls.last!.2) == IndexSet(integer: countBefore - 1)
                }
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
