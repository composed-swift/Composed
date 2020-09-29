import Foundation

/// A delegate for responding to mapping updates. Updates will be stored and _could_ be performed
/// in the future to allow multiple updates to occur at once. This will occur when
/// `mappingWillBeginUpdating` is called multiple times before `mappingDidEndUpdating` is called.
public protocol SectionProviderMappingDelegate: class {
    /// A closure that will be called synchronously on the main thread. It must perform the updates
    /// associated with the mapping change before returning.
    typealias UpdatePerformer = () -> Void

    /// Notifies the delegate that the mapping will being updating
    /// - Parameter mapping: The mapping that provided this update
    func mappingWillBeginUpdating(_ mapping: SectionProviderMapping)

    /// Notifies the delegate that the mapping did end updating
    /// - Parameter mapping: The mapping that provided this update
    func mappingDidEndUpdating(_ mapping: SectionProviderMapping)

    /// Notifies the delegate that the mapping was invalidated
    /// - Parameter mapping: The mapping that provided this update
    func mappingDidInvalidate(_ mapping: SectionProviderMapping, performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did insert sections
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sections: The section indexes
    func mapping(_ mapping: SectionProviderMapping, didInsertSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did insert elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didInsertElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did remove sections
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sections: The section indexes
    func mapping(_ mapping: SectionProviderMapping, didRemoveSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did remove elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didRemoveElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did update sections
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sections: The section indexes
    func mapping(_ mapping: SectionProviderMapping, didUpdateSections sections: IndexSet, performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did update elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPaths: The element indexPaths
    func mapping(_ mapping: SectionProviderMapping, didUpdateElementsAt indexPaths: [IndexPath], performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Notifies the delegate that the mapping did move elements
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - moves: The source and target element indexPaths as a tuple
    func mapping(_ mapping: SectionProviderMapping, didMoveElementsAt moves: [(IndexPath, IndexPath)], performUpdate updatePerformer: @escaping UpdatePerformer)

    /// Asks the delegate for its selected indexes in the specified section
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - section: The section index
    func mapping(_ mapping: SectionProviderMapping, selectedIndexesIn section: Int) -> [Int]

    /// Asks the delegate to select the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPath: The element indexPath
    func mapping(_ mapping: SectionProviderMapping, select indexPath: IndexPath)

    /// Asks the delegate to deselect the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - indexPath: The element indexPath
    func mapping(_ mapping: SectionProviderMapping, deselect indexPath: IndexPath)

    /// Asks the delegate to move the specified indexPath
    /// - Parameters:
    ///   - mapping: The mapping that provided this update
    ///   - sourceIndexPath: The initial indexPath
    ///   - destinationIndexPath: The final indexPath
    func mapping(_ mapping: SectionProviderMapping, move sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)

}
