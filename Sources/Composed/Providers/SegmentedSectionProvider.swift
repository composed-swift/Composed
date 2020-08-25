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

    public enum Child: Equatable {
        case provider(SectionProvider)
        case section(Section)

        public static func == (lhs: Child, rhs: Child) -> Bool {
            switch (lhs, rhs) {
            case let (.section(lhs), .section(rhs)): return lhs === rhs
            case let (.provider(lhs), .provider(rhs)): return lhs === rhs
            default: return false
            }
        }
    }

    open weak var updateDelegate: SectionProviderUpdateDelegate?

    /// Represents all of the children this provider contains
    public private(set) var children: [Child] = []

    private var _currentIndex: Int = -1
    /// Get/set the index of the child to make 'active'
    public var currentIndex: Int {
        get { _currentIndex }
        set {
            if children.isEmpty { _currentIndex = -1 }

            // grab the old index
            let oldIndex = _currentIndex
            // clamp the value
            let newIndex = max(0, min(children.count - 1, newValue))

            // if the value won't result in a change, ignore it
            if _currentIndex == newIndex { return }

            updateDelegate?.willBeginUpdating(self)
            _currentIndex = newIndex
            updateDelegate(forRemovalOf: children[oldIndex])
            updateDelegate(forInsertionOf: children[newIndex])
            updateDelegate?.didEndUpdating(self)
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
        guard (children.startIndex...children.endIndex).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.provider(child), at: index)
        insert(at: index)
    }

    /// Inserts the specified `Section` at the given index
    /// - Parameters:
    ///   - child: The `Section` to insert
    ///   - index: The index where the `Section` should be inserted
    public func insert(_ child: Section, at index: Int) {
        guard (children.startIndex...children.endIndex).contains(index) else { fatalError("Index out of bounds: \(index)") }
        children.insert(.section(child), at: index)
        insert(at: index)
    }

    private func insert(at index: Int) {
        if children.count == 1 {
            _currentIndex = index
            updateDelegate(forInsertionOf: currentChild)
        } else if index <= _currentIndex {
            // Just keep the index in sync
            _currentIndex += 1
        } else {
            // we're inserting at the end, do nothing
        }
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

        let child = currentChild
        children.remove(at: index)

        // if this is the last section
        if children.isEmpty {
            _currentIndex = -1
            updateDelegate(forRemovalOf: child)
        }
        // if our index is still technically valid
        else if _currentIndex <= children.count - 1 {
            updateDelegate?.willBeginUpdating(self)
            updateDelegate(forRemovalOf: child)
            updateDelegate(forInsertionOf: currentChild)
            updateDelegate?.didEndUpdating(self)
        }
        // if our index should be decremented
        else {
            updateDelegate?.willBeginUpdating(self)
            _currentIndex -= 1
            updateDelegate(forRemovalOf: child)
            updateDelegate(forInsertionOf: currentChild)
            updateDelegate?.didEndUpdating(self)
        }
    }

    // MARK: UpdateDelegate

    private func updateDelegate(forRemovalOf child: Child?) {
        switch child {
        case let .provider(provider):
            provider.updateDelegate = nil
            updateDelegate?.provider(self, didRemoveSections: provider.sections, at: IndexSet(provider.sections.indices))
        case let .section(section):
            updateDelegate?.provider(self, didRemoveSections: [section], at: IndexSet(integer: 0))
        case .none:
            break
        }
    }

    private func updateDelegate(forInsertionOf child: Child?) {
        switch child {
        case let .provider(provider):
            provider.updateDelegate = self
            updateDelegate?.provider(self, didInsertSections: provider.sections, at: IndexSet(provider.sections.indices))
        case let .section(section):
            updateDelegate?.provider(self, didInsertSections: [section], at: IndexSet(integer: 0))
        case .none:
            break
        }
    }

}
