import UIKit
import Composed

@available(*, deprecated, renamed: "UICollectionViewSection")
public typealias CollectionSectionProvider = UICollectionViewSection

/// A section in a `UICollectionView`.
public protocol UICollectionViewSection: Section {
    func collectionViewElementsProvider(with traitCollection: UITraitCollection) -> UICollectionViewSectionElementsProvider
}

@available(*, deprecated, renamed: "UICollectionViewSectionElementsProvider")
public typealias CollectionElementsProvider = UICollectionViewSectionElementsProvider

public protocol UICollectionViewSectionElementsProvider {
    var header: CollectionSupplementaryElement<UICollectionReusableView>? { get }
    var footer: CollectionSupplementaryElement<UICollectionReusableView>? { get }
    var numberOfElements: Int { get }

    func cell(for index: Int) -> CollectionCellElement<UICollectionViewCell>
}

extension UICollectionViewSectionElementsProvider {
    public var isEmpty: Bool { return numberOfElements == 0 }
}

public protocol SingleUICollectionViewSectionElementsProvider: UICollectionViewSectionElementsProvider {
    var cell: CollectionCellElement<UICollectionViewCell> { get }
}

extension SingleUICollectionViewSectionElementsProvider {
    public func cell(for index: Int) -> CollectionCellElement<UICollectionViewCell> {
        return cell
    }
}
