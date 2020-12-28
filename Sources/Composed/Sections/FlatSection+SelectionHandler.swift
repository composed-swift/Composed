extension FlatSection: SelectionHandler {
    public final var selectionHandlingSections: [SelectionHandler] {
        children.compactMap { $0 as? SelectionHandler }
    }

    open var allowsMultipleSelection: Bool {
        let selectionHandlingSection = children.compactMap { $0 as? SelectionHandler }
        if selectionHandlingSection.isEmpty {
            return false
        } else if selectionHandlingSection.count == 1 {
            return selectionHandlingSection.first!.allowsMultipleSelection
        } else {
            return true
        }
    }

    /// Returns all element indexes that are currently selected
    open var selectedIndexes: [Int] {
        return children.flatMap { section -> [Int] in
            guard let section = section as? SelectionHandler else { return [] }
            let offset = self.offset(for: section)!
            return section.selectedIndexes.map { $0 + offset }
        }
    }

    /// When a highlight is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    open func shouldHighlight(at index: Int) -> Bool {
        guard let sectionMeta = self.section(at: index) else { return false }
        guard let section = sectionMeta.section as? SelectionHandler else { return false }

        let sectionIndex = index - sectionMeta.offset
        return section.shouldHighlight(at: sectionIndex)
    }

    /// When a selection is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    open func shouldSelect(at index: Int) -> Bool {
        guard let sectionMeta = self.section(at: index) else { return false }
        guard let section = sectionMeta.section as? SelectionHandler else { return false }

        let sectionIndex = index - sectionMeta.offset
        return section.shouldSelect(at: sectionIndex)
    }

    /// When a selection occurs, this method will be called to notify the section
    /// - Parameter index: The element index
    open func didSelect(at index: Int) {
        guard let sectionMeta = self.section(at: index) else { return }
        guard let section = sectionMeta.section as? SelectionHandler else { return }

        let sectionIndex = index - sectionMeta.offset
        section.didSelect(at: sectionIndex)
    }

    /// When a deselection is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    open func shouldDeselect(at index: Int) -> Bool {
        guard let sectionMeta = self.section(at: index) else { return false }
        guard let section = sectionMeta.section as? SelectionHandler else { return false }

        let sectionIndex = index - sectionMeta.offset
        return section.shouldDeselect(at: sectionIndex)
    }

    /// When a deselection occurs, this method will be called to notify the section
    /// - Parameter index: The element index
    open func didDeselect(at index: Int) {
        guard let sectionMeta = self.section(at: index) else { return }
        guard let section = sectionMeta.section as? SelectionHandler else { return }

        let sectionIndex = index - sectionMeta.offset
        return section.didDeselect(at: sectionIndex)
    }

    /// Selects the element at the specified index
    /// - Parameter index: The element index
    open func select(index: Int) {
        guard let sectionMeta = self.section(at: index) else { return }
        guard let section = sectionMeta.section as? SelectionHandler else { return }

        let sectionIndex = index - sectionMeta.offset
        section.select(index: sectionIndex)
    }

    /// Deselects the element at the specified index
    /// - Parameter index: The element index
    open func deselect(index: Int) {
        guard let sectionMeta = self.section(at: index) else { return }
        guard let section = sectionMeta.section as? SelectionHandler else { return }

        let sectionIndex = index - sectionMeta.offset
        section.deselect(index: sectionIndex)
    }

    /// Selects all elements in this section
    open func selectAll() {
        selectionHandlingSections.forEach { $0.selectAll() }
    }

    /// Deselects all elements in this section
    open func deselectAll() {
        selectionHandlingSections.forEach { $0.deselectAll() }
    }
}
