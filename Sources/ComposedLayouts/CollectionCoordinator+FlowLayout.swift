import UIKit
import ComposedUI

extension CollectionCoordinator: UICollectionViewDelegateFlowLayout {

    private func suggestedMetrics(for layout: UICollectionViewFlowLayout) -> CollectionFlowLayoutMetrics {
        var metrics = CollectionFlowLayoutMetrics()
        metrics.contentInsets = layout.sectionInset
        metrics.minimumInteritemSpacing = layout.minimumInteritemSpacing
        metrics.minimumLineSpacing = layout.minimumLineSpacing
        return metrics
    }

    private func metrics(for section: CollectionFlowLayoutHandler, collectionView: UICollectionView, layout: UICollectionViewFlowLayout) -> CollectionFlowLayoutMetrics {
        return section.layoutMetrics(suggested: suggestedMetrics(for: layout), environment: environment(collectionView: collectionView, layout: layout))
    }

    private func environment(collectionView: UICollectionView, layout: UICollectionViewFlowLayout) -> CollectionFlowLayoutEnvironment {
        let size = collectionView.bounds.insetBy(dx: layout.sectionInset.left + layout.sectionInset.right, dy: 0).size
        return CollectionFlowLayoutEnvironment(contentSize: size, traitCollection: collectionView.traitCollection)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let suggested = layout.estimatedItemSize == .zero ? layout.itemSize : layout.estimatedItemSize
        guard let section = sectionProvider.sections[indexPath.section] as? CollectionFlowLayoutHandler else { return suggested }
        let metrics = self.metrics(for: section, collectionView: collectionView, layout: layout)
        return section.sizeForItem(at: indexPath.item, suggested: suggested, metrics: metrics, environment: environment(collectionView: collectionView, layout: layout))
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        guard let section = sectionProvider.sections[section] as? CollectionFlowLayoutHandler else { return layout.sectionInset }
        return metrics(for: section, collectionView: collectionView, layout: layout).contentInsets
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        guard let section = sectionProvider.sections[section] as? CollectionFlowLayoutHandler else { return layout.minimumLineSpacing }
        return metrics(for: section, collectionView: collectionView, layout: layout).minimumLineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        guard let section = sectionProvider.sections[section] as? CollectionFlowLayoutHandler else { return layout.minimumInteritemSpacing }
        return metrics(for: section, collectionView: collectionView, layout: layout).minimumInteritemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        guard let section = sectionProvider.sections[section] as? CollectionFlowLayoutHandler else { return layout.headerReferenceSize }
        return section.referenceHeaderSize(suggested: layout.headerReferenceSize, environment: environment(collectionView: collectionView, layout: layout))
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        guard let section = sectionProvider.sections[section] as? CollectionFlowLayoutHandler else { return layout.footerReferenceSize }
        return section.referenceFooterSize(suggested: layout.footerReferenceSize, environment: environment(collectionView: collectionView, layout: layout))
    }

}
