import Foundation

public protocol SectionProvider: class {

    var updateDelegate: SectionProviderUpdateDelegate? { get set }

    var sections: [Section] { get }

    var isEmpty: Bool { get }

    var numberOfSections: Int { get }

}

public extension SectionProvider {

    var isEmpty: Bool {
        return sections.isEmpty || sections.allSatisfy { $0.isEmpty }
    }

    var numberOfSections: Int {
        return sections.count
    }

}

public protocol AggregateSectionProvider: SectionProvider {

    var providers: [SectionProvider] { get }

    /**
     Calculates the section offset for the provided section provider in the
     context of the callee

     - parameter provider: The provider to calculate the section offset of
     - returns: The section offset of the provided section provider, or -1 if
     the section provider is not in the hierachy
     */
    func sectionOffset(for provider: SectionProvider) -> Int

}

public struct HashableProvider: Hashable {

    public static func == (lhs: HashableProvider, rhs: HashableProvider) -> Bool {
        return lhs.provider === rhs.provider
    }

    private let provider: SectionProvider

    public init(_ provider: SectionProvider) {
        self.provider = provider
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(provider))
    }

}


public protocol SectionProviderUpdateDelegate: class {
    func invalidateAll(_ provider: SectionProvider)
    func willBeginUpdating(_ provider: SectionProvider)
    func didEndUpdating(_ provider: SectionProvider)
    
    func provider(_ provider: SectionProvider, didInsertSections sections: [Section], at indexes: IndexSet)
    func provider(_ provider: SectionProvider, didRemoveSections sections: [Section], at indexes: IndexSet)
}

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
