import UIKit

/// Provides element move handling for a `Section`
public protocol MoveHandler: Section {

    /// When a move is attempted, this method will be called giving the caller a chance to prevent it
    /// - Parameter index: The element index
    func canMove(at index: Int) -> Bool

    /// When a move is attempted, this method will be called giving the caller a chance to update the proposed target index
    /// - Parameter proposedIndex: The proposed index where this element should be moved to
    func targetIndex(for proposedIndex: Int) -> Int

    /// When a move occurs, this method will be called to notify the section
    /// - Parameters:
    ///   - sourceIndex: The initial source index of the element
    ///   - destinationIndex: The final destination index of the element
    func didMove(from sourceIndex: Int, to destinationIndex: Int)

}

public extension MoveHandler {

    func canMove(at index: Int) -> Bool { return true }
    func targetIndex(for proposedIndex: Int) -> Int { return proposedIndex }

}
