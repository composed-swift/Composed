import Foundation

open class ArraySection<Element>: Section {

    public weak var updateDelegate: SectionUpdateDelegate?

    public private(set) var elements: [Element]

    public init(elements: [Element] = []) {
        self.elements = elements
    }

    public func element(at index: Int) -> Element {
        return elements[index]
    }

    public var numberOfElements: Int {
        return elements.count
    }

    public func append(element: Element) {
        let index = elements.count
        elements.append(element)
        updateDelegate?.section(self, didInsertElementAt: index)
    }

    public func replace(elements: [Element]) {
        self.elements = elements
        updateDelegate?.sectionDidReload(self)
    }

}
