import Foundation
import CoreGraphics

public protocol Section: class {
    var numberOfElements: Int { get }
    var updateDelegate: SectionUpdateDelegate? { get set }
}

public extension Section {
    var isEmpty: Bool { return numberOfElements == 0 }
}

public protocol SectionUpdateDelegate: class {
    func section(_ section: Section, didInsertElementAt index: Int)
    func section(_ section: Section, didRemoveElementAt index: Int)
    func section(_ section: Section, didUpdateElementAt index: Int)
    func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int)

    func selectedIndexes(in section: Section) -> [Int]
    func section(_ section: Section, select index: Int)
    func section(_ section: Section, deselect index: Int)
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
