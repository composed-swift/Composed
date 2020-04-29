import Foundation

/// Provides edit handling for a Section
public protocol EditingHandler: Section {

    /// Returns all element indexes that have allowed editing
    var editingIndexes: [Int] { get }

    /// Return `true` to allow editing for the element at the specified index, defaults to `true`
    /// - Parameter index: The index to query
    func allowsEditing(at index: Int) -> Bool

    /// When editing is toggled, this method will be called to notify the section
    /// - Parameter editing: True if editing is being enabled, false otherwise
    func didSetEditing(_ editing: Bool)

    /// When editing is toggled, this method will be called for every element in this section
    /// - Parameters:
    ///   - editing: True if editing is being enabled, false otherwise
    ///   - index: The element index
    func didSetEditing(_ editing: Bool, at index: Int)

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
    func didSetEditing(_ editing: Bool, at index: Int) { }
    
}
