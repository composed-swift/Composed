import Foundation

open class ComposedSectionProvider: AggregateSectionProvider, SectionProviderUpdateDelegate {

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

    private var children: [Child] = []

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

    public func append(_ child: SectionProvider) {
        insert(child, at: children.count)
    }

    public func append(_ child: Section) {
        insert(child, at: children.count)
    }

    public func insert(_ child: Section, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }

        let index = index
        updateDelegate?.willBeginUpdating(self)
        children.insert(.section(child), at: index)
        updateDelegate?.provider(self, didInsertSections: [child], at: IndexSet(integer: index))
        updateDelegate?.didEndUpdating(self)
    }

    public func insert(_ child: SectionProvider, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }

        child.updateDelegate = self

        let firstIndex = index
        let endIndex = firstIndex + child.sections.count

        updateDelegate?.willBeginUpdating(self)
        children.insert(.provider(child), at: index)
        updateDelegate?.provider(self, didInsertSections: child.sections, at: IndexSet(integersIn: firstIndex..<endIndex))
        updateDelegate?.didEndUpdating(self)
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
        let child = children[index]
        var sections: [Section] = []

        switch child {
        case let .section(child):
            sections.append(child)
        case let .provider(child):
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
