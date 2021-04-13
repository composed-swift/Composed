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
}
