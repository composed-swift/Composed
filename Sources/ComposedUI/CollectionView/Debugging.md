# Debugging Composed's UICollectionView Usage

`UICollectionView` is complex and can be hard to debug. Composed provides debug logs that can help to trace where something might have gone wrong. This guide will go over how to debug crashes but the same concepts can be used to find other bugs.

The first step is to identify the collection view in your app that is triggering the issue. Setting `debugLogs` to `true` on the `CollectionCoordinator` will cause messages to be logged to `os_log` (on iOS 12.0 are greater). These logs can be very useful with debugging the logic of the `ChangesReducer`.

## Interpreting Logs

Let's say that when the `ChangesReducer` is told of a section being removed that was inserted in the same batch it doesn't remove it from the array of inserted sections but instead adds it the array of removed sections.

If this were the case we might see a crash and logs similar to:

```logs
[CollectionCoordinator] Starting batch updates
[CollectionCoordinator] mapping(_:didInsertSections:)[0]
[CollectionCoordinator] mapping(_:didRemoveSections:)[0]
[CollectionCoordinator] Preparing sections
[CollectionCoordinator] Deleting sections [0]
[CollectionCoordinator] Deleting items []
[CollectionCoordinator] Reloaded sections []
[CollectionCoordinator] Inserting items []
[CollectionCoordinator] Reloading items []
[CollectionCoordinator] Inserting sections [0]
[CollectionCoordinator] Batch updates have been applied
*** Assertion failure in -[UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:collectionViewAnimator:], UICollectionView.m:7070: attempt to delete section 0, but there are only 0 sections before the update (NSInternalInconsistencyException)
```

Here we can see that the `CollectionCoordinator` has been notified of an insert of section 0 and then the removal of section 0, but it is applying both the delete and the insert. Since deletes are processed first this results in a crash.

Once we understand the problem the next step is to write tests.

## Writing Tests to Validate Fix

The `CollectionCoordinatorTests` includes a `Tester` class that aims to make writing these tests much easier. It provides an initial state with a root `ComposedSectionProvider` and a single function that can be used to build up a series of batch updates. For this example a test could be written as:

```swift
func testRemoveInsertedSection() {
    let tester = Tester() { _ in }

    tester.applyUpdate { sections in
        sections.rootSectionProvider.append(sections.child0)
    }

    tester.applyUpdate { sections in
        sections.rootSectionProvider.remove(sections.child0)
    }
}
```

Each call to `applyUpdate(_:)` is stored and will be run in the order they are declared, one-by-one, to aid with finding which step causes the crash. In this example the test would fail on the second call to `tester.applyUpdate` with the error `attempt to delete section 0, but there are only 0 sections before the update (NSInternalInconsistencyException)`.

The next step would be apply a fix and re-run the tests. If the newly added test and all existing tests pass then the fix has been verified and a pull request can be created.

## Writing Tests for a change that doesn't crash

If you come across a bug that doesn't cause a crash but instead applies an incorrect update, such as reloading the wrong index path, then adding a test against `UICollectionView` might be more cumbersome than adding a test against `ChangesReducer` directly.

A similar convenience function is provided to aid with writing these tests, although they are naturally more verbose due to the tests needing to have assertions about each property.

The above example could be tested as:

```swift
func testInsertThenRemoveGroups() {
    var changesReducer = ChangesReducer()
    changesReducer.beginUpdating()

    AssertApplyingUpdates(
        { changesReducer in
            changesReducer.insertGroups([0])
        },
        changesReducer: &changesReducer,
        produces: { changeset in
            guard let changeset = changeset else {
                XCTFail("Changeset should not be `nil`")
                return
            }

            XCTAssertTrue(changeset.elementsMoved.isEmpty)
            XCTAssertTrue(changeset.elementsRemoved.isEmpty)
            XCTAssertTrue(changeset.elementsInserted.isEmpty)
            XCTAssertTrue(changeset.elementsUpdated.isEmpty)
            XCTAssertTrue(changeset.groupsRemoved.isEmpty)
            XCTAssertTrue(changeset.groupsUpdated.isEmpty)
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
            guard let changeset = changeset else {
                XCTFail("Changeset should not be `nil`")
                return
            }

            XCTAssertTrue(changeset.elementsMoved.isEmpty)
            XCTAssertTrue(changeset.elementsRemoved.isEmpty)
            XCTAssertTrue(changeset.elementsInserted.isEmpty)
            XCTAssertTrue(changeset.elementsUpdated.isEmpty)
            XCTAssertTrue(changeset.groupsInserted.isEmpty)
            XCTAssertTrue(changeset.groupsRemoved.isEmpty)
            XCTAssertTrue(changeset.groupsUpdated.isEmpty)
        })
}
```

This is testing that with a single group insert it is added to the set of inserted groups, but when the same group is then removed the changeset is empty.

These tests are most important for changes that may only cause visual bugs when applied incorrectly, e.g. if an element update reloaded the wrong index path the collection view may not crash but the cell that needs to be reloaded would also not be updated.

## If You Can't Create a Fix

`ChangesReducer` is heavily coupled with the logic of `UICollectionView`'s batch updates, making it quite complex. If you're unsure how to fix an issue please commit the failing test(s) and create a pull request with the changes.
