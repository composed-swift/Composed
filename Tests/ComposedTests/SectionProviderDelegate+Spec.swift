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
            expect(delegate.didInsertSections?.indexes) == IndexSet(integer: 0)
        }

        it("should have zero sections before the update closure has been called") {
            expect(global.numberOfSections) == 0
        }

        context("when update closure has been called") {
            beforeEach {
                delegate?.didInsertSections?.updatePerformer()
            }

            it("should have new sections") {
                expect(global.numberOfSections) == 1
            }
        }
    }

}

final class MockDelegate: SectionProviderUpdateDelegate {
    func willBeginUpdating(_ provider: SectionProvider) {

    }

    func didEndUpdating(_ provider: SectionProvider) {
        
    }

    func invalidateAll(_ provider: SectionProvider, performUpdate updatePerformer: @escaping UpdatePerformer) {

    }

    func providerWillUpdate(_ provider: SectionProvider) {

    }

    func providerDidUpdate(_ provider: SectionProvider) {
        
    }

    var didInsertSections: (provider: SectionProvider, sections: [Section], indexes: IndexSet, updatePerformer: UpdatePerformer)?
    var didRemoveSections: (provider: SectionProvider, sections: [Section], indexes: IndexSet, updatePerformer: UpdatePerformer)?

    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        didInsertSections = (provider, sections, indexes, updatePerformer)
    }

    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        didRemoveSections = (provider, sections, indexes, updatePerformer)
    }
}
