import Foundation

/**
 Represents an collection of `Section`'s and `SectionProvider`'s. The provider supports infinite nesting, including other `ComposedSectionProvider`'s. All children will be active at all times, so `numberOfSections` and `numberOfElements(in:)` will return values representative of all children.

     let provider = ComposedSectionProvider()
     provider.append(section1) // 5 elements
     provider.append(section2) // 3 elements

     provider.numberOfSections        // returns 2
     provider.numberOfElements(in: 0) // returns 5
     provider.numberOfElements(in: 1) // return2 3
 */
open class ComposedSectionProvider: AggregateSectionProvider, SectionProviderUpdateDelegate {

    /// Represents either a section or a provider
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

    /// Returns all the sections this provider contains
    public var sections: [Section] {
        return children.flatMap { kind -> [Section] in
            switch kind {
            case let .section(section):
                return [section]
            case let .provider(provider):
                return provider.sections
            }
        }
    }

    /// Returns all the providers this provider contains
    public var providers: [SectionProvider] {
        return children.compactMap { kind  in
            switch kind {
            case .section: return nil
            case let .provider(provider):
                return provider
            }
        }
    }

    public var numberOfSections: Int {
        return children.reduce(into: 0, { result, kind in
            switch kind {
            case .section: result += 1
            case let .provider(provider): result += provider.numberOfSections
            }
        })
    }

    public init() { }

    /// Returns the number of elements in the specified section
    /// - Parameter section: The section index
    /// - Returns: The number of elements
    public func numberOfElements(in section: Int) -> Int {
        return sections[section].numberOfElements
    }

    public func sectionOffset(for provider: SectionProvider) -> Int {
        guard provider !== self else { return 0 }

        var offset: Int = 0

        for child in children {
            switch child {
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
            }
        }

        // Provider is not in the hierachy
        return -1
    }

    public func sectionOffset(for section: Section) -> Int {
        var offset: Int = 0

        for child in children {
            switch child {
            case .section(let childSection):
                if childSection === section {
                    return offset
                }

                offset += 1
            case .provider(let childProvider):
                if let childProvider = childProvider as? AggregateSectionProvider {
                    if let index = childProvider.sections.firstIndex(where: { $0 === section }) {
                        return offset + index
                    }
                }

                offset += childProvider.numberOfSections
            }
        }

        // Provider is not in the hierachy
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

    /// Inserts the specified `Section` at the given index
    /// - Parameters:
    ///   - child: The `Section` to insert
    ///   - index: The index where the `Section` should be inserted
    public func insert(_ child: Section, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }

        updateDelegate?.willBeginUpdating(self)
        children.insert(.section(child), at: index)
        let sectionOffset = self.sectionOffset(for: child)
        updateDelegate?.provider(self, didInsertSections: [child], at: IndexSet(integer: sectionOffset))
        updateDelegate?.didEndUpdating(self)
    }

    /// Inserts the specified `SectionProvider` at the given index
    /// - Parameters:
    ///   - child: The `SectionProvider` to insert
    ///   - index: The index where the `SectionProvider` should be inserted
    public func insert(_ child: SectionProvider, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }

        child.updateDelegate = self

        updateDelegate?.willBeginUpdating(self)
        children.insert(.provider(child), at: index)
        let firstIndex = sectionOffset(for: child)
        let endIndex = firstIndex + child.sections.count
        updateDelegate?.provider(self, didInsertSections: child.sections, at: IndexSet(integersIn: firstIndex..<endIndex))
        updateDelegate?.didEndUpdating(self)
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
        let child = children[index]
        var sections: [Section] = []

        switch child {
        case let .section(child):
            sections.append(child)
        case let .provider(child):
            child.updateDelegate = nil
            sections.append(contentsOf: child.sections)
        }

        let firstIndex = index
        let endIndex = index + sections.count

        updateDelegate?.willBeginUpdating(self)
        children.remove(at: index)
        updateDelegate?.provider(self, didRemoveSections: sections, at: IndexSet(integersIn: firstIndex..<endIndex))
        updateDelegate?.didEndUpdating(self)
    }

}
