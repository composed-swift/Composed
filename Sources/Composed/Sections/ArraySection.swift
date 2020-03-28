import Foundation

open class ArraySection<Element>: Section, ExpressibleByArrayLiteral {

    public weak var updateDelegate: SectionUpdateDelegate?

    public private(set) var elements: [Element]

    public required init() {
        elements = []
    }

    public required init(arrayLiteral elements: Element...) {
        self.elements = elements
    }

    public func element(at index: Int) -> Element {
        return elements[index]
    }

    public var numberOfElements: Int {
        return elements.count
    }

}

extension ArraySection: Sequence {

    public typealias Iterator = Array<Element>.Iterator

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return elements.makeIterator()
    }

}

extension ArraySection: MutableCollection, RandomAccessCollection, BidirectionalCollection {

    public typealias Index = Array<Element>.Index

    public var isEmpty: Bool { return elements.isEmpty }
    public var startIndex: Index { return elements.startIndex }
    public var endIndex: Index { return elements.endIndex }

    public subscript(position: Index) -> Element {
        get { return elements[position] }
        set(newValue) {
            updateDelegate?.sectionWillUpdate(self)
            elements[position] = newValue
            updateDelegate?.section(self, didUpdateElementAt: position)
            updateDelegate?.sectionDidUpdate(self)
        }
    }

    public func append(_ newElement: Element) {
        elements.append(newElement)
        updateDelegate?.section(self, didInsertElementAt: elements.count - 1)
    }

    public func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        updateDelegate?.sectionWillUpdate(self)
        let oldCount = elements.count
        elements.append(contentsOf: newElements)
        let newCount = elements.count
        (oldCount..<newCount).forEach {
            updateDelegate?.section(self, didInsertElementAt: $0)
        }
        updateDelegate?.sectionDidUpdate(self)
    }

    public func insert(_ newElement: Element, at i: Index) {
        updateDelegate?.sectionWillUpdate(self)
        elements.insert(newElement, at: i)
        updateDelegate?.section(self, didInsertElementAt: i)
        updateDelegate?.sectionDidUpdate(self)
    }

    public func insert<C>(contentsOf newElements: C, at i: Index) where C: Collection, Element == C.Element {
        updateDelegate?.sectionWillUpdate(self)
        let oldCount = elements.count
        elements.insert(contentsOf: newElements, at: i)
        let newCount = elements.count
        (oldCount..<newCount).forEach {
            updateDelegate?.section(self, didInsertElementAt: $0)
        }
        updateDelegate?.sectionDidUpdate(self)
    }

    @discardableResult
    public func removeLast() -> Element {
        updateDelegate?.sectionWillUpdate(self)
        let element = elements.removeLast()
        updateDelegate?.section(self, didRemoveElementAt: elements.count)
        updateDelegate?.sectionDidUpdate(self)
        return element
    }

    public func removeLast(_ k: Int) {
        updateDelegate?.sectionWillUpdate(self)
        let oldCount = elements.count
        elements.removeLast(k)
        let newCount = elements.count
        (newCount..<oldCount).forEach {
            updateDelegate?.section(self, didRemoveElementAt: $0)
        }
        updateDelegate?.sectionDidUpdate(self)
    }

    @discardableResult
    public func remove(at position: Index) -> Element {
        updateDelegate?.sectionWillUpdate(self)
        let element = elements.remove(at: position)
        updateDelegate?.section(self, didRemoveElementAt: position)
        updateDelegate?.sectionDidUpdate(self)
        return element
    }

    public func removeAll() {
        updateDelegate?.sectionWillUpdate(self)
        let indexes = IndexSet(integersIn: indices)
        indexes.forEach { updateDelegate?.section(self, didRemoveElementAt: $0) }
        elements.removeAll()
        updateDelegate?.sectionDidUpdate(self)
    }

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
        updateDelegate?.sectionDidReload(self)
    }

}

extension ArraySection: Equatable where Element: Equatable {
    public static func == (lhs: ArraySection<Element>, rhs: ArraySection<Element>) -> Bool {
        return lhs.elements == rhs.elements
    }
}

extension ArraySection: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        elements.hash(into: &hasher)
    }
}

extension ArraySection: RangeReplaceableCollection {

    public func replaceSubrange<C: Swift.Collection, R: RangeExpression>(_ subrange: R, with newElements: C) where C.Element == Element, R.Bound == Index {
        elements.replaceSubrange(subrange, with: newElements)
        updateDelegate?.sectionDidReload(self)
    }

}

extension ArraySection: CustomStringConvertible {
    public var description: String {
        return String(describing: elements)
    }
}
