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
    
    /// Returns all the sections this provider contains
    public private(set) var sections: [Section] = []
    
    public private(set) var numberOfSections: Int = 0
    
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
    
    /// Represents all of the children this provider contains
    private var children: [Child] = []
    
    /// A flag indicating if a child provider is currently removing sections.
    ///
    /// See: `sectionOffset(for:)`
    private var isRemovingChildProviderSections = false
    
    public init() { }
    
    /// Returns the number of elements in the specified section
    /// - Parameter section: The section index
    /// - Returns: The number of elements
    public func numberOfElements(in section: Int) -> Int {
        return sections[section].numberOfElements
    }
    
    /// Calculate the offset for the first section of `provider`, relative to this section provider.
    ///
    /// - parameter provider: The provide to calculate the offset of.
    /// - returns: The offset for the provider, or `nil` if it is not in the hierarchy.
    public func sectionOffset(for provider: SectionProvider) -> Int? {
        guard provider !== self else { return 0 }
        
        /// This functions provides a fast path for when the `provider` is the last provider in the list of
        /// children. This is provided to speed up appends. However, it relies on the provider's `numberOfSections`
        /// to be in-sync with `sections` and `numberOfSections` on `self`. If these values are not in-sync this
        /// may return incorrect results.
        ///
        /// `isRemovingChildProviderSections` is used to track this and prevent the bug.
        if !isRemovingChildProviderSections {
            // A quick test for if this is the last child is a small optimisation, mainly
            // beneficial when the provider has just been appended.
            switch children.last {
            case .some(.provider(let lastProvider)) where lastProvider === provider:
                return numberOfSections - provider.numberOfSections
            default:
                break
            }
        }
        
        var offset: Int = 0
        
        for child in children {
            switch child {
            case .section:
                offset += 1
            case .provider(let childProvider):
                if childProvider === provider {
                    return offset
                } else if let childProvider = childProvider as? AggregateSectionProvider,  let sectionOffset = childProvider.sectionOffset(for: provider) {
                    return offset + sectionOffset
                }
                
                offset += childProvider.numberOfSections
            }
        }
        
        // Provider is not in the hierarchy
        return nil
    }
    
    public func sectionOffset(for section: Section) -> Int? {
        // A quick test for if this is the last child is a small optimisation, mainly
        // beneficial when the section has just been appended.
        switch children.last {
        case .some(.section(let lastSection)) where lastSection === section:
            return numberOfSections - 1
        default:
            break
        }
        
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
        return nil
    }
    
    /// Returns the first index of the `section`, or `nil` if the section is not a child of this
    /// composed section provider.
    ///
    /// - Parameter section: The section to return the first index of.
    /// - Returns: The first index of `section`, or `nil` if the section is not a child.
    public func firstIndex(of section: Section) -> Int? {
        children.firstIndex(of: .section(section))
    }
    
    /// Returns the first index of the `sectionProvider`, or `nil` if the section is not a child of
    /// this composed section provider.
    ///
    /// - Parameter sectionProvider: The section provider to return the first index of.
    /// - Returns: The first index of `sectionProvider`, or `nil` if the section provider is not a child.
    public func firstIndex(of sectionProvider: SectionProvider) -> Int? {
        children.firstIndex(of: .provider(sectionProvider))
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
        
        performBatchUpdates { updateDelegate in
            children.insert(.section(child), at: index)
            numberOfSections += 1
            let sectionOffset = self.sectionOffset(for: child)!
            sections.insert(child, at: sectionOffset)
            updateDelegate?.provider(self, didInsertSections: [child], at: IndexSet(integer: sectionOffset))
        }
    }
    
    /// Inserts the specified `SectionProvider` at the given index
    /// - Parameters:
    ///   - child: The `SectionProvider` to insert
    ///   - index: The index where the `SectionProvider` should be inserted
    public func insert(_ child: SectionProvider, at index: Int) {
        guard (0...children.count).contains(index) else { fatalError("Index out of bounds: \(index)") }
        
        child.updateDelegate = self
        
        performBatchUpdates { updateDelegate in
            children.insert(.provider(child), at: index)
            numberOfSections += child.sections.count
            let firstIndex = sectionOffset(for: child)!
            let endIndex = firstIndex + child.sections.count
            sections.insert(contentsOf: child.sections, at: firstIndex)
            updateDelegate?.provider(self, didInsertSections: child.sections, at: IndexSet(integersIn: firstIndex..<endIndex))
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
        let child = children[index]
        let sections: [Section]
        let sectionOffset: Int
        
        switch child {
        case let .section(child):
            sections = [child]
            sectionOffset = self.sectionOffset(for: child)!
        case let .provider(child):
            child.updateDelegate = nil
            sectionOffset = self.sectionOffset(for: child)!
            sections = child.sections
        }
        
        let firstIndex = sectionOffset
        let endIndex = sectionOffset + sections.count
        
        performBatchUpdates { _ in
            children.remove(at: index)
            numberOfSections -= sections.count
            self.sections.removeSubrange(firstIndex ..< endIndex)
            updateDelegate?.provider(self, didRemoveSections: sections, at: IndexSet(integersIn: firstIndex..<endIndex))
        }
    }
    
    public func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        assert(sections.count == indexes.count, "Number of indexes must equal number of sections inserted")
        
        numberOfSections += sections.count
        
        let sectionOffset = self.sectionOffset(for: provider)!
        
        indexes
            .enumerated()
            .map { element in
                return (sections[element.offset], element.element + sectionOffset)
            }
            .forEach { element in
                self.sections.insert(element.0, at: element.1)
            }
        
        updateDelegate?.provider(provider, didInsertSections: sections, at: indexes)
    }
    
    public func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        assert(sections.count == indexes.count, "Number of indexes must equal number of sections removed")
        
        isRemovingChildProviderSections = true
        
        defer {
            isRemovingChildProviderSections = false
        }
        
        numberOfSections -= sections.count
        let sectionOffset = self.sectionOffset(for: provider)!
        indexes.map { $0 + sectionOffset }.reversed().forEach { self.sections.remove(at: $0) }
        
        updateDelegate?.provider(provider, didRemoveSections: sections, at: indexes)
    }
}

