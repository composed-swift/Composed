import UIKit
import ComposedUI

@available(iOS 13.0, *)
public extension UICollectionViewCompositionalLayout {

    /// Instantiates a new `UICollectionViewCompositionalLayout` for the specified `CollectionCoordinator`
    /// - Parameter coordinator: The coordinator that will use this layout to provide layout data for its sections
    convenience init(coordinator: CollectionCoordinator) {
        self.init { [weak coordinator] index, environment in
            guard coordinator?.sectionProvider.sections.indices.contains(index) == true,
            let section = coordinator?.sectionProvider.sections[index] as? CompositionalLayoutHandler else { return nil }
            return section.compositionalLayoutSection(environment: environment)
        }
    }

}
