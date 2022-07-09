import XCTest
import UIKit

/// Tests that are validating the logic of `UICollectionView`, without utilising anything from `Composed`/`ComposedUI`.
final class UICollectionViewTests: XCTestCase {
    func testReloadDataInBatchUpdate() throws {
        XCTExpectFailure()

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
        XCTExpectFailure()

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
        if #available(iOS 15, *) {
            XCTExpectFailure("When `reconfigureItems(at:)` was introduced it seems to have broken reloads. In some scenarios nothing will be reloaded, in others on items before a delete will be reloaded. This is the reason ")
        }

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
            viewController.data[0][0] = "0, 0 (updated)"
            viewController.data[0][2] = "0, 2 (updated)"
            viewController.data[0].remove(at: 1)

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
    ///
    /// Items deletes use the section from _before_ section deletes.
    func testDeleteHandlingOrder() {
        let viewController = SpyCollectionViewController()
        viewController.applyInitialData([
            ["0, 0", "0, 1"],
            ["1, 0", "1, 1", "1, 2"],
            ["2, 0"],
        ])

        let callsCompletionExpectations = expectation(description: "Calls completion")

        viewController.collectionView.performBatchUpdates({
            viewController.data.remove(at: 0)
            viewController.collectionView.deleteSections([0])
            viewController.data[0][1] = "1, 1 (new)"
            viewController.data[0].append("1, 3")
            viewController.data[1] = ["2, 0 (new)"]
            viewController.collectionView.deleteSections([2])
            viewController.collectionView.insertSections([1])
            viewController.collectionView.deleteItems(at: [IndexPath(item: 1, section: 1)])
            viewController.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
            viewController.collectionView.insertItems(at: [IndexPath(item: 3, section: 0)])
        }, completion: { _ in
            XCTAssertEqual(
                viewController.requestedIndexPaths, [
                    IndexPath(item: 0, section: 1),
                    IndexPath(item: 1, section: 0),
                    IndexPath(item: 3, section: 0),
                ]
            )
            callsCompletionExpectations.fulfill()
        })

        waitForExpectations(timeout: 1)
    }
}
