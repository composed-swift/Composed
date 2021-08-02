import XCTest
import UIKit

/// Tests that are validating the logic of `UICollectionView`, without utilising anything from `Composed`/`ComposedUI`.
final class UICollectionViewTests: XCTestCase {
    func testReloadDataInBatchUpdate() throws {
        try XCTSkipIf(true, "This test will purposefully fail; it is validating that `reloadData` should not be called within `performBatchUpdates`.")

        final class CollectionViewController: UICollectionViewController {
            var data: [[String]] = []

            override func viewDidLoad() {
                super.viewDidLoad()

                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
            }

            override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            }

            override func numberOfSections(in collectionView: UICollectionView) -> Int {
                data.count
            }

            override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                data[section].count
            }
        }

        let viewController = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        viewController.data = [
            [
                "0, 0",
                "0, 1",
            ]
        ]
        viewController.loadViewIfNeeded()

        viewController.collectionView.performBatchUpdates {
            viewController.data.append(["1, 0"])
            viewController.collectionView.reloadData()
        }
    }

    func testUpdatingBeforeBatchUpdatesWhenViewNeedsLayout() throws {
        try XCTSkipIf(true, "This test will purposefully fail; it is validating that `performBatchUpdates` will crash when changes are applied before being called when the layout has not been updated.")

        final class CollectionViewController: UICollectionViewController {
            var data: [[String]] = []

            override func viewDidLoad() {
                super.viewDidLoad()

                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
            }

            override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            }

            override func numberOfSections(in collectionView: UICollectionView) -> Int {
                data.count
            }

            override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                data[section].count
            }
        }

        let viewController = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        viewController.data = [
            [
                "0, 0",
                "0, 1",
            ]
        ]
        viewController.loadViewIfNeeded()

        // Uncommenting this line allows the tests to pass because it ensures the layout is
        // updated before `performBatchUpdates` has been called
//        viewController.collectionView.layoutIfNeeded()
        viewController.data.append(["1, 0"])

        viewController.collectionView.performBatchUpdates {
            viewController.collectionView.insertSections([1])
        }
    }

    /// A test to validate that element reloads are handled before section deletes.
    func testElementReloadsAreHandledBeforeRemoves() {
        let viewController = SpyCollectionViewController()
        viewController.applyInitialData([
            ["0, 0", "0, 1", "0, 2"],
        ])

        let callsCompletionExpectations = expectation(description: "Calls completion")

        /**
         This validates that the reloads are handled using the "before" indexes because
         `IndexPath(item: 2, section: 0)` is reloaded even though the "after" index path
         that is requested is `IndexPath(item: 1, section: 0)`.
         */
        viewController.collectionView.performBatchUpdates({
            viewController.data[0].remove(at: 1)
            viewController.data[0][1] = "0, 1 (updated)"
            viewController.collectionView.reloadItems(at: [
                IndexPath(item: 0, section: 0),
                IndexPath(item: 2, section: 0),
            ])
            viewController.collectionView.deleteItems(at: [
                IndexPath(item: 1, section: 0),
            ])
        }, completion: { _ in
            XCTAssertEqual(viewController.requestedIndexPaths, [
                IndexPath(item: 0, section: 0),
                IndexPath(item: 1, section: 0),
            ])
            callsCompletionExpectations.fulfill()
        })

        waitForExpectations(timeout: 1)
    }

    /// A test to validate that section reloads are handled before section deletes.
    func testSectionReloadsAreHandledBeforeRemoves() {
        let viewController = SpyCollectionViewController()
        viewController.applyInitialData([
            ["0, 0"],
            ["1, 0"],
            ["2, 0"],
        ])

        let callsCompletionExpectations = expectation(description: "Calls completion")

        viewController.collectionView.performBatchUpdates({
            viewController.data.remove(at: 0)
            viewController.data[1] = ["2, 0 (new)"]
            viewController.collectionView.deleteSections([1])
            viewController.collectionView.reloadSections([2])
        }, completion: { _ in
            XCTAssertEqual(viewController.requestedIndexPaths, [IndexPath(item: 0, section: 1)])
            callsCompletionExpectations.fulfill()
        })

        waitForExpectations(timeout: 1)
    }
}
