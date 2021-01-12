import Foundation

/// A section that flattens each of its children in to a single section.
open class FlatSection: Section, CustomReflectable {
    private enum Child {
        /// A single section.
        case section(Section)

        /// An object that provides 0 or more sections.
        case sectionProvider(SectionProvider)
    }

    public private(set) var sections: ContiguousArray<Section> = []

    public var numberOfElements: Int {
        sections.map(\.numberOfElements).reduce(0, +)
    }

    public weak var updateDelegate: SectionUpdateDelegate?

    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "children": children,
            ]
        )
    }

    private var children: [Child] = []

    public init() {}

    public func append(_ section: Section) {
        updateDelegate?.willBeginUpdating(self)

        let indexOfFirstChildElement = numberOfElements
        children.append(.section(section))
        sections.append(section)
        section.updateDelegate = self

        (0..<section.numberOfElements)
            .map { $0 + indexOfFirstChildElement }
            .forEach { index in
                updateDelegate?.section(self, didInsertElementAt: index)
            }

        updateDelegate?.didEndUpdating(self)
    }

    public func append(_ sectionProvider: SectionProvider) {
        updateDelegate?.willBeginUpdating(self)

        var indexOfFirstSectionElement = numberOfElements

        children.append(.sectionProvider(sectionProvider))
        sections.append(contentsOf: sectionProvider.sections)

        sectionProvider.sections.forEach { section in
            (0..<section.numberOfElements)
                .map { $0 + indexOfFirstSectionElement }
                .forEach { index in
                    updateDelegate?.section(self, didInsertElementAt: index)
                }

            indexOfFirstSectionElement += section.numberOfElements
        }

        sectionProvider.updateDelegate = self

        updateDelegate?.didEndUpdating(self)
    }

    public func insert(_ section: Section, at childIndex: Int) {
        updateDelegate?.willBeginUpdating(self)

        let elementOffset: Int = {
            if childIndex == 0 {
                return 0
            } else if childIndex == children.count {
                return self.numberOfElements
            }

            let childAtInsertedSection = children[childIndex]
            return indexForFirstElement(of: childAtInsertedSection)!
        }()

        let indexInSectionArray = (0..<childIndex).map { children[$0] }.reduce(into: 0) { index, child in
            switch child {
            case .section:
                index += 1
            case .sectionProvider(let sectionProvider):
                index += sectionProvider.numberOfSections
            }
        }

        sections.insert(section, at: indexInSectionArray)
        children.insert(.section(section), at: childIndex)
        section.updateDelegate = self

        (0..<section.numberOfElements)
            .map { $0 + elementOffset }
            .forEach { index in
                updateDelegate?.section(self, didInsertElementAt: index)
            }

        updateDelegate?.didEndUpdating(self)
    }

    public func insert(_ section: Section, after existingSection: Section) {
        guard let existingSectionIndex = childIndex(of: existingSection) else { return }

        insert(section, at: existingSectionIndex + 1)
    }

    public func remove(_ section: Section) {
        guard let childIndex = childIndex(of: section) else { return }

        updateDelegate?.willBeginUpdating(self)

        let sectionOffset = indexForFirstElement(of: section)!
        children.remove(at: childIndex)
        sections = sections.filter { $0 !== section }
        if section.updateDelegate === self {
            section.updateDelegate = nil
        }

        (0..<section.numberOfElements).reversed().forEach { index in
            updateDelegate?.section(self, didRemoveElementAt: index + sectionOffset)
        }

        updateDelegate?.didEndUpdating(self)
    }

    public func remove(_ sectionProvider: SectionProvider) {
        guard let childIndex = self.childIndex(of: sectionProvider) else { return }

        updateDelegate?.willBeginUpdating(self)
        sectionProvider.sections.reversed().forEach { section in
            let sectionOffset = indexForFirstElement(of: section)!
            sections = sections.filter { $0 !== section }

            (0..<section.numberOfElements).reversed().forEach { index in
                updateDelegate?.section(self, didRemoveElementAt: index + sectionOffset)
            }
        }

        children.remove(at: childIndex)

        updateDelegate?.didEndUpdating(self)
    }

    public func sectionForElementIndex(_ index: Int) -> (section: Section, offset: Int)? {
        var offset = 0

        for child in children {
            switch child {
            case .section(let section):
                if !section.isEmpty, offset == index {
                    return (section, offset)
                } else if index < offset + section.numberOfElements {
                    return (section, offset)
                }

                offset += section.numberOfElements
            case .sectionProvider(let sectionProvider):
                for section in sectionProvider.sections {
                    if !section.isEmpty, offset == index {
                        return (section, offset)
                    } else if index < offset + section.numberOfElements {
                        return (section, offset)
                    }

                    offset += section.numberOfElements
                }
            }
        }

        return nil
    }

    public final func indexForFirstElement(of section: Section) -> Int? {
        var offset = 0

        for childSection in sections {
            if childSection === section {
                return offset
            }

            offset += childSection.numberOfElements
        }

        return nil
    }

    public final func indexForFirstElement(of sectionProvider: SectionProvider) -> Int? {
        var offset = 0

        for child in children {
            switch child {
            case .section(let section):
                offset += section.numberOfElements
            case .sectionProvider(let childSectionProvider):
                if childSectionProvider === sectionProvider {
                    return offset
                } else if let aggregate = childSectionProvider as? AggregateSectionProvider, let sectionOffset = aggregate.sectionOffset(for: sectionProvider) {
                    return childSectionProvider.sections[0..<sectionOffset].reduce(into: offset, { $0 += $1.numberOfElements })
                }

                offset += childSectionProvider.sections.reduce(into: 0, { $0 += $1.numberOfElements })
            }
        }

        return nil
    }

    public final func indexesRange(for section: Section) -> Range<Int>? {
        guard let sectionOffset = indexForFirstElement(of: section) else { return nil }
        return (sectionOffset..<sectionOffset + section.numberOfElements)
    }

    public final func childIndex(of section: Section) -> Int? {
        var index = 0

        for child in children {
            switch child {
            case .section(let childSection):
                if childSection === section {
                    return index
                }
            case .sectionProvider:
                break
            }

            index += 1
        }

        return nil
    }

    public final func childIndex(of sectionProvider: SectionProvider) -> Int? {
        var index = 0

        for child in children {
            switch child {
            case .section:
                break
            case .sectionProvider(let childSectionProvider):
                if childSectionProvider === sectionProvider {
                    return index
                }
            }

            index += 1
        }

        return nil
    }

    private func indexForFirstElement(of child: Child) -> Int? {
        switch child {
        case .section(let childSection):
            return indexForFirstElement(of: childSection)
        case .sectionProvider(let sectionProvider):
            return indexForFirstElement(of: sectionProvider)
        }
    }

    /// The index of the first section of `sectionProvider` in the `sections` array.
    ///
    /// - parameter sectionProvider: The section provider to calculate the section index of.
    /// - returns: The index of the first section of `sectionProvider` in the `sections` array, or `nil` if it is not in the hierarchy.
    private func sectionIndex(of sectionProvider: SectionProvider) -> Int? {
        var index = 0

        for child in children {
            switch child {
            case .section:
                index += 1
            case .sectionProvider(let childSectionProvider):
                if childSectionProvider === sectionProvider {
                    return index
                } else if let aggregate = childSectionProvider as? AggregateSectionProvider, let offset = aggregate.sectionOffset(for: sectionProvider) {
                    return index + offset
                }

                index += childSectionProvider.numberOfSections
            }
        }

        return nil
    }
}

