import XCTest
import Composed
@testable import ComposedUI

final class CollectionCoordinatorTests: XCTestCase {
    /// A series of updates that are performed in batch. This isn't testing `CollectionCoordinator` as much as
    /// it tests `ChangesReducer`. These tests are closer to end-to-end tests, essentially testing that the updates from
    /// sections are correctly passed up to the `ChangesReducer`, and that the `ChangesReducer` provides the correct updates
    /// to `UICollectionView`.
    ///
    /// One way for these tests to fail is by `UICollectionView` throwing a `NSInternalInconsistencyException', reason: 'Invalid update...'`
    /// error, which would likely indicate an error in `ChangesReducer`.
    ///
    /// It may also fail without throwing an exception, instead logging: `Invalid update: invalid ... - will perform reloadData`.
    func testBatchUpdates() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let rootSectionProvider = ComposedSectionProvider()
        let collectionCoordinator = CollectionCoordinator(collectionView: collectionView, sectionProvider: rootSectionProvider)
        collectionCoordinator.enableLogs = true

        let child0 = MockCollectionArraySection([])
        let child1 = MockCollectionArraySection(["1"])
        let child2 = MockCollectionArraySection(["1", "2"])
        let child3 = MockCollectionArraySection(["1", "2", "3", "4"])
        var child4 = MockCollectionArraySection(["1", "2", "3", "4", "5"])

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        rootSectionProvider.append(child0)
        rootSectionProvider.append(child1)
        rootSectionProvider.append(child2)
        rootSectionProvider.append(child3)
        rootSectionProvider.append(child4)

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        rootSectionProvider.remove(child3)
        rootSectionProvider.remove(child0)
        rootSectionProvider.remove(child1)
        rootSectionProvider.remove(child2)
        rootSectionProvider.remove(child4)

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        rootSectionProvider.append(child0)
        rootSectionProvider.remove(child0)
        rootSectionProvider.append(child0)
        rootSectionProvider.append(child1)
        rootSectionProvider.append(child2)
        rootSectionProvider.append(child3)
        rootSectionProvider.append(child4)
        rootSectionProvider.remove(child2)

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        child3.append("5")
        rootSectionProvider.insert(child2, after: child1)
        child3.append("6")

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        // TODO: Uncommenting any of these will cause a crash/log an error
        rootSectionProvider.remove(child0)
//        child3.remove(at: 1)
//        child4.swapAt(0, 2)
        rootSectionProvider.remove(child2)
        child4.append("6")
        rootSectionProvider.remove(child0)
//        child4.remove(at: 1)
        rootSectionProvider.remove(child1)
        rootSectionProvider.insert(child0, at: 0)

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)
    }
}

private final class MockCollectionArraySection: ArraySection<String>, SingleUICollectionViewSection {
    func section(with traitCollection: UITraitCollection) -> CollectionSection {
        let cell = CollectionCellElement(section: self, dequeueMethod: .fromClass(UICollectionViewCell.self), configure: { _, _, _ in })
        return CollectionSection(section: self, cell: cell)
    }
}
