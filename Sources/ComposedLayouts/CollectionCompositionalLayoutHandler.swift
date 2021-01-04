import UIKit
import ComposedUI

@available(iOS 13.0, *)
/// Conform your section to this protocol to provide a layout section for a `UICollectionViewCompositionalLayout`
public protocol CompositionalLayoutHandler: CollectionSectionProvider {

    /// Return a layout section for this section
    /// - Parameter environment: The current environment for this layout
    func compositionalLayoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?

}
