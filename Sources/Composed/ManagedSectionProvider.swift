import CoreData

open class ManagedSection<Element>: Section where Element: NSManagedObject {

    fileprivate weak var parent: ManagedSectionProvider<ManagedSection<Element>, Element>?
    public var updateDelegate: SectionUpdateDelegate?

    public var numberOfElements: Int {
        return parent!.numberOfElements(in: self)
    }

    public func element(at index: Int) -> Element {
        return parent!.element(in: self, at: index)
    }

    public required init() { }

}

public final class ManagedSectionProvider<Section, Element>: NSObject, SectionProvider, SectionProviderUpdateDelegate, NSFetchedResultsControllerDelegate where Section: ManagedSection<Element> {

    public var updateDelegate: SectionProviderUpdateDelegate?

    public private(set) var sections: [Composed.Section] = []

    private let managedObjectContext: NSManagedObjectContext
    fileprivate var fetchedResultsController: NSFetchedResultsController<Element>?

    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
    }

    public func replace(fetchRequest: NSFetchRequest<Element>, sectionNameKeyPath: String? = nil) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        fetchedResultsController?.delegate = self
        updateDelegate?.providerDidUpdate(self)
        
        do {
            try fetchedResultsController?.performFetch()
            for _ in fetchedResultsController!.sections ?? [] {
                let section = Section.init()
                section.parent = self as? ManagedSectionProvider<ManagedSection<Element>, Element>

                // this ends up as nil! Can we get the data another way???
                
                sections.append(section)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public var numberOfSections: Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    public func numberOfElements(in section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    private func index(of section: Section) -> Int {
        guard let section = sections.firstIndex(where: { HashableSection(section) == HashableSection($0) }) else {
            fatalError("Section does not belong to this provider")
        }
        return section
    }

    internal func numberOfElements(in section: Section) -> Int {
        let index = self.index(of: section)
        return numberOfElements(in: index)
    }

    internal func element(in section: Section, at index: Int) -> Element {
        guard let controller = fetchedResultsController else { fatalError("No fetchResultsController attached") }
        return controller.object(at: IndexPath(item: index, section: self.index(of: section)))
    }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.providerWillUpdate(self)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let section = Section.init()
            section.parent = self as? ManagedSectionProvider<ManagedSection<Element>, Element>
            sections.append(section)
            updateDelegate?.provider(self, didInsertSections: [section], at: IndexSet(integer: sectionIndex))
        case .delete:
            let section = sections[sectionIndex]
            sections.remove(at: sectionIndex)
            updateDelegate?.provider(self, didRemoveSections: [section], at: IndexSet(integer: sectionIndex))
        default: fatalError("Unsupported type")
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let section = sections[newIndexPath!.section]
            section.updateDelegate?.section(section, didInsertElementAt: newIndexPath!.item)
        case .delete:
            let section = sections[indexPath!.section]
            section.updateDelegate?.section(section, didRemoveElementAt: indexPath!.item)
        case .update:
            let section = sections[indexPath!.section]
            section.updateDelegate?.section(section, didUpdateElementAt: indexPath!.item)
        case .move:
            let fromSection = sections[indexPath!.section]
            let toSection = sections[newIndexPath!.section]

            fromSection.updateDelegate?.section(fromSection, didRemoveElementAt: indexPath!.item)
            toSection.updateDelegate?.section(toSection, didInsertElementAt: newIndexPath!.item)
        default: fatalError("Unsupported type")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.providerDidUpdate(self)
    }

}
