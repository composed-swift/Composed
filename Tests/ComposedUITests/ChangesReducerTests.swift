import XCTest
import Composed
@testable import ComposedUI

final class ChangesReducerTests: XCTestCase {
    /// Mirrors `CollectionCoordinatorTests.testBatchUpdates`
    func testBatchUpdates_Mirror() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         Assumed to start with:

         - Section 0
         - Section 1
         - Section 2
             - Element 0
             - Element 1
             - Element 2
             - Element 3
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        /**
         Remove section 0 to become:

         - Section 1
         - Section 2
             - Element 0
             - Element 1
             - Element 2
             - Element 3
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups(IndexSet([0]))
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0]
                )
            })

        /**
         Swap (1, 0) and (1, 3) to become:

         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 0, section: 1)])
                changesReducer.updateElements(at: [IndexPath(item: 3, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        // Note that updates are decomposed in to a delete and an insert, and element deletes are the first things to be processed so the section here is the original section
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
            })

        /**
         Insert section 0 to become:

         - Section 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
            })

        /**
         Insert (0, 0) to become:

         - Section 0
            - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
            })

        /**
         Reload (2, 1) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 1, section: 2)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
            })

        /**
         Reload (2, 2) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 2, section: 2)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
            })

        /**
         Delete section 3 to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([3])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [3]
                )
            })

        /**
         Insert (2, 4) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 4, section: 2)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [3]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
            })

        /**
         Insert "Section 4" at 1 to become:

         - Section 0
             - Element 0
         - Section 4
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [3]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 3),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [1]
                )
            })

        /**
         Insert "Section 6" at 4 to become:

         - Section 0
             - Element 0
         - Section 4
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([4])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [3]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 3),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [1, 4]
                )
            })

        /**
         Insert "Section 5" at 4 to become:

         - Section 0
             - Element 0
         - Section 4
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([4])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [3]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 3),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [1, 4, 5]
                )
            })

        /**
         Remove "Section 4" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4]
                )
            })

        /**
         Insert "Section 4" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([3])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5]
                )
            })

        /**
         Insert "Section 3" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         - Section 4
         - Section 5
             - Element 0...8         
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([3])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5, 6]
                )
            })

        /**
         Remove (3, 2) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 3
             - Element 0
             - Element 1
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 3)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5, 6]
                )
            })

        /**
         Insert (3, 2) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 3
             - Element 0
             - Element 1
             - Element 2
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 2, section: 3)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5, 6]
                )
            })

        /**
         Insert (3, 3) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
             - Element 3
             - Element 1
             - Element 2
             - Element 0
             - Element 4
         - Section 3
             - Element 0
             - Element 1
             - Element 2
             - Element 3
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 3, section: 3)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 1, section: 2),
                        IndexPath(item: 2, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 4, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5, 6]
                )
            })

        /**
         Remove "Section 2" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 3
             - Element 0
             - Element 1
             - Element 2
             - Element 3
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [2]
                )
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 3]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [3, 4, 5]
                )
            })

        /**
         Remove "Section 3" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 2, 3]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4]
                )
            })

        /**
         Insert "Section 2" to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 2, 3]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5]
                )
            })

        /**
         Swap (4, 0) and (4, 8) to become:

         - Section 0
             - Element 0
         - Section 1
         - Section 2
         - Section 4
         - Section 5
             - Element 0...8
         - Section 6
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [
                    IndexPath(item: 0, section: 4),
                ])
                changesReducer.updateElements(at: [
                    IndexPath(item: 8, section: 4),
                ])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [0, 2, 3]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [4, 5]
                )
            })
    }

    func testMultipleElementRemovals() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
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

    func testReloadInsertReload() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [IndexPath(item: 0, section: 0)]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 1, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [IndexPath(item: 0, section: 0)]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 1, section: 0)]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 1, section: 0)]
                )
            })
    }

    func testInsertAndRemovalInSameSection() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         - 0: Element A
         - 1: Element B
         - 2: Element C
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 3, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 3, section: 0)]
                )
            })

        /**
         - 0: Element A
         - 1: Element B
         - 2: Element C
         - 3: Element D (new)
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
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
         - 0: Element B
         - 1: Element C
         - 2: Element D (new)
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 3, section: 0),
                    ]
                )
            })

        /**
         - 0: New Element (inserted; reload)
         - 1: Element B
         - 2: Element C
         - 3: Element D (new)
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        /**
         - 0: New Element (reloaded)
         - 1: Element B
         - 2: Element D (new)
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 0, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 0, section: 0),
                    ]
                )
            })

        /**
         - Element B
         - Element D
         */
    }

    func testRemoveSectionThenSwapElements() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         - Section A
         - Section B
         - Section C
           - Section C-0
           - Section C-1
           - Section C-2
           - Section C-3
           - Section C-4
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0]
                )
            })

        /**
         - Section B
         - Section C
           - Section C-0
           - Section C-1
           - Section C-2
           - Section C-3
           - Section C-4
         */

        AssertApplyingUpdates(
            { changesReducer in
                // Simulate a swap
                changesReducer.updateElements(at: [
                    IndexPath(item: 0, section: 1),
                ])
                changesReducer.updateElements(at: [
                    IndexPath(item: 3, section: 1),
                ])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 2),
                        IndexPath(item: 3, section: 2),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0]
                )
            })
    }

    func testGroupAndElementRemoves() {
        /**
         Because element removals are processed before group removals, any element removals that are
         performed after a group removal should have their section increased.
         */
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         Assumed to start with:

         - Section 0
         - Section 1
         - Section 2
         - Section 3
           - Element 0
           - Element 1
         */

        /**
         Remove section 0 and section 1 to become:

         - Section 2
         - Section 3
           - Element 0
           - Element 1
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups(IndexSet([0, 1]))
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0, 1]
                )
            })

        /**
         Remove element (1, 1) to become:

         - Section 2
         - Section 3
           - Element 0
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 1, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0, 1]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [IndexPath(row: 1, section: 3)]
                )
            })

        /**
         Remove section 0 to become:

         - Section 3
           - Element 0
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups(IndexSet(integer: 0))
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [0, 1, 2]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [IndexPath(row: 1, section: 3)]
                )
            })
    }

    func testRemoveSectionThenRemoveElementThenRemoveSection() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        changesReducer.removeGroups([1])
        changesReducer.removeElements(at: [IndexPath(row: 1, section: 2)])
        changesReducer.removeGroups([1])
    }

    func testMoveElement() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        changesReducer.moveElements([(from: IndexPath(row: 0, section: 0), to: IndexPath(row: 1, section: 0))])

        let changeset = changesReducer.endUpdating()

        XCTAssertNotNil(changeset)

        XCTAssertEqual(
            changeset!.elementsMoved,
            [
                Changeset.Move(
                    from: IndexPath(row: 0, section: 0),
                    to: IndexPath(row: 1, section: 0)
                )
            ]
        )
    }

    func testGroupAndElementInserts() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        changesReducer.insertElements(at: [IndexPath(item: 5, section: 2)])
        changesReducer.insertGroups([1])
        changesReducer.insertElements(at: [IndexPath(item: 6, section: 3)])

        guard let changeset = changesReducer.endUpdating() else {
            XCTFail("Changeset should not be `nil`")
            return
        }

        XCTAssertEqual(
            changeset.elementsInserted,
            [
                IndexPath(row: 5, section: 3),
                IndexPath(row: 6, section: 3),
            ]
        )
        XCTAssertEqual(
            changeset.groupsInserted,
            [1]
        )
    }

    func testInsertThenRemoveGroups() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
            })
    }

    func testRemoveThenInsertGroups() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        1
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
            })
    }

    func testRemoveElementThenRemoveEarlierGroupThenInsertElement() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1)
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1)
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 1, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [
                        IndexPath(item: 1, section: 0)
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1)
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        0
                    ]
                )
            })
    }

    func testMultipleInsertThenRemoveGroups() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        1
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        1,
                        2,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        1,
                    ]
                )
            })
    }

    func testRemoveGroupLocatedBeforeRemovedElement() {
        /**
         Tests that if a section is removed that is located before an element that has been removed
         that the removed element it not updated. This is because element removals are processed
         before section removals.
         */
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        0,
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1),
                    ]
                )
            })
    }

    func testRemoveGroupContainingRemovedElement() {
        /**
         Tests that if a section is removed that contains an element that has been removed
         that the removed element is removed from the changeset. This is because element removals
         are not required when a section is removed.
         */
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        1,
                    ]
                )
            })
    }

    func testRemoveGroupLocatedAfterRemovedElement() {
        /**
         Tests that if a section is removed that is located after an element that has been removed
         that the removed element it not updated. This is because the element position has not changed.
         */
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 0, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                    ]
                )
            })
    }

    func testInsertAndDeleteBecomesReloadSection() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         Assume starting with:

         - Section 1
         */

        /**
         Insert section 0 to become:

         - Section 0
         - Section 1
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        0,
                    ]
                )
            })

       /**
        Remove section 1 to become:

        - Section 0
        */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0,
                    ]
                )
            })
    }

    func testRemoveThenInsertsThenRemoveGroups() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([0])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        1
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([1])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        0
                    ]
                )
            })
    }

    func testRemoveThenInsertAtSameIndexPath() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })
    }

    func testRemoveThenUpdateAtSameIndexPath() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 3, section: 0),
                    ]
                )
            })
    }

    func testUpdateThenRemoveAtSameIndexPath() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 0),
                    ]
                )
            })
    }

    func testRemoveSectionsWithLowerIndexesThanInsertedSections() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         Start assuming 4 existing sections:

         - Section 0
         - Section 1
         - Section 2
         - Section 3
         */

        /**
         Insert section at index 4 to become:

         - Section 0
         - Section 1
         - Section 2
         - Section 3
         - Section 4
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([4])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        4,
                    ]
                )
            })

        /**
         Insert section at index 5 to become:

         - Section 0
         - Section 1
         - Section 2
         - Section 3
         - Section 4
         - Section 5
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([5])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        4,
                        5,
                    ]
                )
            })

        /**
         Remove section at index 2 to become:

         - Section 0
         - Section 1
         - Section 3
         - Section 4
         - Section 5
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        3,
                        4,
                    ]
                )
            })

        /**
         Remove section at index 2 to become:

         - Section 0
         - Section 1
         - Section 4
         - Section 5
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        2,
                        3,
                    ]
                )
            })
    }

    func testSportyCrash3() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        /**
         Starts with 24 (0...23) sections.

         Section at index 1 has 3 elements.
         */

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 2, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 1, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 1, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    [
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 2, section: 1)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([24])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        24,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertGroups([25])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        24,
                        25,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        23,
                        24,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        22,
                        23,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        21,
                        22,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        20,
                        21,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        19,
                        20,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        18,
                        19,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        17,
                        18,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        16,
                        17,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        15,
                        16,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        14,
                        15,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsInserted,
                    [
                        13,
                        14,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        12,
                        13,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                    ]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeGroups([2])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 1, section: 1),
                        IndexPath(item: 2, section: 1),
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsUpdated,
                    [
                        11,
                        12,
                    ]
                )
                XCTAssertEqual(
                    changeset.groupsRemoved,
                    [
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        13,
                        14,
                    ]
                )
            })
    }

    func testRemoveUpdatedIndexPathWithInsertedIndexPathAfter() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.updateElements(at: [IndexPath(item: 0, section: 0)])
                changesReducer.insertElements(at: [IndexPath(item: 1, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [IndexPath(item: 0, section: 0)]
                )
                XCTAssertEqual(
                    changeset.elementsInserted,
                    [IndexPath(item: 1, section: 0)]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 0)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [IndexPath(item: 0, section: 0)]
                )
            })
    }

    func testMultipleRemoves_MultipleInserts_MultipleRemoves_SingleInsert() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...22).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let removedIndexPaths = Set((0...22).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    removedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let insertedIndexPaths = (0...30).map { IndexPath(item: $0, section: 6) }
                changesReducer.insertElements(at: insertedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...22).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )

                let insertedIndexPaths = Set((23...30).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...29).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [IndexPath(item: 0, section: 6)]
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.insertElements(at: [IndexPath(item: 0, section: 6)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    [
                        IndexPath(item: 0, section: 6),
                        IndexPath(item: 1, section: 6),
                    ]
                )
            })
    }

    func test_SBI1560() {
        var changesReducer = ChangesReducer()
        changesReducer.beginUpdating()

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...6).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let removedIndexPaths = Set((0...6).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    removedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 6)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let removedIndexPaths = Set((0...7).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    removedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 6)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let removedIndexPaths = Set((0...8).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    removedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...10).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let removedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsRemoved,
                    removedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let insertedIndexPaths = (0...50).map { IndexPath(item: $0, section: 6) }
                changesReducer.insertElements(at: insertedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...50).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 6)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...49).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        return;
        // TODO: Fill in `produces`

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...21).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...49).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                changesReducer.removeElements(at: [IndexPath(item: 0, section: 6)])
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...49).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let removedIndexPaths = (0...26).map { IndexPath(item: $0, section: 6) }
                changesReducer.removeElements(at: removedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...49).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })

        AssertApplyingUpdates(
            { changesReducer in
                let insertedIndexPaths = (0...50).map { IndexPath(item: $0, section: 6) }
                changesReducer.insertElements(at: insertedIndexPaths)
            },
            changesReducer: &changesReducer,
            produces: { changeset in
                let updatedIndexPaths = Set((0...19).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsUpdated,
                    updatedIndexPaths
                )
                let insertedIndexPaths = Set((20...50).map { IndexPath(item: $0, section: 6) })
                XCTAssertEqual(
                    changeset.elementsInserted,
                    insertedIndexPaths
                )
            })
    }

    // MARK:- Unfinished Tests