extension FlatSection: SectionUpdateDelegate {
    public func willBeginUpdating(_ section: Section) {
        updateDelegate?.willBeginUpdating(self)
    }

    public func didEndUpdating(_ section: Section) {
        updateDelegate?.didEndUpdating(self)
    }

    public func invalidateAll(_ section: Section) {
        updateDelegate?.invalidateAll(self)
    }

    public func section(_ section: Section, didInsertElementAt index: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, didInsertElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didRemoveElementAt index: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, didRemoveElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didUpdateElementAt index: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, didUpdateElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, didMoveElementAt: sectionOffset + index, to: newIndex + index)
    }

    public func selectedIndexes(in section: Section) -> [Int] {
        guard let allSelectedIndexes = updateDelegate?.selectedIndexes(in: self) else { return [] }
        guard let sectionIndexes = indexesRange(for: section) else { return [] }

        return allSelectedIndexes
            .filter(sectionIndexes.contains(_:))
            .map { $0 - sectionIndexes.startIndex }
    }

    public func section(_ section: Section, select index: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, select: sectionOffset + index)
    }

    public func section(_ section: Section, deselect index: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, deselect: sectionOffset + index)
    }

    public func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {
        guard let sectionOffset = indexForFirstElement(of: section) else { return }
        updateDelegate?.section(self, move: sourceIndex + sectionOffset, to: destinationIndex + sectionOffset)
    }

    public func sectionDidInvalidateHeader(_ section: Section) {
        // Headers of children are currently ignored.
    }
}

extension FlatSection: SectionProviderUpdateDelegate {
    public func willBeginUpdating(_ provider: SectionProvider) {
        updateDelegate?.willBeginUpdating(self)
    }

    public func didEndUpdating(_ provider: SectionProvider) {
        updateDelegate?.didEndUpdating(self)
    }

    public func invalidateAll(_ provider: SectionProvider) {
        sections = ContiguousArray(children.flatMap { child -> [Section] in
            switch child {
            case .section(let section):
                return [section]
            case .sectionProvider(let sectionProvider):
                return sectionProvider.sections
            }
        })
        updateDelegate?.invalidateAll(self)
    }

    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        guard let providerSectionIndex = sectionIndex(of: provider) else {
            assertionFailure(#function + " has been called for a provider that is not a child")
            return
        }

        updateDelegate?.willBeginUpdating(self)

        for (section, index) in zip(sections, indexes) {
            let sectionIndex = index + providerSectionIndex
            self.sections.insert(section, at: sectionIndex)
            let firstSectionIndex = self.indexForFirstElement(of: section)!

            (firstSectionIndex..<firstSectionIndex + section.numberOfElements).forEach { elementIndex in
                updateDelegate?.section(self, didInsertElementAt: elementIndex)
            }
        }

        updateDelegate?.didEndUpdating(self)
    }

    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        guard let providerSectionIndex = sectionIndex(of: provider) else {
            assertionFailure(#function + " has been called for a provider that is not a child")
            return
        }

        updateDelegate?.willBeginUpdating(self)

        for (section, sectionIndexInProvider) in zip(sections, indexes).reversed() {
            let localSectionIndex = sectionIndexInProvider + providerSectionIndex
            let sectionFirstElementIndex = self.indexForFirstElement(of: section)!

            if section.updateDelegate === self {
                section.updateDelegate = nil
            }

            self.sections.remove(at: localSectionIndex)

            (sectionFirstElementIndex..<sectionFirstElementIndex + section.numberOfElements).reversed().forEach { elementIndex in
                updateDelegate?.section(self, didRemoveElementAt: elementIndex)
            }
        }

        updateDelegate?.didEndUpdating(self)
    }
}
