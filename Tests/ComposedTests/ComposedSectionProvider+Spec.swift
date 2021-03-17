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
                    var child2d: ArraySection<String>!
                var child2e: ComposedSectionProvider!
                var child2f: ArraySection<String>!
                var child2g: ComposedSectionProvider!
                    var child2h: ArraySection<String>!

            beforeEach {
                global = ComposedSectionProvider()

                child1 = ComposedSectionProvider()
                    child1a = ArraySection<String>()
                    child1b = ArraySection<String>()
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

            it("should contain 7 global sections") {
                expect(global.numberOfSections) == 7
            }

            it("cache should contain 2 providers") {
                expect(global.providers.count) == 2
            }

            it("should return the right offsets") {
                expect(global.sectionOffset(for: child1)) == 0
                expect(global.sectionOffset(for: child1a)) == 0
                expect(global.sectionOffset(for: child1b)) == 1
                expect(global.sectionOffset(for: child2)) == 2
                expect(global.sectionOffset(for: child2a)) == 2
                expect(global.sectionOffset(for: child2b)) == 2
                expect(global.sectionOffset(for: child2c)) == 3
                expect(global.sectionOffset(for: child2d)) == 4
                expect(global.sectionOffset(for: child2e)) == 5
                expect(global.sectionOffset(for: child2f)) == 5
                expect(global.sectionOffset(for: child2g)) == 6
                expect(global.sectionOffset(for: child2h)) == 6

                expect(child2.sectionOffset(for: child2a)) == 0
                expect(child2.sectionOffset(for: child2e)) == 3
                expect(child2.sectionOffset(for: child2g)) == 4

                expect(child2a.sectionOffset(for: child2b)) == 0
                expect(child2a.sectionOffset(for: child2c)) == 1
                expect(child2a.sectionOffset(for: child2d)) == 2
            }

            context("when a section is inserted after a section provider with multiple sections") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection<String>()
                    countBefore = global.numberOfSections

                    global.append(newSection)
                }

                it("should pass the correct indexes to the delegate") {
                    expect(mockDelegate.didInsertSectionsCalls.last!.2) == IndexSet(integer: countBefore)
                }

                it("should update the sections count") {
                    expect(global.numberOfSections) == 8
                }

                it("should contain the correct sections") {
                    expect(global.sections[0]) === child1a
                    expect(global.sections[1]) === child1b
                    expect(global.sections[2]) === child2b
                    expect(global.sections[3]) === child2c
                    expect(global.sections[4]) === child2d
                    expect(global.sections[5]) === child2f
                    expect(global.sections[6]) === child2h
                    expect(global.sections[7]) === newSection
                }
            }

            context("when a section provider is inserted after a section provider with multiple sections") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!
                var sectionProvider: ComposedSectionProvider!
                var newSection1: ArraySection<String>!
                var newSection2: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate
                    sectionProvider = ComposedSectionProvider()
                    newSection1 = ArraySection<String>()
                    newSection2 = ArraySection<String>()
                    sectionProvider.append(newSection1)
                    sectionProvider.append(newSection2)

                    countBefore = global.numberOfSections

                    global.append(sectionProvider)
                }

                it("should pass the correct indexes to the delegate") {
                    expect(mockDelegate.didInsertSectionsCalls.last!.2) == IndexSet(integersIn: countBefore..<(countBefore + sectionProvider.numberOfSections))
                }

                it("should update the sections count") {
                    expect(global.numberOfSections) == 9
                }

                it("should contain the correct sections") {
                    expect(global.sections[0]) === child1a
                    expect(global.sections[1]) === child1b
                    expect(global.sections[2]) === child2b
                    expect(global.sections[3]) === child2c
                    expect(global.sections[4]) === child2d
                    expect(global.sections[5]) === child2f
                    expect(global.sections[6]) === child2h
                    expect(global.sections[7]) === newSection1
                    expect(global.sections[8]) === newSection2
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

                it("should contain the correct sections") {
                    expect(global.sections[0]) === child1a
                    expect(global.sections[1]) === child1b
                    expect(global.sections[2]) === child2b
                    expect(global.sections[3]) === child2c
                    expect(global.sections[4]) === child2d
                    expect(global.sections[5]) === child2f
                    expect(global.sections[6]) === child2h
                }
            }

            context("when multiple sections are removed") {
                var mockDelegate: MockSectionProviderUpdateDelegate!
                var countBefore: Int!

                beforeEach {
                    mockDelegate = MockSectionProviderUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    countBefore = global.numberOfSections

                    child2.remove(child2a)
                }

                it("should pass through the removed indexes to the delegate") {
                    expect(mockDelegate.didRemoveSectionsCalls.last!.2) == IndexSet([0, 1, 2])
                }

                it("should update the number of sections") {
                    expect(global.numberOfSections) == countBefore - 3
                }

                it("should pass itself to the delegate") {
                    expect(mockDelegate.didRemoveSectionsCalls.last!.0) === child2
                }

                it("should contain the correct sections") {
                    expect(global.sections[0]) === child1a
                    expect(global.sections[1]) === child1b
                    expect(global.sections[2]) === child2f
                    expect(global.sections[3]) === child2h
                }
            }

            context("when the last section provider is a segmented section provider") {
                var child3: SegmentedSectionProvider!
                var child3a: ComposedSectionProvider!
                var child3a_0: ArraySection<String>!
                var child3b: ComposedSectionProvider!
                // Will have 10 children
                var child3c: ComposedSectionProvider!

                beforeEach {
                    child3 = SegmentedSectionProvider()
                    child3a = ComposedSectionProvider()
                    child3a_0 = ArraySection<String>()
                    child3b = ComposedSectionProvider()
                    child3c = ComposedSectionProvider()

                    child3a.append(child3a_0)
                    (0..<10).forEach { _ in
                        child3b.append(ArraySection<String>())
                    }

                    global.append(child3)
                    child3.append(child3a)
                    child3.append(child3b)
                    child3.append(child3c)
                }

                context("switches to a segment with more sections than the global provider contains") {
                    var mockDelegate: MockSectionProviderUpdateDelegate!
                    var countBefore: Int!
                    var sectionCountBefore: Int!
                    var sectionCountDifference: Int!

                    beforeEach {
                        mockDelegate = MockSectionProviderUpdateDelegate()
                        global.updateDelegate = mockDelegate

                        countBefore = global.numberOfSections

                        sectionCountBefore = child3.numberOfSections
                        child3.currentIndex = 1
                        sectionCountDifference = child3.numberOfSections - sectionCountBefore
                    }

                    it("should update the number of sections") {
                        expect(global.numberOfSections) == countBefore + sectionCountDifference
                    }
                }

                context("switches to a segment with less sections than the global provider contains") {
                    var mockDelegate: MockSectionProviderUpdateDelegate!
                    var countBefore: Int!
                    var sectionCountBefore: Int!
                    var sectionCountDifference: Int!

                    beforeEach {
                        mockDelegate = MockSectionProviderUpdateDelegate()
                        global.updateDelegate = mockDelegate

                        countBefore = global.numberOfSections

                        sectionCountBefore = child3.numberOfSections
                        child3.currentIndex = 2
                        sectionCountDifference = child3.numberOfSections - sectionCountBefore
                    }

                    it("should update the number of sections") {
                        expect(global.numberOfSections) == countBefore + sectionCountDifference
                    }
                }
            }
        }
    }

}

private final class MockSectionProviderUpdateDelegate: SectionProviderUpdateDelegate {
    func provider(_ provider: SectionProvider, willPerformBatchUpdates updates: (ChangesReducer) -> Void) {
        
    }
    
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
