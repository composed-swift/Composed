import Composed
import UIKit

/// A `Composed.FlatSection` conforming to `UICollectionViewSection`
open class FlatUICollectionViewSection: FlatSection, UICollectionViewSection {
    public var header: CollectionSupplementaryElement? {
        didSet {
            // TODO: Notify delegate
        }
    }

    public var footer: CollectionSupplementaryElement? {
        didSet {
            // TODO: Notify delegate
        }
    }

    public init(header: CollectionSupplementaryElement? = nil, footer: CollectionSupplementaryElement? = nil) {
        self.header = header
        self.footer = footer

        super.init()
    }

    open func collectionViewElementsProvider(with traitCollection: UITraitCollection) -> UICollectionViewSectionElementsProvider {
        FlatUICollectionViewSectionElementsProvider(section: self, traitCollection: traitCollection, header: header, footer: footer)
    }
}

extension FlatUICollectionViewSection: CollectionSelectionHandler {
    open func didSelect(at index: Int, cell: UICollectionViewCell) {
        guard let sectionMeta = self.section(at: index) else { return }

        let sectionIndex = index - sectionMeta.offset

        if let section = sectionMeta.section as? CollectionSelectionHandler {
            section.didSelect(at: sectionIndex, cell: cell)
        } else if let section = sectionMeta.section as? SelectionHandler {
            section.didSelect(at: sectionIndex)
        }
    }

    open func didDeselect(at index: Int, cell: UICollectionViewCell) {
        guard let sectionMeta = self.section(at: index) else { return }

        let sectionIndex = index - sectionMeta.offset

        if let section = sectionMeta.section as? CollectionSelectionHandler {
            section.didDeselect(at: sectionIndex, cell: cell)
        } else if let section = sectionMeta.section as? SelectionHandler {
            section.didDeselect(at: sectionIndex)
        }
    }
}
