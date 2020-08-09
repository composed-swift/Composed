import UIKit

/// Provides element move handling for a `Section`
#warning("todo: Refactor MoveHandler into a protocol that augments drag and drop handlers")
public protocol MoveHandler: Section {

    var allowsReorder: Bool { get }

    /// When a move occurs, this method will be called to notify the section
    /// - Parameters:
    ///   - sourceIndex: The initial source index of the element
    ///   - destinationIndex: The final destination index of the element
    func didMove(sourceIndexes: IndexSet, to destinationIndex: Int)

}