//    func testGroupInserts() {
//        var changesReducer = ChangesReducer()
//        changesReducer.beginUpdating()
//
//        changesReducer.insertGroups(IndexSet([0, 2]))
//
//        changesReducer.insertGroups(IndexSet(integer: 1))
//
//        let changeset = changesReducer.endUpdating()
//
//        XCTAssertNotNil(changeset)
//
//        XCTAssertEqual(changeset!.groupsInserted, [0, 0, 2])
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
//        XCTAssertEqual(
//            changeset.elementsInserted,
//            [
//                IndexPath(row: 5, section: 3),
//                IndexPath(row: 6, section: 3),
//            ]
//        )
//        XCTAssertEqual(
//            changeset.groupsInserted,
//            [1]
//        )
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
//        XCTAssertEqual(
//            changeset!.elementsUpdated,
//            [
//                IndexPath(row: 0, section: 0),
//                IndexPath(row: 1, section: 0),
//            ]
//        )
//    }
//
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
//
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
//
//        changesReducer.removeElements(at: [IndexPath(item: 2, section: 1)])
//        changesReducer.insertGroups([1, 2, 4])
//        changesReducer.removeGroups([2])
//    }
}

private func AssertApplyingUpdates(_ updates: (inout ChangesReducer) -> Void, changesReducer: inout ChangesReducer, produces resultChecker: (ChangesetChecker) -> Void) {
    updates(&changesReducer)

    var changesReducerCopy = changesReducer
    if let changeset = changesReducerCopy.endUpdating() {
        let checker = ChangesetChecker(changeset: changeset)
        resultChecker(checker)
        checker.assertUncheckedKeyPathsAreEmpty()
    } else {
        XCTFail("Changeset should not be `nil`. Please call `beginUpdates` at the start of your tests.")
    }
}

