public protocol SelectionProvider: Section {
    var allowsMultipleSelection: Bool { get }

    func shouldHighlight(at index: Int) -> Bool
    func shouldSelect(at index: Int) -> Bool
    func didSelect(at index: Int)

    func shouldDeselect(at index: Int) -> Bool
    func didDeselect(at index: Int)
}

public extension SelectionProvider {
    var allowsMultipleSelection: Bool { return false }
    func shouldHighlight(at index: Int) -> Bool { return true }
    func shouldSelect(at index: Int) -> Bool { return true }
    func shouldDeselect(at index: Int) -> Bool { return true }
    func didDeselect(at index: Int) { return }

}
