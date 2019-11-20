import Foundation

public protocol EditProvider: Section {
    var isEditing: Bool { get }

    func allowsEditing(at index: Int) -> Bool
    func setEditing(_ isEditing: Bool, at index: Int)
}

public extension EditProvider {
    var allowsMultipleSelection: Bool { return false }
    var selectedIndexes: [Int] { return updateDelegate?.selectedIndexes(in: self) ?? [] }

    func shouldHighlight(at index: Int) -> Bool { return true }
    func shouldSelect(at index: Int) -> Bool { return true }
    func didSelect(at index: Int) { }

    func shouldDeselect(at index: Int) -> Bool { return true }
    func didDeselect(at index: Int) { }

    func select(index: Int) { updateDelegate?.section(self, select: index) }
    func deselect(index: Int) { updateDelegate?.section(self, deselect: index) }
}

