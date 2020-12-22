import UIKit
import Composed

@available(*, deprecated, renamed: "SingleUICollectionViewSection")
public typealias CollectionSectionProvider = SingleUICollectionViewSection

/// A section in a `UICollectionView`.
public protocol UICollectionViewSection: Section {
    func collectionViewElementsProvider(with traitCollection: UITraitCollection) -> UICollectionViewSectionElementsProvider
}

public protocol SingleUICollectionViewSection: UICollectionViewSection {
    func section(with traitCollection: UITraitCollection) -> CollectionSection
}

extension SingleUICollectionViewSection {
    public func collectionViewElementsProvider(with traitCollection: UITraitCollection) -> UICollectionViewSectionElementsProvider {
        return section(with: traitCollection)
    }
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
