import Foundation

/// Provides selection handling for a section
public protocol SelectionHandler: Section {

    /// Return `true` to allow multiple selection in this section, defaults to `false`
    var allowsMultipleSelection: Bool { get }

    /// Returns all element indexes that are currently selected
    var selectedIndexes: [Int] { get }

    /// When a highlight is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    func shouldHighlight(at index: Int) -> Bool

    /// When a selection is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    func shouldSelect(at index: Int) -> Bool

    /// When a selection occurs, this method will be called to notify the section
    /// - Parameter index: The element index
    func didSelect(at index: Int)

    /// When a deselection is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    func shouldDeselect(at index: Int) -> Bool

    /// When a deselection occurs, this method will be called to notify the section
    /// - Parameter index: The element index
    func didDeselect(at index: Int)

    /// Selects the element at the specified index
    /// - Parameter index: The element index
    func select(index: Int)

    /// Deselects the element at the specified index
    /// - Parameter index: The element index
    func deselect(index: Int)

    /// Selects all elements in this section
    func selectAll()

    /// Deselects all elements in this section
    func deselectAll()

}

public extension SelectionHandler {
    var allowsMultipleSelection: Bool { return false }
    var selectedIndexes: [Int] { return updateDelegate?.selectedIndexes(in: self) ?? [] }

    func shouldHighlight(at index: Int) -> Bool { return true }
    func shouldSelect(at index: Int) -> Bool { return true }
    func didSelect(at index: Int) { deselect(index: index) }

    func shouldDeselect(at index: Int) -> Bool { return true }
    func didDeselect(at index: Int) { }

    func select(index: Int) { updateDelegate?.section(self, select: index) }
    func deselect(index: Int) { updateDelegate?.section(self, deselect: index) }

    func selectAll() {
        (0..<numberOfElements).forEach { select(index: $0) }
    }

    func deselectAll() {
        (0..<numberOfElements).forEach { deselect(index: $0) }
    }
}

public extension SelectionHandler where Self: EditingHandler {
    func shouldHighlight(at index: Int) -> Bool {
        if allowsMultipleSelection {
            return allowsEditing(at: index)
        } else {
            return true
        }
    }
}
