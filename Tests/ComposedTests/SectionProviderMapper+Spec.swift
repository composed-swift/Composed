import Foundation
import Quick
import Nimble

@testable import Composed

final class SectionProviderMapping_Spec: QuickSpec {

    override func spec() {
        describe("SectionProviderMapping") {
            context("with a composed section provider") {
                var global: ComposedSectionProvider!
                var mapper: SectionProviderMapping!
                var delegate: MockSectionProviderMappingDelegate!
                
                beforeEach {
                    global = ComposedSectionProvider()
                    mapper = SectionProviderMapping(provider: global)
                    delegate = MockSectionProviderMappingDelegate()
                    mapper.delegate = delegate
                }
                
                it("should become the delegate of the section provider") {
                    expect(global.updateDelegate) === mapper
                }
                
                context("when a child section has been added to the global provider") {
                    var child: Section!
                    
                    beforeEach {
                        child = ArraySection<String>()
                        global.append(child)
                    }

                    it("should call the SectionProviderMapping(_:didInsertSections:) delegate function") {
                        expect(delegate.didInsertSections).toNot(beNil())
                    }
                    
                    it("should notify the delegate of the inserted section") {
                        expect(delegate.didInsertSections!.sections) == IndexSet(integer: 0)
                    }
                }
                
                context("with a composed section provider that contains 2 child sections") {
                    var level1EmbeddedSectionProvider: ComposedSectionProvider!
                    var level1Section1: Section!
                    var level1Section2: Section!
                    
                    beforeEach {
                        level1EmbeddedSectionProvider = ComposedSectionProvider()
                        level1Section1 = ArraySection<String>()
                        level1Section2 = ArraySection<String>()
                        level1EmbeddedSectionProvider.append(level1Section1)
                        level1EmbeddedSectionProvider.append(level1Section2)
                        
                        global.append(level1EmbeddedSectionProvider)
                    }
                    
//                    it("should return 2 sections") {
//                        expect(mapper.numberOfSections) == 2
//                    }
                    
                    context("and a composed section provider with 3 sections") {
                        var level2EmbeddedSectionProvider: ComposedSectionProvider!
                        var level2Section1: Section!
                        var level2Section2: Section!
                        var level2Section3: Section!
                        
                        beforeEach {
                            level2EmbeddedSectionProvider = ComposedSectionProvider()
                            level2Section1 = ArraySection<String>()
                            level2Section2 = ArraySection<String>()
                            level2Section3 = ArraySection<String>()
                            level2EmbeddedSectionProvider.append(level2Section1)
                            level2EmbeddedSectionProvider.append(level2Section2)
                            level2EmbeddedSectionProvider.append(level2Section3)
                            
                            level1EmbeddedSectionProvider.append(level2EmbeddedSectionProvider)
                        }
                        
//                        it("should return 5 sections") {
//                            expect(mapper.numberOfSections) == 5
//                        }
                        
//                        it("should return a section offset of 2 for the composed section provider") {
//                            expect(mapper.sectionOffset(of: level2EmbeddedSectionProvider)) == 2
//                        }
//                        
//                        it("should notify the delegate of the inserted sections") {
//                            expect(delegate.didInsertSections!.sections) == IndexSet(2...4)
//                        }
                    }
                }
                
                context("with embedded composed providers") {
                    var level1EmbeddedSectionProvider: ComposedSectionProvider!
                    var level2EmbeddedSectionProvider: ComposedSectionProvider!
                    
                    beforeEach {
                        level1EmbeddedSectionProvider = ComposedSectionProvider()
                        level2EmbeddedSectionProvider = ComposedSectionProvider()
                        level1EmbeddedSectionProvider.append(level2EmbeddedSectionProvider)
                        global.append(level1EmbeddedSectionProvider)
                    }
                }
            }
        }
    }
    
}

final class MockSectionProviderMappingDelegate: SectionProviderMappingDelegate {    var didInsertSections: (mapping: SectionProviderMapping, sections: IndexSet)?
    var didInsertElements: (section: SectionProviderMapping, indexPaths: [IndexPath])?

    var didRemoveSections: (mapping: SectionProviderMapping, sections: IndexSet)?
    var didRemoveElements: (section: SectionProviderMapping, indexPaths: [IndexPath])?

    var didUpdateElements: (section: SectionProviderMapping, indexPaths: [IndexPath])?

    var didMoveElements: (mapping: SectionProviderMapping, moves: [(IndexPath, IndexPath)])?

    var didUpdate: SectionProviderMapping?

    func mappingDidReload(_ mapping: SectionProviderMapping) { }
    func mappingWillBeginUpdating(_ mapping: SectionProviderMapping) { }

    func mappingDidUpdate(_ mapping: SectionProviderMapping) {
        didUpdate = mapping
    }

    func mapping(_ mapping: SectionProviderMapping, didInsertSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        didInsertSections = (mapping, sections)
    }

    func mapping(_ mapping: SectionProviderMapping, didInsertElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer) {
        didInsertElements = (mapping, indexPaths)
    }

    func mapping(_ mapping: SectionProviderMapping, didRemoveSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        didRemoveSections = (mapping, sections)
    }

    func mapping(_ mapping: SectionProviderMapping, didRemoveElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer) {
        didRemoveElements = (mapping, indexPaths)
    }

    func mapping(_ mapping: SectionProviderMapping, didUpdateSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) { }

    func mapping(_ mapping: SectionProviderMapping, didUpdateElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer) {
        didUpdateElements = (mapping, indexPaths)
    }

    func mapping(_ mapping: SectionProviderMapping, didMoveElementsAt moves: [(IndexPath, IndexPath)], performUpdate updatePerformer: @escaping UpdatePerformer) {
        didMoveElements = (mapping, moves)
    }

    func mapping(_ mapping: SectionProviderMapping, selectedIndexesIn section: Int) -> [Int] {
        return []
    }

    func mapping(_ mapping: SectionProviderMapping, select indexPath: IndexPath) { }
    func mapping(_ mapping: SectionProviderMapping, deselect indexPath: IndexPath) { }

    func mappingDidEndUpdating(_ mapping: SectionProviderMapping) {}
    func mappingDidInvalidate(_ mapping: SectionProviderMapping, performUpdate updatePerformer: @escaping UpdatePerformer) {}
    func mapping(_ mapping: SectionProviderMapping, move sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}

}
