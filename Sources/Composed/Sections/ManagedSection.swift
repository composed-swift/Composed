import CoreData

open class ManagedSection<Element>: NSObject, NSFetchedResultsControllerDelegate, Section where Element: NSManagedObject {

    public let managedObjectContext: NSManagedObjectContext
    public var updateDelegate: SectionUpdateDelegate?

    private var fetchedResultsController: NSFetchedResultsController<Element>?

    public var elements: [Element] {
        return fetchedResultsController?.fetchedObjects ?? []
    }

    public var numberOfElements: Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    public init(managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Element>? = nil) {
        self.managedObjectContext = managedObjectContext
        super.init()

        if let fetchRequest = fetchRequest {
            replace(fetchRequest: fetchRequest)
        }
    }

    public func replace(fetchRequest: NSFetchRequest<Element>) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }

        updateDelegate?.sectionDidReload(self)
    }

    public func element(at index: Int) -> Element {
        guard let controller = fetchedResultsController else {
            fatalError("A valid fetchRequest has not been configured. You must provide a fetchRequest before calling this method.")
        }

        return controller.object(at: IndexPath(item: index, section: 0))
    }

    public func index(of element: Element) -> Int? {
        return fetchedResultsController?.indexPath(forObject: element)?.item
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.sectionWillUpdate(self)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            updateDelegate?.section(self, didInsertElementAt: newIndexPath!.item)
        case .delete:
            let sections = fetchedResultsController?.sections ?? []
            if !sections.isEmpty, sections.first?.numberOfObjects == 0 {
                updateDelegate?.sectionDidReload(self)
            } else {
                updateDelegate?.section(self, didRemoveElementAt: indexPath!.item)
            }
        case .update:
            updateDelegate?.section(self, didUpdateElementAt: indexPath!.item)
        case .move:
            updateDelegate?.section(self, didMoveElementAt: indexPath!.item, to: newIndexPath!.item)
        default:
            fatalError("Unsupported type")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.sectionDidUpdate(self)
    }

}
