import Foundation

/**
 Represents a section that manages its elements via an `Array`. This type of section is useful for representing in-memory data.

 This type conforms to various standard library protocols to provide a more familiar API.

 `ArraySection` conforms to the following protocols from the standard library:

 Sequence
 MutableCollection
 RandomAccessCollection
 BidirectionalCollection
 RangeReplaceableCollection

 Example usage:

 let section = ArraySection<Int>()
 section.append(contentsOf: [1, 2, 3])
 section.numberOfElements // returns 3

 */
open class ArraySection<Element>: Section, ExpressibleByArrayLiteral {

    public weak var updateDelegate: SectionUpdateDelegate?

    /// Represents the elements this section contains
    public private(set) var elements: [Element]

    public init(elements: [Element]) {
        self.elements = elements
    }

    public required init() {
        elements = []
    }

    /// Makes an `ArraySection` containing the specified elements
    /// - Parameter elements: The elements to append
    public required init(arrayLiteral elements: Element...) {
        self.elements = elements
    }

    /// Returns the element at the specified index
    /// - Parameter index: The position of the element to access. `index` must be greater than or equal to `startIndex` and less than `endIndex`.
    /// - Returns: If the index is valid, the element. Otherwise
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
            performBatchUpdates { _ in
                elements[position] = newValue
                updateDelegate?.section(self, didUpdateElementAt: position)
            }
        }
    }

    public func append(_ newElement: Element) {
        performBatchUpdates { _ in
            elements.append(newElement)
            updateDelegate?.section(self, didInsertElementAt: elements.count - 1)
        }
    }

    public func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        performBatchUpdates { _ in
            let oldCount = elements.count
            elements.append(contentsOf: newElements)
            let newCount = elements.count
            (oldCount..<newCount).forEach {
                updateDelegate?.section(self, didInsertElementAt: $0)
            }
        }
    }

    public func insert(_ newElement: Element, at i: Index) {
        performBatchUpdates { _ in
            elements.insert(newElement, at: i)
            updateDelegate?.section(self, didInsertElementAt: i)
        }
    }

    public func insert<C>(contentsOf newElements: C, at i: Index) where C: Collection, Element == C.Element {
        performBatchUpdates { _ in
            let oldCount = elements.count
            elements.insert(contentsOf: newElements, at: i)
            let newCount = elements.count
            (oldCount..<newCount).forEach {
                updateDelegate?.section(self, didInsertElementAt: $0)
            }
        }
    }

    /// Removes the last element
    /// - Returns: The element that was removed
    @discardableResult
    public func removeLast() -> Element {
        var element: Element!
        performBatchUpdates { _ in
            element = elements.removeLast()
            updateDelegate?.section(self, didRemoveElementAt: elements.count)
        }
        return element
    }

    /// Removes the last `k` (number of) elements
    /// - Parameter k: The number of elements to remove from the end
    public func removeLast(_ k: Int) {
        performBatchUpdates { _ in
            let oldCount = elements.count
            elements.removeLast(k)
            let newCount = elements.count
            (newCount..<oldCount).sorted(by: >).forEach {
                updateDelegate?.section(self, didRemoveElementAt: $0)
            }
        }
    }

    @discardableResult
    public func remove(at position: Index) -> Element {
        var element: Element!
        performBatchUpdates { _ in
            element = elements.remove(at: position)
            updateDelegate?.section(self, didRemoveElementAt: position)
        }
        return element
    }

    public func commitInteractiveMove(from source: Int, to target: Index) {
        // This is called at the end of an interactive move,
        // as such we don't want to update the delegate since it would a duplicate move to occur.
        // We just need to update our model to match so that when the cell is reused,
        // it will have the correct element backing it.
        elements.insert(elements.remove(at: source), at: target)
    }

    /// Removes all elements from this section
    public func removeAll() {
        performBatchUpdates { _ in
            let indexes = IndexSet(integersIn: indices)
            indexes.sorted(by: >).forEach { updateDelegate?.section(self, didRemoveElementAt: $0) }
            elements.removeAll()
        }
    }

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
        updateDelegate?.invalidateAll(self)
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
        performBatchUpdates { updateDelegate in
            elements.replaceSubrange(subrange, with: newElements)
            for index in subrange.relative(to: elements) {
                updateDelegate?.section(self, didUpdateElementAt: index)
            }
        }
    }
}

extension ArraySection: CustomStringConvertible {
    public var description: String {
        return String(describing: elements)
    }
}
