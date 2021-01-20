import XCTest
import Composed
@testable import ComposedUI

final class ChangesReducerTests: XCTestCase {
    func testMultipleElementRemovals() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [IndexPath(item: 0, section: 0)]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 8, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                        IndexPath(item: 13, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 4, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                        IndexPath(item: 9, section: 0),
                        IndexPath(item: 13, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 0, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                        IndexPath(item: 5, section: 0),
                        IndexPath(item: 9, section: 0),
                        IndexPath(item: 13, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 1, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                        IndexPath(item: 5, section: 0),
                        IndexPath(item: 7, section: 0),
                        IndexPath(item: 9, section: 0),
                        IndexPath(item: 13, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(
                    at: [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                    ]
                )
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsInserted.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 4, section: 0),
                        IndexPath(item: 5, section: 0),
                        IndexPath(item: 6, section: 0),
                        IndexPath(item: 7, section: 0),
                        IndexPath(item: 8, section: 0),
                        IndexPath(item: 9, section: 0),
                        IndexPath(item: 13, section: 0),
                    ]
                )
            })
    }

    func testInsertAndRemovalInSameSection() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         - Element A
         - Element B
         - Element C
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 3, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsRemoved.isEmpty)
                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 3, section: 0)]
                )
            })

        /**
         - Element A
         - Element B
         - Element C
         - Element D
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 2, section: 0)]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                    ]
                )
            })

        /**
         - Element B
         - Element C
         - Element D
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 2, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                    ]
                )
            })

        /**
         - New Element
         - Element B
         - Element C
         - Element D
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        /**
         - New Element
         - Element B
         - Element D
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                guard let changeset = changeset else {
                    XCTFail("Changeset should not be `nil`")
                    return
                }

                XCTAssertTrue(changeset.elementsMoved.isEmpty)
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 1, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        /**
         - Element B
         - Element D
         */
    }

