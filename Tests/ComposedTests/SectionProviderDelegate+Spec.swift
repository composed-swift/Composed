import Foundation
import Quick
import Nimble

@testable import Composed

final class SectionProviderDelegate_Spec: QuickSpec {

    override func spec() {
        super.spec()

        var global: ComposedSectionProvider!
        var child: Section!
        var delegate: MockDelegate!

        beforeEach {
            global = ComposedSectionProvider()
            delegate = MockDelegate()
            global.updateDelegate = delegate

            child = ArraySection<String>()
            global.append(child)
        }

        it("should call the delegate method for inserting a section") {
            expect(delegate.didInsertSections).toNot(beNil())
        }

        it("should be called from the global provider") {
            expect(delegate.didInsertSections?.provider) === global
        }

        it("should contain only 1 new section") {
            expect(delegate.didInsertSections?.sections.count).to(equal(1))
        }

        it("should be called from child") {
            expect(delegate.didInsertSections?.sections[0]) === child
        }

        it("section should equal 1") {
            expect(delegate.didInsertSections?.indexes) === IndexSet(integer: 0)
        }

    }

}

final class MockDelegate: SectionProviderUpdateDelegate {

    func invalidateAll(_ provider: SectionProvider) {

    }

    func providerWillUpdate(_ provider: SectionProvider) {

    }

    func providerDidUpdate(_ provider: SectionProvider) {
        
    }

    var didInsertSections: (provider: SectionProvider, sections: [Section], indexes: IndexSet)?
    var didRemoveSections: (provider: SectionProvider, sections: [Section], indexes: IndexSet)?

    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        didInsertSections = (provider, sections, indexes)
    }

    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        didRemoveSections = (provider, sections, indexes)
    }

}
