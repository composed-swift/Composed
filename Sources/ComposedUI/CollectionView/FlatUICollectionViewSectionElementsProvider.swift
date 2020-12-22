import UIKit
import Composed

open class FlatUICollectionViewSectionElementsProvider: UICollectionViewSectionElementsProvider {
    /// The header configuration element
    public let header: CollectionSupplementaryElement<UICollectionReusableView>?

    /// The footer configuration element
    public let footer: CollectionSupplementaryElement<UICollectionReusableView>?

    /// The number of elements in this section
    open var numberOfElements: Int {
        return flatSection?.numberOfElements ?? 0
    }

    // The underlying section associated with this section
    private weak var flatSection: FlatSection?

    private let traitCollection: UITraitCollection

    /// Makes a new configuration with the specified cell, header and/or footer elements
    /// - Parameters:
    ///   - section: The section this will be associated with
    ///   - cell: The cell configuration element
    ///   - header: The header configuration element
    ///   - footer: The footer configuration element
    public init<Header, Footer>(
        section: FlatSection,
        traitCollection: UITraitCollection,
        header: CollectionSupplementaryElement<Header>? = nil,
        footer: CollectionSupplementaryElement<Footer>? = nil
    ) where Header: UICollectionReusableView, Footer: UICollectionReusableView {
        self.flatSection = section
        self.traitCollection = traitCollection

        // The code below copies the relevent elements to erase type-safety

        if let header = header {
            let dequeueMethod: DequeueMethod<UICollectionReusableView>
            switch header.dequeueMethod {
            case .fromClass: dequeueMethod = .fromClass(Header.self)
            case .fromNib: dequeueMethod = .fromNib(Header.self)
            case .fromStoryboard: dequeueMethod = .fromStoryboard(Header.self)
            }

            let kind: CollectionElementKind
            if case .automatic = header.kind {
                kind = .custom(kind: UICollectionView.elementKindSectionHeader)
            } else {
                kind = header.kind
            }

            self.header = CollectionSupplementaryElement(section: section,
                                                         dequeueMethod: dequeueMethod,
                                                         reuseIdentifier: header.reuseIdentifier,
                                                         kind: kind,
                                                         configure: header.configure)
        } else {
            self.header = nil
        }

        if let footer = footer {
            let dequeueMethod: DequeueMethod<UICollectionReusableView>
            switch footer.dequeueMethod {
            case .fromClass: dequeueMethod = .fromClass(Footer.self)
            case .fromNib: dequeueMethod = .fromNib(Footer.self)
            case .fromStoryboard: dequeueMethod = .fromStoryboard(Footer.self)
            }

            let kind: CollectionElementKind
            if case .automatic = footer.kind {
                kind = .custom(kind: UICollectionView.elementKindSectionFooter)
            } else {
                kind = footer.kind
            }

            self.footer = CollectionSupplementaryElement(section: section,
                                                         dequeueMethod: dequeueMethod,
                                                         reuseIdentifier: footer.reuseIdentifier,
                                                         kind: kind,
                                                         configure: footer.configure)
        } else {
            self.footer = nil
        }
    }

    open func cell(for index: Int) -> CollectionCellElement<UICollectionViewCell> {
        guard let (section, offset) = flatSection?.section(at: index) else {
            fatalError("No section for index \(index) exists")
        }

        guard let collectionSectionProvider = section as? UICollectionViewSection else {
            fatalError("Child must conform to `CollectionSectionProvider`")
        }

        let indexInSection = index - offset
        let collectionSection = collectionSectionProvider.collectionViewElementsProvider(with: traitCollection)
        let collectionCellElement = collectionSection.cell(for: indexInSection)
        return FlattenedCollectionCellElement(collectionElement: collectionCellElement, section: section, sectionOffset: offset)
    }
}


extension UICollectionViewSection where Self: FlatSection {
    func collectionViewElementsProvider(with traitCollection: UITraitCollection) -> UICollectionViewSectionElementsProvider {
        FlatUICollectionViewSectionElementsProvider(section: self, traitCollection: traitCollection)
    }
}

private final class FlattenedCollectionCellElement: CollectionCellElement<UICollectionViewCell> {
    fileprivate init(collectionElement element: CollectionCellElement<UICollectionViewCell>, section: Section, sectionOffset: Int) {
        super.init(
            dequeueMethod: element.dequeueMethod,
            reuseIdentifier: element.reuseIdentifier,
            configure: { [weak element, weak section] cell, index in
                guard let element = element else { return }
                guard let section = section else { return }

                let sectionIndex = index - sectionOffset
                element.configure(cell, sectionIndex, section)
            },
            willAppear: { [weak element, weak section] cell, index in
                guard let element = element else { return }
                guard let section = section else { return }

                let sectionIndex = index - sectionOffset
                element.willAppear?(cell, sectionIndex, section)
            },
            didDisappear: { [weak element, weak section] cell, index in
                guard let element = element else { return }
                guard let section = section else { return }

                let sectionIndex = index - sectionOffset
                element.didDisappear?(cell, sectionIndex, section)
            }
        )
    }
}
