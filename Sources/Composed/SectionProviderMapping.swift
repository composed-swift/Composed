import Foundation

/**
 An object that encapsulates the logic required to map `SectionProvider`s to
 a global context, allowing elements in a `Section` to be referenced via an
 `IndexPath`
 */
public final class SectionProviderMapping: SectionProviderUpdateDelegate, SectionUpdateDelegate {

    public weak var delegate: SectionProviderMappingDelegate?

    public let provider: SectionProvider

    public var numberOfSections: Int {
        return provider.numberOfSections
    }

    private var cachedProviderSections: [HashableProvider: Int] = [:]

    public init(provider: SectionProvider) {
        self.provider = provider
        provider.updateDelegate = self
    }

    public func sectionOffset(of provider: SectionProvider) -> Int? {
        return cachedProviderSections[HashableProvider(provider)]
    }

    public func sectionOffset(of section: Section) -> Int? {
        return provider.sections.firstIndex(where: { $0 === section })
    }

    private func globalIndexes(for provider: SectionProvider, with indexes: IndexSet) -> IndexSet {
        if provider is AggregateSectionProvider {
            // The inserted section couldn've been due to a new section provider
            // being inserted in to the hierachy; rebuild the offsets cache
            rebuildSectionOffsets()
        }

        guard let offset = sectionOffset(of: provider) else {
            assertionFailure("Cannot call \(#function) with a provider not in the hierachy")
            return []
        }

        return IndexSet(indexes.map { $0 + offset })
    }

    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didInsertSections: indexes)
        // add sections.count to all sections >= sectionOffset(for: provider)
    }

    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didRemoveSections: indexes)
        // minus sections.count to all sections >= sectionOffset(for: provider)
    }

    public func provider(_ provider: SectionProvider, didUpdateSections sections: [Section], at indexes: IndexSet) {
        guard let offset = sectionOffset(of: provider) else {
            assertionFailure("Cannot call \(#function) with a provider not in the hierachy")
            return
        }
        let indexes = IndexSet(indexes.map { $0 + offset })
        delegate?.mapping(self, didUpdateSections: indexes)
    }

    private func indexPath(for index: Int, in section: Section) -> IndexPath? {
        guard let offset = sectionOffset(of: section) else {
            assertionFailure("Cannot call \(#function) with a section not in the hierachy")
            return nil
        }
        return IndexPath(item: index, section: offset)
    }

    public func section(_ section: Section, didInsertElementAt index: Int) {
        guard let indexPath = self.indexPath(for: index, in: section) else { return }
        delegate?.mapping(self, didInsertElementsAt: [indexPath])
    }

    public func section(_ section: Section, didRemoveElementAt index: Int) {
        guard let indexPath = self.indexPath(for: index, in: section) else { return }
        delegate?.mapping(self, didRemoveElementsAt: [indexPath])
    }

    public func section(_ section: Section, didUpdateElementAt index: Int) {
        guard let indexPath = self.indexPath(for: index, in: section) else { return }
        delegate?.mapping(self, didUpdateElementsAt: [indexPath])
    }

    public func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int) {
        guard let source = self.indexPath(for: index, in: section) else { return }
        guard let destination = self.indexPath(for: newIndex, in: section) else { return }
        delegate?.mapping(self, didMoveElementsAt: [(source, destination)])
    }

    private func rebuildSectionOffsets() {
        var providerSections: [HashableProvider: Int] = [HashableProvider(provider): 0]

        defer {
            cachedProviderSections = providerSections
        }

        // Joseph: can we actually just return here?
        guard let aggregate = provider as? AggregateSectionProvider else { return }

        func addOffsets(forChildrenOf aggregate: AggregateSectionProvider, offset: Int = 0) {
            for child in aggregate.providers {
                let aggregateSectionOffset = aggregate.sectionOffset(for: child)
                guard aggregateSectionOffset > -1 else {
                    assertionFailure("AggregateSectionProvider should return a value > -1 for section offset of child \(child)")
                    continue
                }
                providerSections[HashableProvider(child)] = offset + aggregateSectionOffset

                if let aggregate = child as? AggregateSectionProvider {
                    addOffsets(forChildrenOf: aggregate, offset: offset + aggregateSectionOffset)
                }
            }
        }

        addOffsets(forChildrenOf: aggregate)
    }

}

public protocol SectionProviderMappingDelegate: class {
    func mapping(_ mapping: SectionProviderMapping, didInsertSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didInsertElementsAt indexPaths: [IndexPath])

    func mapping(_ mapping: SectionProviderMapping, didRemoveSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didRemoveElementsAt indexPaths: [IndexPath])

    func mapping(_ mapping: SectionProviderMapping, didUpdateSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didUpdateElementsAt indexPaths: [IndexPath])

    func mapping(_ mapping: SectionProviderMapping, didMoveElementsAt moves: [(IndexPath, IndexPath)])
}

// We don't want to import UIKit here so we create the same IndexPath init.
// This will 'just work' on the consumer's end.
private extension IndexPath {
    var section: Int {
        return self[0]
    }

    var item: Int {
        return self[1]
    }

    init(item: Int, section: Int) {
        self.init(indexes: [section, item])
    }
}
