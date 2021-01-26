import UIKit
import Composed

/// Defines a configuration for a section in a `UICollectionView`.
/// The section must contain a cell element, but can also optionally include a header and/or footer element.
open class CollectionSection: SingleUICollectionViewSectionElementsProvider {

    /// The cell configuration element
    public let cell: CollectionCellElement

    /// The header configuration element
    public let header: CollectionSupplementaryElement?

    /// The footer configuration element
    public let footer: CollectionSupplementaryElement?

    /// The number of elements in this section
    open var numberOfElements: Int {
        return section?.numberOfElements ?? 0
    }

    // The underlying section associated with this section
    private weak var section: Section?

    /// Makes a new configuration with the specified cell, header and/or footer elements
    /// - Parameters:
    ///   - section: The section this will be associated with
    ///   - cell: The cell configuration element
    ///   - header: The header configuration element
    ///   - footer: The footer configuration element
    public init<Section>(
        section: Section,
        cell: CollectionCellElement,
        header: CollectionSupplementaryElement? = nil,
        footer: CollectionSupplementaryElement? = nil
    ) where Section: Composed.Section {
        self.section = section
        self.cell = cell

        if let header = header {
            let kind: CollectionElementKind
            if case .automatic = header.kind {
                kind = .custom(kind: UICollectionView.elementKindSectionHeader)
            } else {
                kind = header.kind
            }

            self.header = CollectionSupplementaryElement(section: section,
                                                         dequeueMethod: header.dequeueMethod,
                                                         reuseIdentifier: header.reuseIdentifier,
                                                         kind: kind,
                                                         configure: header.configure)
        } else {
            self.header = nil
        }

        if let footer = footer {
            let kind: CollectionElementKind
            if case .automatic = footer.kind {
                kind = .custom(kind: UICollectionView.elementKindSectionFooter)
            } else {
                kind = footer.kind
            }

            self.footer = CollectionSupplementaryElement(section: section,
                                                         dequeueMethod: footer.dequeueMethod,
                                                         reuseIdentifier: footer.reuseIdentifier,
                                                         kind: kind,
                                                         configure: footer.configure)
        } else {
            self.footer = nil
        }
    }

}
