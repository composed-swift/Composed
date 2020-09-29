import UIKit

/// An object that encapsulates the logic required to map `SectionProvider`s to a global context,
/// allowing elements in a `Section` to be referenced via an `IndexPath`
public final class SectionProviderMapping: SectionProviderUpdateDelegate {
    /// The delegate that will respond to updates
    public weak var delegate: SectionProviderMappingDelegate?

    /// The root provider that contains all other providers and sections
    public let provider: SectionProvider

    /// The number of sections in this mapping
    public var numberOfSections: Int {
        return provider.numberOfSections
    }

    /// The cached providers for each section, improves lookup peformance
    private var cachedProviderSections: [HashableProvider: Int] = [:]

    /// Makes a new mapping for the specified provider
    /// - Parameter provider: The provider to map
    public init(provider: SectionProvider) {
        self.provider = provider
        provider.updateDelegate = self
        provider.sections.forEach { $0.updateDelegate = self }
        rebuildSectionOffsets()
    }

    /// The global section offset for the specified provider, nil if none found
    /// - Parameter provider: The provider this index should represent
    /// - Returns: The section index in a global context
    public func sectionOffset(of provider: SectionProvider) -> Int? {
        return cachedProviderSections[HashableProvider(provider)]
    }

    /// The global section offset for the specified section, nil if none found
    /// - Parameter section: The section this index should represent
    /// - Returns: The section index in a global context
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

    public func willBeginUpdating(_ provider: SectionProvider) {
        delegate?.mappingWillBeginUpdating(self)
    }

    public func didEndUpdating(_ provider: SectionProvider) {
        delegate?.mappingDidEndUpdating(self)
    }

    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        sections.forEach { $0.updateDelegate = self }
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didInsertSections: indexes, performUpdate: updatePerformer)
    }

    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        sections.forEach { $0.updateDelegate = nil }
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didRemoveSections: indexes, performUpdate: updatePerformer)
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

    public func invalidateAll(_ provider: SectionProvider, performUpdate updatePerformer: @escaping UpdatePerformer) {
        delegate?.mappingDidInvalidate(self, performUpdate: updatePerformer)
    }

    public func willBeginUpdating(_ section: Section) {
        delegate?.mappingWillBeginUpdating(self)
    }

    public func didEndUpdating(_ section: Section) {
        delegate?.mappingDidEndUpdating(self)
    }

    public func invalidateAll(_ section: Section, performUpdate updatePerformer: @escaping UpdatePerformer) {
        provider.sections.forEach { $0.updateDelegate = self }
        delegate?.mappingDidInvalidate(self, performUpdate: updatePerformer)
    }

//    public func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {
//        guard let sourceIndexPath = self.indexPath(for: sourceIndex, in: section),
//            let destinationIndexPath = self.indexPath(for: destinationIndex, in: section) else {
//                return
//        }
//        delegate?.mapping(self, move: sourceIndexPath, to: destinationIndexPath)
//    }

    public func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int, performUpdate updatePerformer: @escaping UpdatePerformer) {
        guard let source = self.indexPath(for: index, in: section) else { return }
        guard let destination = self.indexPath(for: newIndex, in: section) else { return }
        delegate?.mapping(self, didMoveElementsAt: [(source, destination)], performUpdate: updatePerformer)
    }

    // Rebuilds the cached providers to improve lookup performance.
    // This is generally only required when a sections are either inserted or removed, so it should be fairly efficient.
    private func rebuildSectionOffsets() {
        var providerSections: [HashableProvider: Int] = [HashableProvider(provider): 0]

        defer {
            cachedProviderSections = providerSections
        }

        guard let aggregate = provider as? AggregateSectionProvider else { return }

        func addOffsets(forChildrenOf aggregate: AggregateSectionProvider, offset: Int = 0) {
            for child in aggregate.providers {
                guard let aggregateSectionOffset = aggregate.sectionOffset(for: child) else {
                    assertionFailure("AggregateSectionProvider should return a value for section offset of child \(child)")
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

extension SectionProviderMapping: SectionUpdateDelegate {
    public func section(_ section: Section, didInsertElementsAt indexSet: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        var indexPaths: [IndexPath] = []

        for index in indexSet {
            guard let indexPath = self.indexPath(for: index, in: section) else { return }
            indexPaths.append(indexPath)
        }

        delegate?.mapping(self, didInsertElementsAt: indexPaths, performUpdate: updatePerformer)
    }

    public func section(_ section: Section, didRemoveElementsAt indexSet: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        var indexPaths: [IndexPath] = []

        for index in indexSet {
            guard let indexPath = self.indexPath(for: index, in: section) else { return }
            indexPaths.append(indexPath)
        }

        delegate?.mapping(self, didRemoveElementsAt: indexPaths, performUpdate: updatePerformer)
    }

    public func section(_ section: Section, didUpdateElementsAt indexSet: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer) {
        var indexPaths: [IndexPath] = []

        for index in indexSet {
            guard let indexPath = self.indexPath(for: index, in: section) else { return }
            indexPaths.append(indexPath)
        }

        delegate?.mapping(self, didUpdateElementsAt: indexPaths, performUpdate: updatePerformer)
    }

    public func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {
        guard let sourceIndexPath = self.indexPath(for: sourceIndex, in: section),
            let destinationIndexPath = self.indexPath(for: destinationIndex, in: section) else {
                return
        }
        delegate?.mapping(self, move: sourceIndexPath, to: destinationIndexPath)
    }
}

/// A convenient wrapper to provide hashability and equality to a section provider for comparison and storage in a `SectionProviderMapping`
private struct HashableProvider: Hashable {

    public static func == (lhs: HashableProvider, rhs: HashableProvider) -> Bool {
        return lhs.provider === rhs.provider
    }

    private let provider: SectionProvider

    public init(_ provider: SectionProvider) {
        self.provider = provider
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(provider))
    }

}
