import Foundation

/**
 Represents an collection of `Section`'s and `SectionProvider`'s. The provider supports infinite nesting, including other `SegmentedSectionProvider`'s. One or zero children may be active at any time, so `numberOfSections` and `numberOfElements(in:)` will return values representative of the currenly active child only.

     let provider = SegmentedSectionProvider()
     provider.append(section1) // 5 elements
     provider.append(section2) // 3 elements

     provider.currentIndex = 1

     provider.numberOfSections        // returns 1
     provider.numberOfElements(in: 0) // return 3
     provider.numberOfElements(in: 1) // out-of-bounds error
 */
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

    open weak var updateDelegate: SectionProviderUpdateDelegate?

    /// Represents all of the children this provider contains
    private var children: [Child] = []

    private var _currentIndex: Int = -1

    /// Get/set the index of the child to make 'active'
    public var currentIndex: Int {
        get { _currentIndex }
        set {
            _currentIndex = newValue
            updateDelegate?.invalidateAll(self)
        }
    }

    /// Returns the currently 'active' child
    private var currentChild: Child? {
        guard children.indices.contains(_currentIndex) else { return nil }
        return children[_currentIndex]
    }

    /// Returns all the providers this provider contains
    public var providers: [SectionProvider] {
        switch currentChild {
        case .section:
            return []
        case let .provider(childProvider):
            return [childProvider]
        case .none:
            return []
        }
    }

    /// Returns all the sections this provider contains
    public var sections: [Section] {
        switch currentChild {
        case let .provider(childProvider):
            return childProvider.sections
        case let .section(section):
            return [section]
        case .none:
            return []
        }
    }

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

    /// Returns the number of elements in the specified section
    /// - Parameter section: The section index
    /// - Returns: The number of elements
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

    /// Appends the specified `SectionProvider` to the provider
    /// - Parameter child: The `SectionProvider` to append
    public func append(_ child: SectionProvider) {
        insert(child, at: children.count)
    }

    /// Appends the specified `Section` to the provider
    /// - Parameter child: The `Section` to append
    public func append(_ child: Section) {
        insert(child, at: children.count)
    }

    /// Inserts the specified `SectionProvider` at the given index
    /// - Parameters:
    ///   - child: The `SectionProvider` to insert
    ///   - index: The index where the `SectionProvider` should be inserted
    public func insert(_ child: SectionProvider, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.provider(child), at: index)
        insert(at: index)
    }

    /// Inserts the specified `Section` at the given index
    /// - Parameters:
    ///   - child: The `Section` to insert
    ///   - index: The index where the `Section` should be inserted
    public func insert(_ child: Section, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.section(child), at: index)
        insert(at: index)
    }

    private func insert(at index: Int) {
        // if we don't have a `currentChild` yet, update it
        guard currentChild == nil else { return }
        _currentIndex = index
        insert(newIndex: index, newChild: currentChild)
    }

    /// Removes the specified `Section`
    /// - Parameter child: The `Section` to remove
    public func remove(_ child: Section) {
        remove(.section(child))
    }

    /// Removes the specified `SectionProvider`
    /// - Parameter child: The `SectionProvider` to remove
    public func remove(_ child: SectionProvider) {
        remove(.provider(child))
    }

    private func remove(_ child: Child) {
        guard let index = children.firstIndex(of: child) else { return }
        remove(at: index)
    }

    /// Remove the child at the specified index
    /// - Parameter index: The index to remove
    public func remove(at index: Int) {
        guard children.indices.contains(index) else { return }
        let oldChild = currentChild
        let oldIndex = currentIndex

        children.remove(at: index)

        if oldIndex == index {
            _currentIndex = max(-1, _currentIndex - 1)
        }

        remove(oldIndex: oldIndex, oldChild: oldChild)
    }

    private func remove(oldIndex: Int, oldChild: Child?) {
        switch oldChild {
        case .provider(let provider):
            updateDelegate?.provider(self, didRemoveSections: provider.sections, at: IndexSet(provider.sections.indices))
        case .section(let section):
            updateDelegate?.provider(self, didRemoveSections: [section], at: IndexSet(integer: 0))
        case .none:
            break
        }
    }

    private func insert(newIndex: Int, newChild: Child?) {
        switch newChild {
        case .provider(let provider):
            updateDelegate?.provider(self, didInsertSections: provider.sections, at: IndexSet(provider.sections.indices))
        case .section(let section):
            updateDelegate?.provider(self, didInsertSections: [section], at: IndexSet(integer: 0))
        case .none:
            break
        }
    }

}
