import UIKit
import ComposedUI

/// Encapsulates the metrics for a section
public struct CollectionFlowLayoutMetrics {
    /// Represents the insets applied to the section
    public var contentInsets: UIEdgeInsets = .zero
    /// Represents the spacing between lines in a section
    public var minimumLineSpacing: CGFloat = 0
    /// Represets the spacing between items in a section
    public var minimumInteritemSpacing: CGFloat = 0

    public init() { }
}

/// Represents the current environment for a `UICollectionView`
public struct CollectionFlowLayoutEnvironment {
    /// Returns the current size of the collectionView
    public var contentSize: CGSize {
        collectionView.bounds.insetBy(dx: layout.sectionInset.left + layout.sectionInset.right, dy: 0).size
    }

    /// Returns the current traits of the collectionView
    public var traitCollection: UITraitCollection {
        collectionView.traitCollection
    }

    public let collectionCoordinator: CollectionCoordinator

    public let collectionView: UICollectionView

    public let layout: UICollectionViewFlowLayout

    public let rootSectionIndex: Int

    /// Instantiates a new instance
    /// - Parameters:
    ///   - contentSize: The collection view collectionView
    ///   - layout: The flow layout
    public init(collectionCoordinator: CollectionCoordinator, collectionView: UICollectionView, layout: UICollectionViewFlowLayout, rootSectionIndex: Int) {
        self.collectionCoordinator = collectionCoordinator
        self.collectionView = collectionView
        self.layout = layout
        self.rootSectionIndex = rootSectionIndex
    }
}

/// Conform your section to this protocol to override sizing and metric values for a `UICollectionViewFlowLayout`
public protocol CollectionFlowLayoutHandler: UICollectionViewSection {

    /// Return the size for the element at the specified index
    /// - Parameters:
    ///   - index: The index of the element
    ///   - suggested: A suggested value which is generally inherited from the layout itself
    ///   - metrics: The current metrics for the elements in this section
    ///   - environment: The current environment for this layout
    func sizeForItem(at index: Int, suggested: CGSize, metrics: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CGSize

    /// Return a sizing strategy for the specified index
    /// - Parameters:
    ///   - index: The index of the element
    ///   - metrics: The current metrics for the elements in this section
    ///   - environment: The current environment for this layout
    func sizingStrategy(at index: Int, metrics: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutSizingStrategy?

    /// Return the size for the header in this section
    /// - Parameters:
    ///   - suggested: A suggested value which is generally inherited from the layout itself
    ///   - environment: The current environment for this layout
    func referenceHeaderSize(suggested: CGSize, environment: CollectionFlowLayoutEnvironment) -> CGSize

    /// Return the size for the footer in this section
    /// - Parameters:
    ///   - suggested: A suggested value which is generally inherited from the layout itself
    ///   - environment: The current environment for this layout
    func referenceFooterSize(suggested: CGSize, environment: CollectionFlowLayoutEnvironment) -> CGSize

    /// Return the metrics to be applied to this section
    /// - Parameters:
    ///   - suggested: A suggested value which is generally inherited from the layout itself
    ///   - environment: The current environment for this layout
    func layoutMetrics(suggested: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutMetrics
    
}

// Default implementations
public extension CollectionFlowLayoutHandler {
    func sizeForItem(at index: Int, suggested: CGSize, metrics: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CGSize {
        return sizingStrategy(at: index, metrics: metrics, environment: environment)?
            .size(forElementAt: index, environment: environment)
            ?? suggested
    }
    func sizingStrategy(at index: Int, metrics: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutSizingStrategy? { return nil }
    func referenceHeaderSize(suggested: CGSize, environment: CollectionFlowLayoutEnvironment) -> CGSize { return suggested }
    func referenceFooterSize(suggested: CGSize, environment: CollectionFlowLayoutEnvironment) -> CGSize { return suggested }
    func layoutMetrics(suggested: CollectionFlowLayoutMetrics, environment: CollectionFlowLayoutEnvironment) -> CollectionFlowLayoutMetrics { return suggested }
}
