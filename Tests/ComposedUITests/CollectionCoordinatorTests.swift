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

        tester.applyUpdate({ sections in
            sections.child2.swapAt(0, 3)
        }, postUpdateChecks: { sections in
            XCTAssertEqual(Set(sections.child2.requestedCells), Set([0, 3]))
        })

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

        tester.applyUpdate({ sections in
            sections.child2[1] = "new-1"
        }, postUpdateChecks: { sections in
            XCTAssertEqual(Set(sections.child2.requestedCells), Set([0, 1, 3]))
        })

        tester.applyUpdate({ sections in
            sections.child2[2] = "new-2"
        }, postUpdateChecks: { sections in
            XCTAssertEqual(Set(sections.child2.requestedCells), Set([0, 1, 2, 3]))
        })

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child3)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         */

        tester.applyUpdate { sections in
            sections.child2.append("appended")
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child4, at: 1)
        }

        /**
         - Child 0
         - Child 4
         - Child 1
         - Child 2
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child6)
        }

        /**
         - Child 0
         - Child 4
         - Child 1
         - Child 2
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child5, before: sections.child6)
        }

        /**
         - Child 0
         - Child 4
         - Child 1
         - Child 2
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child4)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child4, before: sections.child5)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 4
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child3, before: sections.child4)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 3
         - Child 4
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.child3.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.child3.insert("new-2", at: 2)
        }

        tester.applyUpdate { sections in
            sections.child3.insert("new-3", at: 3)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child2)
        }

        /**
         - Child 0
         - Child 1
         - Child 3
         - Child 4
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child3)
        }

        /**
         - Child 0
         - Child 1
         - Child 4
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child2, at: 2)
        }

        /**
         - Child 0
         - Child 1
         - Child 2
         - Child 4
         - Child 5
         - Child 6
         */

        tester.applyUpdate { sections in
            sections.child5.swapAt(0, 8)
        }

        tester.applyUpdate { sections in
            sections.child2.swapAt(0, 3)
        }
    }

    func testRemoveAndInsertMultipleSection() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child1)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child1)
        }
    }

    func testInsertsAndRemoves() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child1)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child1)
        }
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

    func testGroupAndElementRemoves() {
        // Mirror of `ChangesReducerTests.testGroupAndElementRemoves`
        let tester = Tester() { sections in
            sections.child0.removeAll()
            sections.child1.removeAll()
            sections.child2.removeAll()

            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child2)
            sections.rootSectionProvider.append(sections.child3)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child1)
            sections.rootSectionProvider.remove(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child3.remove(at: 1)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child2)
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

    func testSwapping() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.child2.swapAt(0, 3)
        }
    }

    func testRemoveAll() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.child2.removeAll()
        }
    }

    func testRemoveLast2() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.child2.removeLast(2)
        }
    }

    func testRemoveInsertsSection() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child1, at: 0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }
    }

    func testRemoveThenInsertAtSameIndexPath() {
        let tester = Tester() { sections in
            (0...9).forEach { index in
                sections.child0.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.child0[2] = "new-2"
        }
    }
}

private final class MockCollectionArraySection: ArraySection<String>, SingleUICollectionViewSection {
    private(set) var requestedCells: [Int] = []

    func section(with traitCollection: UITraitCollection) -> CollectionSection {
        let cell = CollectionCellElement(section: self, dequeueMethod: .fromClass(UICollectionViewCell.self), configure: { [weak self] _, cellIndex, _ in
            self?.requestedCells.append(cellIndex)
        })
        return CollectionSection(section: self, cell: cell)
    }
}

private final class TestSections {
    let rootSectionProvider = ComposedSectionProvider()

    let child0 = MockCollectionArraySection([])
    let child1 = MockCollectionArraySection([])
    var child2 = MockCollectionArraySection(["0", "1", "2", "3"])
    let child3 = MockCollectionArraySection(["0", "1", "2"])
    let child4 = MockCollectionArraySection(["0"])
    var child5 = MockCollectionArraySection(["0", "1", "2", "3", "4", "5", "6", "7", "8"])
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

    func applyUpdate(_ updater: @escaping Updater, postUpdateChecks: ((TestSections) -> Void)? = nil) {
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

        postUpdateChecks?(sections)
    }
}
