import Foundation

/**
 Represents a section that manages a single element. This section is useful when only have a single element to manage. Hint: Use `Optional<T>` to represent an element that may or may not exist.

 Example usage:

     let section = SingleElementSection<Optional<Int>>(element: nil)
     section.numberOfElements    // return 0

     section.replace(element: 0)
     section.numberOfElements    // return 1
 */
open class SingleElementSection<Element>: Section {

    public weak var updateDelegate: SectionUpdateDelegate?

    /// Returns the element
    public private(set) var element: Element

    /// Generally returns 1, however if `element == Optional<Element>.none` returns 0
    public var numberOfElements: Int {
        switch element as Any {
        case Optional<Any>.none: return 0
        default: return 1
        }
    }

    /// Makes a `SingleElementSection` with the specified element
    /// - Parameter element: The element
    public init(element: Element) {
        self.element = element
    }

    /// Replaces the element with the specified element
    /// - Parameter element: The new element
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
