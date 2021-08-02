import UIKit

final class SpyCollectionViewController: UICollectionViewController {
    var data: [[String]] = []

    var requestedIndexPaths: [IndexPath] = []

    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    }

    func applyInitialData(_ data: [[String]]) {
        self.data = data
        loadViewIfNeeded()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        requestedIndexPaths = []
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        requestedIndexPaths.append(indexPath)
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].count
    }
}
