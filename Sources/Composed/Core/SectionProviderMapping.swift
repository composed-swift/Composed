import UIKit

/// A delegate for responding to mapping updates
public protocol SectionProviderMappingDelegate: AnyObject {

    func mapping(_ mapping: SectionProviderMapping, willPerformBatchUpdates updates: (_ changesReducer: ChangesReducer?) -> Void)

    /// Notifies the delegate that the mapping will being updating
    /// - Parameter mapping: The mapping that provided this update
    func mappingWillBeginUpdating(_ mapping: SectionProviderMapping)

    /// Notifies the delegate that the mapping did end updating
    /// - Parameter mapping: The mapping that provided this update
    func mappingDidEndUpdating(_ mapping: SectionProviderMapping)

    /// Notifies the delegate that the mapping was invalidated
    /// - Parameter mapping: The mapping that provided this update
    func mappingDidInvalidate(_ mapping: SectionProviderMapping)

    /// Notifies the delegate that the mapping did insert sections
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sections: The section indexes
    func mapping(_ mapping: SectionProviderMapping, didInsertSections sections: IndexSet)

    /// Notifies the delegate that the mapping did insert elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didInsertElementsAt indexPaths: [IndexPath])

    /// Notifies the delegate that the mapping did remove sections
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sections: The section indexes
    func mapping(_ mapping: SectionProviderMapping, didRemoveSections sections: IndexSet)

    /// Notifies the delegate that the mapping did remove elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didRemoveElementsAt indexPaths: [IndexPath])

    /// Notifies the delegate that the mapping did update elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didUpdateElementsAt indexPaths: [IndexPath])

    /// Notifies the delegate that the mapping did move elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - moves: The source and target element indexPaths as a tuple
    func mapping(_ mapping: SectionProviderMapping, didMoveElementsAt moves: [(IndexPath, IndexPath)])

    /// Asks the delegate for its selected indexes in the specified section
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - section: The section index
    func mapping(_ mapping: SectionProviderMapping, selectedIndexesIn section: Int) -> [Int]

    /// Asks the delegate to select the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPath: The element indexPath
    func mapping(_ mapping: SectionProviderMapping, select indexPath: IndexPath)

    /// Asks the delegate to deselect the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPath: The element indexPath
    func mapping(_ mapping: SectionProviderMapping, deselect indexPath: IndexPath)

    /// Asks the delegate to move the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sourceIndexPath: The initial indexPath
    ///   - destinationIndexPath: The final indexPath
    func mapping(_ mapping: SectionProviderMapping, move sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)

    /// Notifies the delegate that the section invalidated its header.
    /// - Parameters:
    ///   - sectionIndex: The index of the section that invalidated its header.
    func mappingDidInvalidateHeader(at sectionIndex: Int)

    /// Notifies the delegate that the section invalidated its footer.
    /// - Parameters:
    ///   - sectionIndex: The index of the section that invalidated its footer.
    func mappingDidInvalidateFooter(at sectionIndex: Int)

}

/// An object that encapsulates the logic required to map `SectionProvider`s to a global context,
/// allowing elements in a `Section` to be referenced via an `IndexPath`
public final class SectionProviderMapping: SectionProviderUpdateDelegate, SectionUpdateDelegate {

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

    public func provider(_ provider: SectionProvider, willPerformBatchUpdates updates: (ChangesReducer?) -> Void) {
        if let delegate = delegate {
            delegate.mapping(self, willPerformBatchUpdates: updates)
        } else {
            updates(nil)
        }
    }

    public func willBeginUpdating(_ provider: SectionProvider) {
        delegate?.mappingWillBeginUpdating(self)
    }

    public func didEndUpdating(_ provider: SectionProvider) {
        delegate?.mappingDidEndUpdating(self)
    }

    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        sections.forEach { $0.updateDelegate = self }
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didInsertSections: indexes)
    }

    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        sections.forEach { $0.updateDelegate = nil }
        let indexes = globalIndexes(for: provider, with: indexes)
        delegate?.mapping(self, didRemoveSections: indexes)
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

    public func invalidateAll(_ provider: SectionProvider) {
        delegate?.mappingDidInvalidate(self)
    }

    public func section(_ section: Section, willPerformBatchUpdates updates: (ChangesReducer?) -> Void) {
        if let delegate = delegate {
            delegate.mapping(self, willPerformBatchUpdates: updates)
        } else {
            updates(nil)
        }
    }

    public func willBeginUpdating(_ section: Section) {
        delegate?.mappingWillBeginUpdating(self)
    }

    public func didEndUpdating(_ section: Section) {
        delegate?.mappingDidEndUpdating(self)
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

    public func invalidateAll(_ section: Section) {
        provider.sections.forEach { $0.updateDelegate = self }
        delegate?.mappingDidInvalidate(self)
    }

    public func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {
        guard let sourceIndexPath = self.indexPath(for: sourceIndex, in: section),
            let destinationIndexPath = self.indexPath(for: destinationIndex, in: section) else {
                return
        }
        delegate?.mapping(self, move: sourceIndexPath, to: destinationIndexPath)
    }

    public func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int) {
        guard let source = self.indexPath(for: index, in: section) else { return }
        guard let destination = self.indexPath(for: newIndex, in: section) else { return }
        delegate?.mapping(self, didMoveElementsAt: [(source, destination)])
    }

    public func sectionDidInvalidateHeader(_ section: Section) {
        guard let sectionOffset = self.sectionOffset(of: section) else { return }
        delegate?.mappingDidInvalidateHeader(at: sectionOffset)
    }

    public func sectionDidInvalidateFooter(_ section: Section) {
        guard let sectionOffset = self.sectionOffset(of: section) else { return }
        delegate?.mappingDidInvalidateFooter(at: sectionOffset)
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
                    assertionFailure("AggregateSectionProvider should return a non-nil value for section offset of child \(child)")
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
