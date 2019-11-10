import Foundation

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
}
