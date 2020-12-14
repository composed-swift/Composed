import UIKit

/// Provides element move handling for a `Section`
public protocol MoveHandler: Section {

    func canMove(index: Int) -> Bool
    func targetIndex(sourceIndex: Int, proposedIndex: Int) -> Int

    /// When a move occurs, this method will be called to notify the section
    /// - Parameters:
    ///   - sourceIndex: The initial source index of the element
    ///   - destinationIndex: The final destination index of the element
    func didMove(sourceIndexes: IndexSet, to destinationIndex: Int)

}

public extension MoveHandler {
    func canMove(index: Int) -> Bool { return true }
    func targetIndex(sourceIndex: Int, proposedIndex: Int) -> Int {
        return proposedIndex
    }
}
