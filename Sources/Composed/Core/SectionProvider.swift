import Foundation

/// Represents a collection of `Section`'s.
public protocol SectionProvider: AnyObject {

    /// The child sections contained in this provider
    var sections: [Section] { get }

    /// The number of sections in this provider
    var numberOfSections: Int { get }

    /// The delegate that will respond to updates
    var updateDelegate: SectionProviderUpdateDelegate? { get set }

}

public extension SectionProvider {

    /// Returns true if the provider contains no sections or all of its sections are empty, false otherwise
    var isEmpty: Bool {
        return sections.isEmpty || sections.allSatisfy { $0.isEmpty }
    }

    var numberOfSections: Int {
        return sections.count
    }

}

/// Represents a collection of `SectionProvider`'s
public protocol AggregateSectionProvider: SectionProvider {

    var providers: [SectionProvider] { get }

    /**
     Calculates the section offset for the provided section provider in the
     context of the callee

     - parameter provider: The provider to calculate the section offset of
     - returns: The section offset of the provided section provider, or `nil` if
     the section provider is not in the hierachy
     */
    func sectionOffset(for provider: SectionProvider) -> Int?

}

/// A delegate that will respond to update events from a `SectionProvider`
public protocol SectionProviderUpdateDelegate: AnyObject {

    /// /// Notifies the delegate before a provider will process updates
    /// - Parameter provider: The provider that will be updated
    func willBeginUpdating(_ provider: SectionProvider)

    /// Notifies the delegate after a provider has processed updates
    /// - Parameter provider: The provider that was updated
    func didEndUpdating(_ provider: SectionProvider)

    /// Notifies the delegate that all sections should be invalidated, ignoring individual updates
    /// - Parameter provider: The provider that requested the invalidation
    func invalidateAll(_ provider: SectionProvider)

    /// Notifies the delegate that sections were inserted
    /// - Parameters:
    ///   - provider: The provider where the inserts occurred
    ///   - sections: The sections that were inserted
    ///   - indexes: The indexes of the sections that were inserted
    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet)

    /// Notifies the delegate that sections were removed
    /// - Parameters:
    ///   - provider: The provider where the removes occurred
    ///   - sections: The sections that were removed
    ///   - indexes: The indexes of the sections that were removed
    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet)
}

// Default implementations to minimise `SectionProvider` implementation requirements
public extension SectionProviderUpdateDelegate where Self: SectionProvider {

    func willBeginUpdating(_ provider: SectionProvider) {
        updateDelegate?.willBeginUpdating(self)
    }

    func didEndUpdating(_ provider: SectionProvider) {
        updateDelegate?.didEndUpdating(self)
    }

    func invalidateAll(_ provider: SectionProvider) {
        updateDelegate?.invalidateAll(provider)
    }

    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet) {
        updateDelegate?.provider(provider, didInsertSections: sections, at: indexes)
    }

    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet) {
        updateDelegate?.provider(provider, didRemoveSections: sections, at: indexes)
    }

}
