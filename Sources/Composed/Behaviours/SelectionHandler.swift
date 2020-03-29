@available(*, deprecated, renamed: "SelectionHandler")
public protocol SelectionProvider: Section { }

public protocol SelectionHandler: Section {
    var allowsMultipleSelection: Bool { get }
    var selectedIndexes: [Int] { get }

    func shouldHighlight(at index: Int) -> Bool
    func shouldSelect(at index: Int) -> Bool
    func didSelect(at index: Int)

    func shouldDeselect(at index: Int) -> Bool
    func didDeselect(at index: Int)

    func select(index: Int)
    func deselect(index: Int)

    func selectAll()
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
