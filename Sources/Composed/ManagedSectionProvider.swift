import CoreData

public final class Persistence {

    public let persistentContainer: NSPersistentContainer
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    public var newBackgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
            
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
}

open class ManagedSection<Element>: Section where Element: NSManagedObject {

    public let persistence: Persistence
    public let sectionInfo: NSFetchedResultsSectionInfo
    public var updateDelegate: SectionUpdateDelegate?

    public var elements: [Element] {
        return sectionInfo.objects as? [Element] ?? []
    }

    public var numberOfElements: Int {
        return sectionInfo.numberOfObjects
    }

    public func element(at index: Int) -> Element {
        return sectionInfo.objects?[index] as! Element
    }

    public required init(sectionInfo: NSFetchedResultsSectionInfo, persistence: Persistence) {
        self.sectionInfo = sectionInfo
        self.persistence = persistence
    }

}

open class ManagedSectionProvider<ManagedSection, Element>: NSObject, SectionProvider, SectionProviderUpdateDelegate, NSFetchedResultsControllerDelegate where ManagedSection: Composed.ManagedSection<Element> {

    public var updateDelegate: SectionProviderUpdateDelegate?

    public private(set) var sections: [Composed.Section] = []

    private let persistence: Persistence
    fileprivate var fetchedResultsController: NSFetchedResultsController<Element>?

    public init(persistence: Persistence) {
        self.persistence = persistence
    }

    public func replace(fetchRequest: NSFetchRequest<Element>, sectionNameKeyPath: String? = nil) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistence.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        fetchedResultsController?.delegate = self
        updateDelegate?.providerDidUpdate(self)
        
        do {
            try fetchedResultsController?.performFetch()
            (fetchedResultsController?.sections ?? []).forEach {
                let section = ManagedSection(sectionInfo: $0, persistence: persistence)
                sections.append(section)
                didInsert(section: section, at: sections.count - 1)
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

    open func didInsert(section: ManagedSection, at index: Int) { }
    open func didRemove(section: ManagedSection, at index: Int) { }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.providerWillUpdate(self)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        assert(Thread.isMainThread)

        switch type {
        case .insert:
            let section = ManagedSection(sectionInfo: sectionInfo, persistence: persistence)
            sections.append(section)
            updateDelegate?.provider(self, didInsertSections: [section], at: IndexSet(integer: sectionIndex))
            didInsert(section: section, at: sectionIndex)
        case .delete:
            let section = sections[sectionIndex] as! ManagedSection
            sections.remove(at: sectionIndex)
            updateDelegate?.provider(self, didRemoveSections: [section], at: IndexSet(integer: sectionIndex))
            didRemove(section: section, at: sectionIndex)
        default:
            updateDelegate?.providerDidReload(self)
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        assert(Thread.isMainThread)

        switch type {
        case .insert:
            let section = sections[newIndexPath!.section]

            if let sections = controller.sections,
                newIndexPath!.section > sections.count {
                updateDelegate?.providerDidReload(self)
            } else {
                section.updateDelegate?.section(section, didInsertElementAt: newIndexPath!.item)
            }
        case .delete:
            let section = sections[indexPath!.section]

            if let sections = controller.sections,
                !sections.isEmpty,
                sections[indexPath!.section].numberOfObjects == 1 {
                updateDelegate?.providerDidReload(self)
            } else {
                section.updateDelegate?.section(section, didRemoveElementAt: indexPath!.item)
            }
        case .update:
            let section = sections[indexPath!.section]
            section.updateDelegate?.section(section, didUpdateElementAt: indexPath!.item)
        case .move:
            let fromSection = sections[indexPath!.section]
            let toSection = sections[newIndexPath!.section]

            if indexPath == newIndexPath {
                fromSection.updateDelegate?.section(fromSection, didUpdateElementAt: indexPath!.item)
            } else {
                fromSection.updateDelegate?.section(fromSection, didRemoveElementAt: indexPath!.item)
                toSection.updateDelegate?.section(toSection, didInsertElementAt: newIndexPath!.item)
            }
        default: fatalError("Unsupported type")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDelegate?.providerDidUpdate(self)
    }

}