@dynamicMemberLookup
private final class ChangesetChecker {
    private let changeset: Changeset

    private var checkedKeyPaths: [PartialKeyPath<Changeset>] = []

    fileprivate init(changeset: Changeset) {
        self.changeset = changeset
    }

    fileprivate func assertUncheckedKeyPathsAreEmpty() {
        if !checkedKeyPaths.contains(\Changeset.groupsInserted) {
            XCTAssertEqual(changeset.groupsInserted, [], "No groups should have been inserted")
        }
        if !checkedKeyPaths.contains(\Changeset.groupsRemoved) {
            XCTAssertEqual(changeset.groupsRemoved, [], "No groups should have been removed")
        }
        if !checkedKeyPaths.contains(\Changeset.groupsUpdated) {
            XCTAssertEqual(changeset.groupsUpdated, [], "No groups should have been updates")
        }
        if !checkedKeyPaths.contains(\Changeset.elementsRemoved) {
            XCTAssertEqual(changeset.elementsRemoved, [], "No elements should have been removed")
        }
        if !checkedKeyPaths.contains(\Changeset.elementsInserted) {
            XCTAssertEqual(changeset.elementsInserted, [], "No elements should have been inserted")
        }
        if !checkedKeyPaths.contains(\Changeset.elementsMoved) {
            XCTAssertEqual(changeset.elementsMoved, [], "No elements should have been moved")
        }
        if !checkedKeyPaths.contains(\Changeset.elementsUpdated) {
            XCTAssertEqual(changeset.elementsUpdated, [], "No elements should have been updated")
        }
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Changeset, Value>) -> Value {
        checkedKeyPaths.append(keyPath)
        return changeset[keyPath: keyPath]
    }
}
