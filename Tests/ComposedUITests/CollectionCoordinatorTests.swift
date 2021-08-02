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
            sections.child2.append(contentsOf: ["0", "1", "2", "3"])
            sections.child3.append(contentsOf: ["0", "1", "2"])
            sections.child5.append(contentsOf: ["0", "1", "2", "3", "4", "5", "6", "7", "8"])
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

    func testRemoveInsertedElementWhileWaitingForAnimations() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0.insert("inserted-0", at: 0)
            DispatchQueue.main.async {
                sections.child0.remove(at: 0)
            }
        }
    }

    func testRemoveSectionWhenForcingReloadData() {
        let tester = Tester(forceReloadData: true) { sections in
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child2)
        }

        tester.applyUpdate { sections in
            let delegate = sections.rootSectionProvider.updateDelegate
            defer {
                sections.rootSectionProvider.updateDelegate = delegate
            }
            sections.rootSectionProvider.updateDelegate = nil

            sections.rootSectionProvider.remove(sections.child1)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.invalidateAll(sections.rootSectionProvider)
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
            sections.child4.append("0")
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
            sections.child3.removeAll()
            sections.child3.append("3, 0")
            sections.child3.append("3, 1")

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
            sections.rootSectionProvider.append(sections.child0)
            sections.child0.append(contentsOf: ["0", "1", "2", "3"])
        }

        tester.applyUpdate { sections in
            sections.child0.swapAt(0, 3)
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
            sections.rootSectionProvider.append(sections.child0)
            sections.child0.append("0")
            sections.child0.append("1")
            sections.child0.append("2")
        }

        tester.applyUpdate { sections in
            sections.child0.removeLast(2)
        }
    }

    func testRemoveInsertedSection() {
        let tester = Tester() { _ in }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }
    }

    func testRemoveInsertsSection() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child1)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.insert(sections.child0, at: 0)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child1)
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
            sections.child0.insert("new-2", at: 2)
        }
    }

    func testInsertAndRemovalInSameSection() {
        let tester = Tester() { sections in
            (0...2).forEach { index in
                sections.child0.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0.append("new-3")
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 0)
        }

        tester.applyUpdate { sections in
            sections.child0.insert("new-0", at: 0)
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 0)
        } postUpdateChecks: { sections in
            XCTAssertEqual(sections.child0.requestedCells, [1])
        }
    }

    func testRemoveThenReloadAtSameIndexPath() {
        let tester = Tester() { sections in
            (0...9).forEach { index in
                sections.child1.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
        }

        tester.applyUpdate { sections in
            sections.child1.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child1[2] = "new-2"
        } postUpdateChecks: { sections in
            XCTAssertTrue(sections.child0.requestedCells.isEmpty)
            XCTAssertEqual(sections.child1.requestedCells, [2])
        }
    }

    func testReloadThenRemoveAtSameIndexPath() {
        let tester = Tester() { sections in
            (0...9).forEach { index in
                sections.child0.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0[2] = "new-2"
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }
    }

    func testReloadInsertReload() {
        let tester = Tester() { sections in
            (0..<2).forEach { index in
                sections.child0.append("initial-\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0[0] = "new-0"
        }
        tester.applyUpdate { sections in
            sections.child0.insert("inserted-1", at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0[2] = "new-2"
        }
    }

    /// Test a crash from Sporty
    func testDeleteDeleteDeleteReload() {
        let tester = Tester() { sections in
            (0...3).forEach { index in
                sections.child0.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0.remove(at: 0)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 0)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 0)
        }
        tester.applyUpdate { sections in
            sections.child0[0] = "new-0"
        } postUpdateChecks: { sections in
            XCTAssertEqual(sections.child0.requestedCells, [0])
        }
    }

    /// Test a crash from Sporty
    func testSportyCrash() {
        let tester = Tester() { sections in
            (0...51).forEach { index in
                sections.child0.append("\(index)")
            }
            sections.rootSectionProvider.append(sections.child0)
        }

        tester.applyUpdate { sections in
            sections.child0[0] = "new-0"
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 4)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 3)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 4)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 3)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 4)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 3)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 4)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 3)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 2)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-1", at: 1)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-2", at: 2)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-3", at: 3)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-4", at: 4)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-5", at: 5)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-6", at: 6)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-7", at: 7)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-8", at: 8)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-9", at: 9)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-10", at: 10)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-11", at: 11)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-12", at: 12)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-13", at: 13)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-14", at: 14)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-15", at: 15)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-16", at: 16)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-17", at: 17)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-18", at: 18)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-19", at: 19)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-20", at: 20)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-21", at: 21)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-22", at: 22)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-23", at: 23)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-24", at: 24)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-25", at: 25)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-26", at: 26)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-27", at: 27)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-28", at: 28)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-29", at: 29)
        }
        tester.applyUpdate { sections in
            sections.child0.insert("new-30", at: 30)
        }
        tester.applyUpdate { sections in
            sections.child0[31] = "new-31"
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 35)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 34)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 35)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 34)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 32)
        }
        tester.applyUpdate { sections in
            sections.child0[32] = "new-32"
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
        tester.applyUpdate { sections in
            sections.child0.remove(at: 33)
        }
    }

    /// Test a crash from Sporty
    func testSportyCrash2() {
        let tester = Tester() { sections in
            sections.rootSectionProvider.append(sections.child0)
            sections.rootSectionProvider.append(sections.child1)
            sections.rootSectionProvider.append(sections.child2)
            sections.rootSectionProvider.append(sections.child3)
        }

        tester.applyUpdate { sections in
            let section = MockCollectionArraySection()
            sections.rootSectionProvider.insert(section, at: 4)
        }
        tester.applyUpdate { sections in
            let section = MockCollectionArraySection()
            sections.rootSectionProvider.insert(section, at: 5)
        }
        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }
        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }
    }

    /// Test a crash from Sporty
    func testSportyCrash3() throws {
        let tester = Tester() { sections in
            (0...23).forEach { index in
                switch index {
                case 1:
                    sections.rootSectionProvider.append(MockCollectionArraySection([
                        "1a",
                        "1b",
                        "1c",
                    ]))
                default:
                    sections.rootSectionProvider.append(MockCollectionArraySection([
                        "\(index)a"
                    ]))
                }
            }
        }

        tester.applyUpdate { sections in
            (sections.rootSectionProvider.sections[1] as! ArraySection<String>).remove(at: 2)
        }
        tester.applyUpdate { sections in
            (sections.rootSectionProvider.sections[1] as! ArraySection<String>).remove(at: 1)
        }
        tester.applyUpdate { sections in
            (sections.rootSectionProvider.sections[1] as! ArraySection<String>).insert("1b-new", at: 1)
        }
        tester.applyUpdate { sections in
            (sections.rootSectionProvider.sections[1] as! ArraySection<String>).insert("1c-new", at: 2)
        }
        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(MockCollectionArraySection([
                "24a-inserted"
            ]))
        }
        tester.applyUpdate { sections in
            sections.rootSectionProvider.append(MockCollectionArraySection([
                "25a-inserted"
            ]))
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate { sections in
            sections.rootSectionProvider.remove(at: 2)
        }

        tester.applyUpdate({ sections in
            sections.rootSectionProvider.remove(at: 2)
        }, postUpdateChecks: { sections in
            XCTAssertEqual(sections.rootSectionProvider.sections.count, 4)

            XCTAssertEqual(
                (sections.rootSectionProvider.sections[0] as! MockCollectionArraySection).requestedCells,
                []
            )
            XCTAssertEqual(
                (sections.rootSectionProvider.sections[1] as! MockCollectionArraySection).requestedCells,
                [1, 2]
            )
            XCTAssertEqual(
                (sections.rootSectionProvider.sections[2] as! MockCollectionArraySection).requestedCells,
                [0]
            )
            XCTAssertEqual(
                (sections.rootSectionProvider.sections[3] as! MockCollectionArraySection).requestedCells,
                [0]
            )
        })

        /**
         Remaining logs:

         [CollectionCoordinator] mapping(_:didInsertSections:)[4]
         [CollectionCoordinator] mapping(_:didInsertSections:)[5]
         [CollectionCoordinator] mapping(_:didInsertSections:)[6]
         [CollectionCoordinator] mapping(_:didInsertSections:)[7]
         [CollectionCoordinator] mapping(_:didInsertSections:)[8]
         [CollectionCoordinator] mapping(_:didInsertSections:)[9]
         [CollectionCoordinator] mapping(_:didInsertSections:)[10]
         [CollectionCoordinator] mapping(_:didInsertSections:)[11]
         [CollectionCoordinator] mapping(_:didInsertSections:)[12]
         [CollectionCoordinator] mapping(_:didInsertSections:)[13]
         [CollectionCoordinator] mapping(_:didInsertSections:)[14]
         [CollectionCoordinator] mapping(_:didInsertSections:)[15]
         [CollectionCoordinator] mapping(_:didInsertSections:)[16]
         [CollectionCoordinator] mapping(_:didInsertSections:)[17]
         [CollectionCoordinator] mapping(_:didInsertSections:)[18]
         [CollectionCoordinator] mapping(_:didInsertSections:)[19]
         [CollectionCoordinator] mapping(_:didInsertSections:)[20]
         [CollectionCoordinator] mapping(_:didInsertSections:)[21]
         [CollectionCoordinator] mapping(_:didInsertSections:)[22]
         [CollectionCoordinator] mapping(_:didInsertSections:)[23]
         [CollectionCoordinator] mapping(_:didInsertSections:)[24]
         [CollectionCoordinator] mapping(_:didInsertSections:)[25]
         [CollectionCoordinator] mapping(_:didInsertSections:)[26]
         [CollectionCoordinator] mapping(_:didInsertSections:)[27]
         [CollectionCoordinator] mapping(_:didInsertSections:)[28]
         [CollectionCoordinator] mapping(_:didInsertSections:)[29]
         [CollectionCoordinator] mapping(_:didInsertSections:)[30]
         [CollectionCoordinator] mapping(_:didInsertSections:)[31]
         [CollectionCoordinator] mapping(_:didInsertSections:)[32]
         [CollectionCoordinator] mapping(_:didInsertSections:)[33]
         [CollectionCoordinator] mapping(_:didInsertSections:)[34]
         [CollectionCoordinator] mapping(_:didInsertSections:)[35]
         [CollectionCoordinator] mapping(_:didInsertSections:)[36]
         [CollectionCoordinator] mapping(_:didInsertSections:)[37]
         [CollectionCoordinator] mapping(_:didInsertSections:)[38]
         [CollectionCoordinator] mapping(_:didInsertSections:)[39]
         [CollectionCoordinator] mapping(_:didInsertSections:)[40]
         [CollectionCoordinator] mapping(_:didInsertSections:)[41]
         [CollectionCoordinator] mapping(_:didInsertSections:)[42]
         [CollectionCoordinator] mapping(_:didInsertSections:)[43]
         [CollectionCoordinator] mapping(_:didInsertSections:)[44]
         [CollectionCoordinator] mapping(_:didInsertSections:)[45]
         [CollectionCoordinator] mapping(_:didInsertSections:)[46]
         [CollectionCoordinator] mapping(_:didInsertSections:)[47]
         [CollectionCoordinator] mapping(_:didInsertSections:)[48]
         [CollectionCoordinator] mapping(_:didInsertSections:)[49]
         [CollectionCoordinator] mapping(_:didInsertSections:)[50]
         [CollectionCoordinator] mapping(_:didInsertSections:)[51]
         */
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

    var child0 = MockCollectionArraySection([])
    var child1 = MockCollectionArraySection([])
    var child2 = MockCollectionArraySection([])
    var child3 = MockCollectionArraySection([])
    var child4 = MockCollectionArraySection([])
    var child5 = MockCollectionArraySection([])
    var child6 = MockCollectionArraySection([])
}

private final class Tester {
    typealias Updater = (TestSections) -> Void

    private var updaters: [Updater] = []

    private var sections: TestSections

    private let initialState: Updater

    private var collectionViews: [UICollectionView] = []

    private let forceReloadData: Bool

    init(forceReloadData: Bool = false, initialState: @escaping Updater) {
        self.forceReloadData = forceReloadData
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

        rootSectionProvider.performBatchUpdates(forceReloadData: forceReloadData) { _ in
            updaters.forEach { $0(sections) }
        }

        postUpdateChecks?(sections)
    }
}
