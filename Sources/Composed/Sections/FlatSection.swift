/// A section that flattens each of its children in to a single section.
open class FlatSection: Section {
    open private(set) var children: [Section] = []

    public var numberOfElements: Int {
        children.map(\.numberOfElements).reduce(0, +)
    }

    public var updateDelegate: SectionUpdateDelegate?

    public func append(_ section: Section) {
        updateDelegate?.willBeginUpdating(self)

        let indexOfFirstChildElement = numberOfElements
        children.append(section)

        (0..<section.numberOfElements)
            .map { $0 + indexOfFirstChildElement }
            .forEach { index in
                updateDelegate?.section(self, didInsertElementAt: index)
            }

        updateDelegate?.didEndUpdating(self)
    }

    public func section(at index: Int) -> (section: Section, offset: Int)? {
        var offset = 0

        for child in children {
            if index <= offset + child.numberOfElements {
                return (child, offset)
            }

            offset += child.numberOfElements
        }

        return nil
    }

    private func offset(for section: Section) -> Int? {
        var offset = 0

        for child in children {
            if child === section {
                return offset
            }

            offset += child.numberOfElements
        }

        return nil
    }

    private func indexesRange(for section: Section) -> Range<Int>? {
        guard let sectionOffset = offset(for: section) else { return nil }
        return (sectionOffset..<sectionOffset + section.numberOfElements)
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
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, didInsertElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didRemoveElementAt index: Int) {
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, didRemoveElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didUpdateElementAt index: Int) {
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, didUpdateElementAt: sectionOffset + index)
    }

    public func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int) {
        guard let sectionOffset = offset(for: section) else { return }
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
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, select: sectionOffset + index)
    }

    public func section(_ section: Section, deselect index: Int) {
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, deselect: sectionOffset + index)
    }

    public func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {
        guard let sectionOffset = offset(for: section) else { return }
        updateDelegate?.section(self, move: sourceIndex + sectionOffset, to: destinationIndex + sectionOffset)
    }
}
