import Foundation

public protocol EditingHandler: Section {
    var editingIndexes: [Int] { get }
    func allowsEditing(at index: Int) -> Bool
    func setEditing(_ editing: Bool)
    func setEditing(_ editing: Bool, at index: Int)
}

public extension EditingHandler {
    var editingIndexes: [Int] {
        var indexes: [Int] = []
        for index in 0..<numberOfElements {
            guard allowsEditing(at: index) else { continue }
            indexes.append(index)
        }
        return indexes
    }

    func allowsEditing(at index: Int) -> Bool { return true }
    func setEditing(_ editing: Bool, at index: Int) { }
}