// MARK:- Convenience Functions

extension ComposedSectionProvider {
    /// Returns a bool indicating if the composed section provider contains `section`.
    ///
    /// - Parameter section: The section to search for.
    /// - Returns: `true` if the composed section provider contains `section`, otherwise `false`.
    public func contains(_ section: Section) -> Bool {
        firstIndex(of: section) != nil
    }
    
    /// Returns a bool indicating if the section provider contains `sectionProvider`.
    ///
    /// - Parameter sectionProvider: The section provider to search for.
    /// - Returns: `true` if the composed section provider contains `sectionProvider`, otherwise `false`.
    public func contains(_ sectionProvider: SectionProvider) -> Bool {
        firstIndex(of: sectionProvider) != nil
    }
    
    /// Inserts the provided section after an existing section. If `existingSection` is not a child
    /// of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSection: The section to insert.
    ///   - existingSection: A child section of the composed section provider.
    /// - Returns: The index of the inserted section, or `nil` if `existingSection` is not a child
    ///     of this composed section.
    @discardableResult
    public func insert(_ newSection: Section, after existingSection: Section) -> Int? {
        guard let existingSectionIndex = firstIndex(of: existingSection) else { return nil }
        
        let newIndex = existingSectionIndex + 1
        insert(newSection, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section provider after an existing section. If `existingSection` is not
    /// a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSectionProvider: The section provider to insert.
    ///   - existingSection: A child section of the composed section provider.
    /// - Returns: The index of the inserted section provider, or `nil` if `existingSection` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSectionProvider: SectionProvider, after existingSection: Section) -> Int? {
        guard let existingSectionIndex = firstIndex(of: existingSection) else { return nil }
        
        let newIndex = existingSectionIndex + 1
        insert(newSectionProvider, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section after an existing section provider. If `existingSectionProvider`
    /// is not a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSection: The section to insert.
    ///   - existingSectionProvider: A child section provider of the composed section provider.
    /// - Returns: The index of the inserted section, or `nil` if `existingSectionProvider` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSection: Section, after existingSectionProvider: SectionProvider) -> Int? {
        guard let existingSectionProviderIndex = firstIndex(of: existingSectionProvider) else { return nil }
        
        let newIndex = existingSectionProviderIndex + 1
        insert(newSection, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section provider after an existing section provider. If `existingSectionProvider`
    /// is not a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSectionProvider: The section provider to insert.
    ///   - existingSectionProvider: A child section provider of the composed section provider.
    /// - Returns: The index of the inserted section provider, or `nil` if `existingSection` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSectionProvider: SectionProvider, after existingSectionProvider: SectionProvider) -> Int? {
        guard let existingSectionProviderIndex = firstIndex(of: existingSectionProvider) else { return nil }
        
        let newIndex = existingSectionProviderIndex + 1
        insert(newSectionProvider, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section before an existing section. If `existingSection` is not a child
    /// of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSection: The section to insert.
    ///   - existingSection: A child section of the composed section provider.
    /// - Returns: The index of the inserted section, or `nil` if `existingSection` is not a child
    ///     of this composed section.
    @discardableResult
    public func insert(_ newSection: Section, before existingSection: Section) -> Int? {
        guard let newIndex = firstIndex(of: existingSection) else { return nil }
        
        insert(newSection, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section provider before an existing section. If `existingSection` is not
    /// a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSectionProvider: The section provider to insert.
    ///   - existingSection: A child section of the composed section provider.
    /// - Returns: The index of the inserted section provider, or `nil` if `existingSection` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSectionProvider: SectionProvider, before existingSection: Section) -> Int? {
        guard let newIndex = firstIndex(of: existingSection) else { return nil }
        
        insert(newSectionProvider, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section before an existing section provider. If `existingSectionProvider`
    /// is not a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSection: The section to insert.
    ///   - existingSectionProvider: A child section provider of the composed section provider.
    /// - Returns: The index of the inserted section, or `nil` if `existingSectionProvider` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSection: Section, before existingSectionProvider: SectionProvider) -> Int? {
        guard let newIndex = firstIndex(of: existingSectionProvider) else { return nil }
        
        insert(newSection, at: newIndex)
        
        return newIndex
    }
    
    /// Inserts the provided section provider before an existing section provider. If `existingSectionProvider`
    /// is not a child of this composed section provider this function does nothing.
    ///
    /// - Parameters:
    ///   - newSectionProvider: The section provider to insert.
    ///   - existingSectionProvider: A child section provider of the composed section provider.
    /// - Returns: The index of the inserted section provider, or `nil` if `existingSection` is not
    ///     a child of this composed section.
    @discardableResult
    public func insert(_ newSectionProvider: SectionProvider, before existingSectionProvider: SectionProvider) -> Int? {
        guard let newIndex = firstIndex(of: existingSectionProvider) else { return nil }
        
        insert(newSectionProvider, at: newIndex)
        
        return newIndex
    }
}