//    func testGroupInserts() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//        changesReducer.insertGroups(IndexSet([0, 2]))
//        changesReducer.insertGroups(IndexSet(integer: 1))
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(changeset!.groupsInserted, [0, 1, 2])
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.elementsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertTrue(changeset!.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.elementsMoved.isEmpty)
//    }
//
//    func testGroupRemoves() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//        changesReducer.removeGroups(IndexSet([0, 2]))
//        changesReducer.removeGroups(IndexSet(integer: 0))
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(changeset!.groupsRemoved, [0, 1, 2])
//        XCTAssertTrue(changeset!.groupsInserted.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.elementsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertTrue(changeset!.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.elementsMoved.isEmpty)
//    }
//
//    func testGroupAndElementRemoves() {
//        /**
//         Because element removals are processed before group removals, any element removals that are
//         performed after a group removal should have their section increased.
//         */
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//        changesReducer.removeGroups(IndexSet([0, 1]))
//        changesReducer.removeElements(at: [IndexPath(item: 1, section: 2)])
//        changesReducer.removeGroups(IndexSet(integer: 0))
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(changeset!.groupsRemoved, [0, 1, 2])
//        XCTAssertTrue(changeset!.groupsInserted.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//        XCTAssertEqual(changeset!.elementsRemoved, [IndexPath(row: 1, section: 4)])
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertTrue(changeset!.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.elementsMoved.isEmpty)
//    }
//
//    func testRemoveSectionThenRemoveElementThenRemoveSection() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        changesReducer.removeGroups([1])
//        changesReducer.removeElements(at: [IndexPath(row: 1, section: 2)])
//        changesReducer.removeGroups([1])
//    }
//
//    func testMoveElement() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        changesReducer.moveElements([(from: IndexPath(row: 0, section: 0), to: IndexPath(row: 1, section: 0))])
//
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(
//            changeset!.elementsMoved,
//            [
//                Changeset.Move(
//                    from: IndexPath(row: 0, section: 0),
//                    to: IndexPath(row: 1, section: 0)
//                )
//            ]
//        )
//        XCTAssertTrue(changeset!.elementsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertTrue(changeset!.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.groupsInserted.isEmpty)
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//    }
//
//    func testElementRemovalAfterOtherChanges() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        changesReducer.removeGroups([0])
//        changesReducer.insertGroups([2])
//        changesReducer.moveElements([Changeset.Move(from: IndexPath(item: 3, section: 1), to: IndexPath(item: 3, section: 1))])
//        changesReducer.insertElements(at: [IndexPath(item: 5, section: 2)])
//        changesReducer.insertGroups([1])
//        changesReducer.insertElements(at: [IndexPath(item: 6, section: 3)])
//
//        guard let changeset = changesReducer.endUpdating() else {
//            XCTFail("Changeset should not be `nil`")
//            return
//        }
//
//        XCTAssertTrue(changeset.elementsMoved.isEmpty)
//        XCTAssertTrue(changeset.elementsRemoved.isEmpty)
//        XCTAssertEqual(
//            changeset.elementsInserted,
//            [
//                IndexPath(row: 5, section: 3),
//                IndexPath(row: 6, section: 3),
//            ]
//        )
//        XCTAssertTrue(changeset.elementsUpdated.isEmpty)
//        XCTAssertEqual(
//            changeset.groupsInserted,
//            [1]
//        )
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//    }
//
//    func testGroupAndElementInserts() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        changesReducer.insertElements(at: [IndexPath(item: 5, section: 2)])
//        changesReducer.insertGroups([1])
//        changesReducer.insertElements(at: [IndexPath(item: 6, section: 3)])
//
//        guard let changeset = changesReducer.endUpdating() else {
//            XCTFail("Changeset should not be `nil`")
//            return
//        }
//
//        XCTAssertTrue(changeset.elementsMoved.isEmpty)
//        XCTAssertTrue(changeset.elementsRemoved.isEmpty)
//        XCTAssertEqual(
//            changeset.elementsInserted,
//            [
//                IndexPath(row: 5, section: 3),
//                IndexPath(row: 6, section: 3),
//            ]
//        )
//        XCTAssertTrue(changeset.elementsUpdated.isEmpty)
//        XCTAssertEqual(
//            changeset.groupsInserted,
//            [1]
//        )
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//    }
//
//    func testMoveElementThenRemoveElementBeforeMovedElement() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        /**
//         This is testing:
//
//         - A
//         - B
//         - C
//         - D
//
//         # Swap C and D
//
//         - A
//         - B
//         - D
//         - C
//
//         # Delete A
//
//         - B
//         - D
//         - C
//         */
//
//        changesReducer.moveElements([(from: IndexPath(row: 2, section: 0), to: IndexPath(row: 3, section: 0))])
//        changesReducer.removeElements(at: [IndexPath(row: 0, section: 0)])
//
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(
//            changeset!.elementsMoved,
//            [
//                Changeset.Move(
//                    from: IndexPath(row: 1, section: 0),
//                    to: IndexPath(row: 2, section: 0)
//                )
//            ]
//        )
//        XCTAssertEqual(changeset!.elementsRemoved, [IndexPath(row: 0, section: 0)])
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertTrue(changeset!.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//    }
//
//    func testRemoveAnIndexPathWithAMoveTo() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        /**
//         This is testing:
//
//         - A
//         - B
//         - C
//
//         # Swap B and C
//
//         - A
//         - C
//         - B
//
//         # Delete B
//
//         - A
//         - C
//
//         `UICollectionView` does not support deleting an index path and moving to the same index path, so this should produce:
//
//         - Delete 1
//         - Delete 2
//         - Insert 1
//         */
//
//        changesReducer.moveElements([(from: IndexPath(row: 1, section: 0), to: IndexPath(row: 2, section: 0))])
//        changesReducer.removeElements(at: [IndexPath(row: 2, section: 0)])
//
//        guard let changeset = changesReducer.endUpdating() else {
//            XCTFail("Changeset should not be `nil`")
//            return
//        }
//
//        XCTAssertEqual(
//            changeset.elementsRemoved,
//            [
//                IndexPath(row: 1, section: 0),
//                IndexPath(row: 2, section: 0),
//            ]
//        )
//        XCTAssertEqual(
//            changeset.elementsInserted,
//            [
//                IndexPath(row: 1, section: 0),
//            ]
//        )
//        XCTAssertTrue(changeset.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset.elementsMoved.isEmpty)
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//    }
//
//    func testRemoveAnIndexPathWithAMoveFrom() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        /**
//         This is testing:
//
//         - A
//         - B
//         - C
//
//         # Swap B and C
//
//         - A
//         - C
//         - B
//
//         # Delete B
//
//         - A
//         - C
//
//         `UICollectionView` does not support deleting an index path and moving to the same index path, so this should produce:
//
//         - Delete 1
//         - Delete 2
//         - Insert 1
//         */
//
//        changesReducer.moveElements([(from: IndexPath(row: 2, section: 0), to: IndexPath(row: 1, section: 0))])
//        changesReducer.removeElements(at: [IndexPath(row: 2, section: 0)])
//
//        guard let changeset = changesReducer.endUpdating() else {
//            XCTFail("Changeset should not be `nil`")
//            return
//        }
//
//        XCTAssertEqual(
//            changeset.elementsRemoved,
//            [
//                IndexPath(row: 1, section: 0),
//                IndexPath(row: 2, section: 0),
//            ]
//        )
//        XCTAssertEqual(
//            changeset.elementsInserted,
//            [
//                IndexPath(row: 1, section: 0),
//            ]
//        )
//        XCTAssertTrue(changeset.elementsUpdated.isEmpty)
//        XCTAssertTrue(changeset.elementsMoved.isEmpty)
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//    }
//
//    func testMoveElementAtSameIndexAsRemove() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        /**
//         This is testing:
//
//         - A
//         - B
//         - C
//
//         # Delete B
//
//         - A
//         - C
//
//         # Swap A and C
//
//         - C
//         - A
//
//         `UICollectionView` does not support deleting an index path and moving to the same index path, so this should produce:
//
//         - Update 0
//         - Update 1
//         - Delete 2
//         */
//
//        changesReducer.removeElements(at: [IndexPath(row: 1, section: 0)])
//        changesReducer.moveElements([(from: IndexPath(row: 0, section: 0), to: IndexPath(row: 1, section: 0))])
//
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(
//            changeset!.elementsRemoved,
//            [
//                IndexPath(row: 2, section: 0),
//            ]
//        )
//        XCTAssertTrue(changeset!.elementsInserted.isEmpty)
//        XCTAssertEqual(
//            changeset!.elementsUpdated,
//            [
//                IndexPath(row: 0, section: 0),
//                IndexPath(row: 1, section: 0),
//            ]
//        )
//        XCTAssertTrue(changeset!.elementsMoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsRemoved.isEmpty)
//        XCTAssertTrue(changeset!.groupsUpdated.isEmpty)
//    }

//    func testBuildingUpComplexChanges() {
//        /**
//         This test continuously builds upon the same `ChangesReducer` to test
//         applying a large number of changes at the same time.
//
//         These changes are mirrored by the `CollectionCoordinatorTests.testBatchUpdates`.
//         */
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.insertGroups([0])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsRemoved.isEmpty)
//                XCTAssertTrue(changeset.elementsInserted.isEmpty)
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.insertElements(at: [IndexPath(item: 0, section: 0)])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsRemoved.isEmpty)
//                XCTAssertTrue(changeset.elementsInserted.isEmpty)
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.updateElements(at: [IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1)])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 1, section: 0),
//                        IndexPath(row: 2, section: 0),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 1, section: 1),
//                        IndexPath(row: 2, section: 1),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.insertGroups([1])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 1, section: 0),
//                        IndexPath(row: 2, section: 0),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 1, section: 2),
//                        IndexPath(row: 2, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0, 1]
//                )
//            })

