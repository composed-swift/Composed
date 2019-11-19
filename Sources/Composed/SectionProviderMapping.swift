import UIKit

public protocol SectionProviderMappingDelegate: class {
    func mappingDidReload(_ mapping: SectionProviderMapping)
    func mappingWillUpdate(_ mapping: SectionProviderMapping)
    func mappingDidUpdate(_ mapping: SectionProviderMapping)

    func mapping(_ mapping: SectionProviderMapping, didInsertSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didInsertElementsAt indexPaths: [IndexPath])
    func mapping(_ mapping: SectionProviderMapping, didRemoveSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didRemoveElementsAt indexPaths: [IndexPath])
    func mapping(_ mapping: SectionProviderMapping, didUpdateSections sections: IndexSet)
    func mapping(_ mapping: SectionProviderMapping, didUpdateElementsAt indexPaths: [IndexPath])
    func mapping(_ mapping: SectionProviderMapping, didMoveElementsAt moves: [(IndexPath, IndexPath)])

    func mapping(_ mapping: SectionProviderMapping, selectedIndexesIn section: Int) -> [Int]
    func mapping(_ mapping: SectionProviderMapping, select indexPath: IndexPath)
    func mapping(_ mapping: SectionProviderMapping, deselect indexPath: IndexPath)
}

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
        provider.sections.forEach { $0.updateDelegate = self }
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

    public func providerWillUpdate(_ provider: SectionProvider) {
        delegate?.mappingWillUpdate(self)
    }

    public func providerDidUpdate(_ provider: SectionProvider) {
        delegate?.mappingDidUpdate(self)
    }

    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        sections.forEach { $0.updateDelegate = self }
        // add sections.count to all sections >= sectionOffset(for: provider)
//        let elements = cachedProviderSections.enumerated().filter { $0.offset >= offset }.map { $0.element }
//        elements.forEach { cachedProviderSections[$0.key] = (cachedProviderSections[$0.key] ?? 0) + sections.count }

        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didInsertSections: indexes)
    }

    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        sections.forEach { $0.updateDelegate = nil }
        // minus sections.count to all sections >= sectionOffset(for: provider)
//        let elements = cachedProviderSections.enumerated().filter { $0.offset >= offset }.map { $0.element }
//        elements.forEach { cachedProviderSections[$0.key] = (cachedProviderSections[$0.key] ?? 0) - sections.count }

        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didRemoveSections: indexes)
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

    public func selectedIndexes(in section: Section) -> [Int] {
        guard let index = sectionOffset(of: section) else { return [] }
        return delegate?.mapping(self, selectedIndexesIn: index) ?? []
    }

    public func section(_ section: Section, select index: Int) {
        guard let section = sectionOffset(of: section) else { return }
        delegate?.mapping(self, select: IndexPath(item: index, section: section))
    }

    public func section(_ section: Section, deselect index: Int) {
        guard let section = sectionOffset(of: section) else { return }
        delegate?.mapping(self, deselect: IndexPath(item: index, section: section))
    }

    public func providerDidReload(_ provider: SectionProvider) {
        delegate?.mappingDidReload(self)
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

        guard let aggregate = provider as? AggregateSectionProvider else { return }

        func addOffsets(forChildrenOf aggregate: AggregateSectionProvider, offset: Int = 0) {
            for child in aggregate.providers {
                let aggregateSectionOffset = aggregate.sectionOffset(for: child)

                guard aggregateSectionOffset > -1 else {
                    assertionFailure("AggregateSectionProvider should return a value > -1 fo.r section offset of child \(child)")
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
