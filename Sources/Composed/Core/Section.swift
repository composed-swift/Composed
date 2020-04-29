import Foundation
import CoreGraphics

/// Rerepresents a single section of data. The delegate is used to propogate updates to its 'parent'
public protocol Section: class {

    /// The number of elements contained in this section
    var numberOfElements: Int { get }

    /// The delegate that will respond to updates
    var updateDelegate: SectionUpdateDelegate? { get set }

}

public extension Section {

    /// Returns true if the section contains no elements, false otherwise
    var isEmpty: Bool { return numberOfElements == 0 }

}

public protocol SectionUpdateDelegate: class {

    /// Notifies the delegate before a section will process updates
    /// - Parameter section: The section that will be updated
    func willBeginUpdating(_ section: Section)

    /// Notifies the delegate after a section has processed updates
    /// - Parameter section: The section that was updated
    func didEndUpdating(_ section: Section)

    /// Notifies the delegate that all sections should be invalidated, ignoring individual updates
    /// - Parameter section: The section that requested the invalidation
    func invalidateAll(_ section: Section)

    func section(_ section: Section, didInsertElementAt index: Int)
    func section(_ section: Section, didRemoveElementAt index: Int)
    func section(_ section: Section, didUpdateElementAt index: Int)
    func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int)

    func selectedIndexes(in section: Section) -> [Int]
    func section(_ section: Section, select index: Int)
    func section(_ section: Section, deselect index: Int)

    func isEditing(_ section: Section) -> Bool
}

public struct HashableSection: Hashable {

    public static func == (lhs: HashableSection, rhs: HashableSection) -> Bool {
        return lhs.section === rhs.section
    }

    private let section: Section

    public init(_ section: Section) {
        self.section = section
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(section))
    }

}