//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.removeElements(at: [IndexPath(item: 2, section: 3)])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 1, section: 0),
//                        IndexPath(row: 2, section: 0),
//                        IndexPath(row: 2, section: 1),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 1, section: 2),
//                        IndexPath(row: 2, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0, 1]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.insertGroups([5, 4])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 1, section: 0),
//                        IndexPath(row: 2, section: 0),
//                        IndexPath(row: 2, section: 1),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 1, section: 2),
//                        IndexPath(row: 2, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0, 1, 4, 5]
//                )
//            })



        
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.removeGroups([1])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 0, section: 3),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 0, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsUpdated,
//                    [
//                        IndexPath(row: 1, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.removeElements(at: [IndexPath(item: 2, section: 1)])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsRemoved.isEmpty)
//                XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 2, section: 1),
//                        IndexPath(row: 0, section: 3),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 0, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsUpdated,
//                    [
//                        IndexPath(row: 1, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.removeGroups([2])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 0, section: 3),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 0, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsUpdated,
//                    [
//                        IndexPath(row: 1, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//                XCTAssertEqual(
//                    changeset.groupsRemoved,
//                    [1]
//                )
//            })
//
//        AssertApplyingUpdates(
//            { changesReducer in
//                changesReducer.insertElements(at: [IndexPath(item: 2, section: 1), IndexPath(item: 3, section: 1)])
//            },
//            changesReducer: &changesReducer,
//            produces: { changeset in
//                guard let changeset = changeset else {
//                    XCTFail("Changeset should not be `nil`")
//                    return
//                }
//
//                XCTAssertTrue(changeset.elementsMoved.isEmpty)
//                XCTAssertTrue(changeset.groupsUpdated.isEmpty)
//                XCTAssertEqual(
//                    changeset.elementsRemoved,
//                    [
//                        IndexPath(row: 0, section: 3),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsInserted,
//                    [
//                        IndexPath(row: 0, section: 2),
//                        IndexPath(row: 2, section: 1),
//                        IndexPath(row: 3, section: 1),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.elementsUpdated,
//                    [
//                        IndexPath(row: 1, section: 2),
//                    ]
//                )
//                XCTAssertEqual(
//                    changeset.groupsInserted,
//                    [0]
//                )
//                XCTAssertEqual(
//                    changeset.groupsRemoved,
//                    [1]
//                )
//            })

//        changesReducer.removeElements(at: [IndexPath(item: 2, section: 1)])
//        changesReducer.insertGroups([1, 2, 4])
//        changesReducer.removeGroups([2])
//    }
}

private func AssertApplyingUpdates(_ updates: (inout ChangesReducer) -> Void, changesReducer: inout ChangesReducer, produces resultChecker: (Changeset?) -> Void) {
    updates(&changesReducer)

    var changesReducerCopy = changesReducer
    let changeset = changesReducerCopy.endUpdating()

    resultChecker(changeset)
}
