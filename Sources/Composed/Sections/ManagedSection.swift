import CoreData

/**
 Represents a section that provides its elements via an `NSFetchedResultsController`. This section is useful for representing data managed by CoreData.

 This type conforms to various standard library protocols to provide a more familiar API.

 `ManagedSection` conforms to the following protocols from the standard library:

     Sequence
     RandomAccessCollection
     BidirectionalCollection

 Example usage:

     let section = ManagedSection<Person>(managedObjectContext: context)
     let request: NSFetchRequest<Person> = Person.fetchRequest()
     request.sortDescriptors = [...]
     section.replace(fetchRequest: request)
 */
open class ManagedSection<Element>: NSObject, NSFetchedResultsControllerDelegate, Section where Element: NSManagedObject {

    /// Returns the `NSManagedObjectContext` associated with this section
    public let managedObjectContext: NSManagedObjectContext

    public var updateDelegate: SectionUpdateDelegate?

    // The current controller that will return elements
    private var fetchedResultsController: NSFetchedResultsController<Element>?

    // A convenience property for return all fetched elements
    public var elements: [Element] {
        return fetchedResultsController?.fetchedObjects ?? []
    }

    public var numberOfElements: Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    /// Makes a `ManagedSection` with the specified context and optional request
    /// - Parameters:
    ///   - managedObjectContext: The context to associate with this section
    ///   - fetchRequest: The initial request to use for fetching data (optional)
    public init(managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<Element>? = nil) {
        self.managedObjectContext = managedObjectContext
        super.init()

        if let fetchRequest = fetchRequest {
            replace(fetchRequest: fetchRequest)
        }
    }

    /// Replaces the current fetch request with the specified request
    /// - Parameter fetchRequest: The new fetch request
    public func replace(fetchRequest: NSFetchRequest<Element>, cacheName: String? = nil) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: cacheName)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            updateDelegate?.invalidateAll(self)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    /// Returns the element at the specified index
    /// - Parameter index: The position of the element to access. `index` must be greater than or equal to `startIndex` and less than `endIndex`.
    /// - Returns: If the index is valid, the element. Otherwise
    public func element(at index: Int) -> Element {
        guard let controller = fetchedResultsController else {
            fatalError("A valid fetchRequest has not been configured. You must provide a fetchRequest before calling this method.")
        }

        return controller.object(at: IndexPath(item: index, section: 0))
    }

    /// The index of the specified element. Returns nil if the element is _not_ in this section.
    /// - Parameter element: The element to look lookup
    /// - Returns: The index of the element if it is in this section, nil otherwise
    public func index(of element: Element) -> Int? {
        return fetchedResultsController?.indexPath(forObject: element)?.item
    }

    public private(set) var isSuspended: Bool = false

    public func suspend() {
        isSuspended = true
    }

    public func resume() {
        isSuspended = false
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard !isSuspended else { return }
        updateDelegate?.willBeginUpdating(self)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard !isSuspended else { return }

        switch type {
        case .insert:
            updateDelegate?.section(self, didInsertElementAt: newIndexPath!.item)
        case .delete:
            let sections = fetchedResultsController?.sections ?? []
            if !sections.isEmpty, sections.first?.numberOfObjects == 0 {
                updateDelegate?.invalidateAll(self)
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
        guard !isSuspended else { return }
        updateDelegate?.didEndUpdating(self)
    }

}

extension ManagedSection: RandomAccessCollection, BidirectionalCollection {

    public typealias Index = Array<Element>.Index

    public var isEmpty: Bool { return elements.isEmpty }
    public var startIndex: Index { return elements.startIndex }
    public var endIndex: Index { return elements.endIndex }

    public subscript(position: Index) -> Element {
        return elements[position]
    }

}

extension ManagedSection: Sequence {

    public typealias Iterator = Array<Element>.Iterator

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return elements.makeIterator()
    }

}
