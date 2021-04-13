import Foundation
import CoreGraphics

/// Represents a single section of data.
public protocol Section: AnyObject {

    /// The number of elements in this section
    var numberOfElements: Int { get }

    /// The delegate that will respond to updates
    var updateDelegate: SectionUpdateDelegate? { get set }

}

public extension Section {

    /// Returns true if the section contains no elements, false otherwise
    var isEmpty: Bool { return numberOfElements == 0 }

    /// Perform multiple updates in a single batch, ensuring a single layout pass and animation is used for all updates.
    ///
    /// Changes will be reduced in to the minimal total changes required, based on the calls made to the `updateDelegate`. If
    /// no `updateDelegate` has been set the `updates` closure is called with `nil`, allowing changes to still be made.
    ///
    /// Some updates are not correct reduced, or you may wish to avoid this batching behaviour. To enable this the `forceReloadData`
    /// parameter can be set to `true`. Note that passing `true` is not supported if another batch updates that does not force reload
    /// data is currently being performed.
    ///
    /// - Parameter forceReloadData: If `true` all updates will be ignored and `reloadData` will be called after all updates are applied.
    /// - Parameter updates: A closure that applies the updates.
    func performBatchUpdates(forceReloadData: Bool = false, _ updates: (_ updateDelegate: SectionUpdateDelegate?) -> Void) {
        if let updateDelegate = updateDelegate {
            updateDelegate.section(self, willPerformBatchUpdates: {
                updates(updateDelegate)
            }, forceReloadData: forceReloadData)
        } else {
            updates(nil)
        }
    }

}

/// A delegate that will respond to update events from a `Section`
public protocol SectionUpdateDelegate: AnyObject {
    /// Notifies the delegate that the section will perform a series of updates.
    ///
    /// The delegate must call the `updates` closure synchronously.
    ///
    /// - Parameter section: The section that will be updated.
    /// - Parameter updates: A closure that will perform the updates.
    func section(_ section: Section, willPerformBatchUpdates updates: () -> Void, forceReloadData: Bool)

    /// Notifies the delegate that all sections should be invalidated, ignoring individual updates
    /// - Parameter section: The section that requested the invalidation
    func invalidateAll(_ section: Section)

    /// Notifies the delegate that an element was inserted
    /// - Parameters:
    ///   - section: The section where the insert occurred
    ///   - index: The index of the element that was inserted
    func section(_ section: Section, didInsertElementAt index: Int)

    /// Notifies the delegate that an element was removed
    /// - Parameters:
    ///   - section: The section where the remove occurred
    ///   - index: The index of the element that was removed
    func section(_ section: Section, didRemoveElementAt index: Int)

    /// Notifies the delegate that an element was updated
    /// - Parameters:
    ///   - section: The section where the update occurred
    ///   - index: The index of the element that was updated
    func section(_ section: Section, didUpdateElementAt index: Int)

    /// Notifies the delegate that an element was moved
    /// - Parameters:
    ///   - section: The section where the move occurred
    ///   - index: The source index of the element that was moved
    ///   - newIndex: The target index of the element that was moved
    func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int)

    /// Returns the currently selected indexes in the specified section
    /// - Parameter section: The section to query
    func selectedIndexes(in section: Section) -> [Int]

    /// Notifies the delegate that the specified index in the given section should be selected
    /// - Parameters:
    ///   - section: The section where the selection should be performed
    ///   - index: The index of the element that should be selected
    func section(_ section: Section, select index: Int)

    /// Notifies the delegate that the specified index in the given section should be deselected
    /// - Parameters:
    ///   - section: The section where the deselection should be performed
    ///   - index: The index of the element that should be deselected
    func section(_ section: Section, deselect index: Int)

    /// Notifies the delegate that the source index should be moved to the destination index
    /// - Parameters:
    ///   - section: The section where the move should be performed
    ///   - sourceIndex: The initial index where the element will be moved from
    ///   - destinationIndex: The final index where the element will be moved to
    func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int)

    /// Notifies the delegate that the section invalidated its header.
    /// - Parameters:
    ///   - section: The section that invalidated its header.
    func sectionDidInvalidateHeader(_ section: Section)

    /// Notifies the delegate that the section invalidated its footer.
    /// - Parameters:
    ///   - section: The section that invalidated its footer.
    func sectionDidInvalidateFooter(_ section: Section)
}
