import Foundation

open class SegmentedSectionProvider: AggregateSectionProvider, SectionProviderUpdateDelegate {

    private enum Child: Equatable {
        case provider(SectionProvider)
        case section(Section)

        static func == (lhs: Child, rhs: Child) -> Bool {
            switch (lhs, rhs) {
            case let (.section(lhs), .section(rhs)): return lhs === rhs
            case let (.provider(lhs), .provider(rhs)): return lhs === rhs
            default: return false
            }
        }
    }

    open var updateDelegate: SectionProviderUpdateDelegate?
    public var currentIndex: Int = -1 {
        didSet { updateDelegate?.invalidateAll(self) }
    }

    private var currentChild: Child? {
        guard children.indices.contains(currentIndex) else { return nil }
        return children[currentIndex]
    }

    open var providers: [SectionProvider] {
        switch currentChild {
        case .section:
            return []
        case let .provider(childProvider):
            return [childProvider]
        case .none:
            return []
        }
    }

    open var sections: [Section] {
        switch currentChild {
        case let .provider(childProvider):
            return childProvider.sections
        case let .section(section):
            return [section]
        case .none:
            return []
        }
    }

    private var children: [Child] = []

    public init() { }

    public var numberOfSections: Int {
        switch currentChild {
        case let .provider(childProvider):
            return childProvider.numberOfSections
        case .section:
            return 1
        case .none:
            return 0
        }
    }

    public func numberOfElements(in section: Int) -> Int {
        return sections[section].numberOfElements
    }

    public func sectionOffset(for provider: SectionProvider) -> Int {
        guard provider !== self else { return 0 }

        var offset: Int = 0

        switch currentChild {
        case .section:
            offset += 1
        case .provider(let childProvider):
            if childProvider === provider {
                return offset
            } else if let childProvider = childProvider as? AggregateSectionProvider {
                let sectionOffset = childProvider.sectionOffset(for: provider)
                if sectionOffset != -1 {
                    return offset + sectionOffset
                }
            }

            offset += childProvider.numberOfSections
        case .none:
            break
        }

        return -1
    }

    public func append(_ child: SectionProvider) {
        insert(child, at: children.count)
    }

    public func append(_ child: Section) {
        insert(child, at: children.count)
    }

    public func insert(_ child: SectionProvider, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.provider(child), at: index)
        insert(at: index)
    }

    public func insert(_ child: Section, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.section(child), at: index)
        insert(at: index)
    }

    func insert(at index: Int) {
        // if we don't have a `currentChild` yet, update it
        guard currentChild == nil else { return }
        currentIndex = index
        updateDelegate?.invalidateAll(self)
    }

    public func remove(_ child: Section) {
        remove(.section(child))
    }

    public func remove(_ child: SectionProvider) {
        remove(.provider(child))
    }

    private func remove(_ child: Child) {
        guard let index = children.firstIndex(of: child) else { return }
        remove(at: index)
    }

    public func remove(at index: Int) {
        guard children.indices.contains(index) else { return }
        children.remove(at: index)

        if currentIndex == index {
            currentIndex = max(-1, currentIndex - 1)
        }

        updateDelegate?.invalidateAll(self)
    }

}
