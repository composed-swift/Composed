import Foundation

open class SingleElementSection<Element>: Section {

    public var updateDelegate: SectionUpdateDelegate?

    public private(set) var element: Element

    public var numberOfElements: Int {
        switch element as Any {
        case Optional<Any>.none: return 0
        default: return 1
        }
    }

    public init(element: Element) {
        self.element = element
    }

    public func replace(element: Element) {
        let wasEmpty = isEmpty
        self.element = element

        switch (wasEmpty, isEmpty) {
        case (true, true):
            break
        case (true, false):
            updateDelegate?.section(self, didInsertElementAt: 0)
        case (false, true):
            updateDelegate?.section(self, didRemoveElementAt: 0)
        case (false, false):
            updateDelegate?.section(self, didUpdateElementAt: 0)
        }
    }

}
