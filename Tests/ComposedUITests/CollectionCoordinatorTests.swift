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
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child2)
            sections.rootSectionProvider.append(sections.child3)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 3
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }

        /**
         - Child 1
         - Child 2
         - Child 3
         */

        tester.applyUpdate { sections in
            sections.child2.swapAt(0, 3)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child0, at: 0)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 3
         */

        tester.applyUpdate { sections in
            sections.child0.append("new-0")
        }

        tester.applyUpdate { sections in
            sections.child2[1] = "new-1"
        }

        tester.applyUpdate { sections in
            sections.child2[2] = "new-2"
        }

//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.remove(sections.child3)
//        }

        /**
         - Child 0
         - Child 1
         - Child 2
         */

//        tester.applyUpdate { sections in
//            sections.child2.append("appended")
//        }
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.insert(sections.child4, at: 1)
//        }
//
//        /**
//         - Child 0
//         - Child 4
//         - Child 1
//         - Child 2
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.append(sections.child6)
//        }
//
//        /**
//         - Child 0
//         - Child 4
//         - Child 1
//         - Child 2
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.insert(sections.child5, before: sections.child6)
//        }
//
//        /**
//         - Child 0
//         - Child 4
//         - Child 1
//         - Child 2
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.remove(sections.child4)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 2
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.insert(sections.child4, before: sections.child5)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 2
//         - Child 4
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.insert(sections.child3, before: sections.child4)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 2
//         - Child 3
//         - Child 4
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.child3.remove(at: 2)
//        }
//
//        tester.applyUpdate { sections in
//            sections.child3.insert("new-2", at: 2)
//        }
//
//        tester.applyUpdate { sections in
//            sections.child3.insert("new-3", at: 3)
//        }
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.remove(sections.child2)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 3
//         - Child 4
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.remove(sections.child3)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 4
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.rootSectionProvider.insert(sections.child2, at: 2)
//        }
//
//        /**
//         - Child 0
//         - Child 1
//         - Child 2
//         - Child 4
//         - Child 5
//         - Child 6
//         */
//
//        tester.applyUpdate { sections in
//            sections.child5.swapAt(0, 8)
//        }
//
//        tester.applyUpdate { sections in
//            sections.child2.swapAt(0, 3)
//        }
    }

    func testBatchedSectionRemovals() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child2)
            sections.rootSectionProvider.append(sections.child3)
            sections.rootSectionProvider.append(sections.child4)
            sections.rootSectionProvider.append(sections.child5)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 3
         - Child 4
         - Child 5
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child3)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child5)
        }

        /**
         - Child 1
         - Child 2
         - Child 4
         */

        tester.applyUpdate { sections in
            _ = sections.child4.remove(at: 0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child4)
        }

        tester.applyUpdate { sections in
            sections.child4.append("appended")
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child1)
        }
    }

    func testInsertInToSectionAfterInsertion() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child3)
        }

        tester.applyUpdate { sections in
            sections.child0.append("new-element")
        }

        tester.applyUpdate { sections in
            sections.child3.append("new-element")
        }

        /**
         - Child 0
         - Child 1
         - Child 3
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child2, after: sections.child1)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 3
         */

        tester.applyUpdate { sections in
            sections.child0.append("new-element")
        }

        tester.applyUpdate { sections in
            sections.child3.append("new-element")
        }
    }
}

private final class MockCollectionArraySection: ArraySection<String>, SingleUICollectionViewSection {
    func section(with traitCollection: UITraitCollection) -> CollectionSection {
        let cell = CollectionCellElement(section: self, dequeueMethod: .fromClass(UICollectionViewCell.self), configure: { _, _, _ in })
        return CollectionSection(section: self, cell: cell)
    }
}

private final class TestSections {
    let rootSectionProvider = ComposedSectionProvider()

    let child0 = MockCollectionArraySection([])
    let child1 = MockCollectionArraySection(["1"])
    var child2 = MockCollectionArraySection(["1", "2", "3", "4"])
    let child3 = MockCollectionArraySection(["1", "2", "3"])
    let child4 = MockCollectionArraySection(["1", "2", "3", "4", "5"])
    var child5 = MockCollectionArraySection(["1", "2", "3", "4", "5", "6", "7", "8", "9"])
    let child6 = MockCollectionArraySection([])
}

private final class Tester {
    typealias Updater = (TestSections) -> Void

    private var updaters: [Updater] = []

    private var sections: TestSections

    private let initialState: Updater

    private var collectionViews: [UICollectionView] = []

    init(initialState: @escaping Updater) {
        self.initialState = initialState
        
        sections = TestSections()
    }

    func applyUpdate(_ updater: @escaping Updater) {
        updaters.append(updater)
        sections = TestSections()
        initialState(sections)

        let rootSectionProvider = sections.rootSectionProvider

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionViews.append(collectionView)

        let collectionCoordinator = CollectionCoordinator(collectionView: collectionView, sectionProvider: rootSectionProvider)
        collectionCoordinator.enableLogs = true
        collectionView.reloadData()

        rootSectionProvider.updateDelegate?.willBeginUpdating(rootSectionProvider)

        updaters.forEach { $0(sections) }

        rootSectionProvider.updateDelegate?.didEndUpdating(rootSectionProvider)
    }
}
