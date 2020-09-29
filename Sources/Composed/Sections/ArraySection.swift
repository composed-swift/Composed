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
    public private(set) var appliedElements: [Element]

    /// Represents the elements this section contains
    public private(set) var pendingElements: [Element]

    public required init() {
        appliedElements = []
        pendingElements = []
    }

    /// Makes an `ArraySection` containing the specified elements
    /// - Parameter elements: The elements to append
    required public init(arrayLiteral elements: Element...) {
        appliedElements = elements
        pendingElements = elements
    }

    /// Returns the element at the specified index
    /// - Parameter index: The position of the element to access. `index` must be greater than or equal to `startIndex` and less than `endIndex`.
    /// - Returns: If the index is valid, the element. Otherwise
    public func element(at index: Int) -> Element {
        return appliedElements[index]
    }

    public var numberOfElements: Int {
        return appliedElements.count
    }

}

extension ArraySection: Sequence {

    public typealias Iterator = Array<Element>.Iterator

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return appliedElements.makeIterator()
    }

}

extension ArraySection: MutableCollection, RandomAccessCollection, BidirectionalCollection {

    public typealias Index = Array<Element>.Index

    public var isEmpty: Bool { return appliedElements.isEmpty }
    public var startIndex: Index { return appliedElements.startIndex }
    public var endIndex: Index { return appliedElements.endIndex }

    public subscript(position: Index) -> Element {
        get { return appliedElements[position] }
        set(newValue) {
            guard let updateDelegate = updateDelegate else {
                appliedElements[position] = newValue
                pendingElements = appliedElements
                return
            }

            pendingElements[position] = newValue
            updateDelegate.section(self, didInsertElementAt: position) { [weak self] in
                self?.appliedElements[position] = newValue
            }
        }
    }

    // MARK:- Inserting elements

    public func append(_ newElement: Element) {
        insert(newElement, at: pendingElements.endIndex)
    }

    public func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        guard let updateDelegate = updateDelegate else {
            appliedElements.append(contentsOf: newElements)
            pendingElements = appliedElements
            return
        }

        let countBefore = pendingElements.count
        pendingElements.append(contentsOf: newElements)
        let countAfter = pendingElements.count
        let indexSet = IndexSet(countBefore ..< countAfter)
        updateDelegate.section(self, didInsertElementsAt: indexSet) { [weak self] in
            self?.appliedElements.append(contentsOf: newElements)
        }
    }

    public func insert(_ newElement: Element, at index: Index) {
        guard let updateDelegate = updateDelegate else {
            appliedElements.insert(newElement, at: index)
            pendingElements = appliedElements
            return
        }

        pendingElements.insert(newElement, at: index)
        updateDelegate.section(self, didInsertElementAt: index) { [weak self] in
            self?.appliedElements.insert(newElement, at: index)
        }
    }

    public func insert<C>(contentsOf newElements: C, at index: Index) where C: Collection, Element == C.Element {
        guard let updateDelegate = updateDelegate else {
            appliedElements.insert(contentsOf: newElements, at: index)
            pendingElements = appliedElements
            return
        }

        pendingElements.insert(contentsOf: newElements, at: index)
        let indexSet = IndexSet(index ..< (index + newElements.count))
        updateDelegate.section(self, didInsertElementsAt: indexSet) { [weak self] in
            self?.appliedElements.insert(contentsOf: newElements, at: index)
        }
    }

    // MARK:- Removing elements

    /// Removes the last element
    /// - Returns: The element that was removed
    @discardableResult
    public func removeLast() -> Element {
        guard let updateDelegate = updateDelegate else {
            let removedElement = appliedElements.removeLast()
            pendingElements = appliedElements
            return removedElement
        }

        let removedIndex = pendingElements.endIndex - 1
        let removedElement = pendingElements.removeLast()
        updateDelegate.section(self, didRemoveElementAt: removedIndex) { [weak self] in
            self?.appliedElements.removeLast()
        }
        return removedElement
    }

    /// Removes the last `k` (number of) elements
    /// - Parameter k: The number of elements to remove from the end
    public func removeLast(_ k: Int) {
        guard let updateDelegate = updateDelegate else {
            appliedElements.removeLast(1)
            pendingElements = appliedElements
            return
        }

        let removedIndexes = IndexSet((pendingElements.endIndex-k) ..< pendingElements.endIndex)
        pendingElements.removeLast(k)
        updateDelegate.section(self, didRemoveElementsAt: removedIndexes) { [weak self] in
            self?.appliedElements.removeLast(k)
        }
    }

    @discardableResult
    public func remove(at position: Index) -> Element {
        guard let updateDelegate = updateDelegate else {
            let removedElement = appliedElements.remove(at: position)
            pendingElements = appliedElements
            return removedElement
        }

        let removedElement = pendingElements.remove(at: position)
        updateDelegate.section(self, didRemoveElementAt: position) { [weak self] in
            self?.appliedElements.remove(at: position)
        }
        return removedElement
    }

    public func commitInteractiveMove(from source: Int, to target: Index) {
        // This is called at the end of an interactive move,
        // as such we don't want to update the delegate since it would a duplicate move to occur.
        // We just need to update our model to match so that when the cell is reused,
        // it will have the correct element backing it.
        appliedElements.insert(appliedElements.remove(at: source), at: target)
    }

    /// Removes all elements from this section
    public func removeAll() {
        guard let updateDelegate = updateDelegate else {
            appliedElements.removeAll()
            pendingElements = appliedElements
            return
        }

        let removedIndexes = IndexSet(integersIn: indices)
        pendingElements.removeAll()
        updateDelegate.section(self, didRemoveElementsAt: removedIndexes) { [weak self] in
            self?.appliedElements.removeAll()
        }
    }

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        guard let updateDelegate = updateDelegate else {
            try appliedElements.removeAll(where: shouldBeRemoved)
            pendingElements = appliedElements
            return
        }

        let indexesToBeRemoved = try appliedElements.reversed().enumerated().filter({ try shouldBeRemoved($0.element) }).map(\.offset)
        indexesToBeRemoved.forEach { _ = pendingElements.remove(at: $0) }
        updateDelegate.section(self, didRemoveElementsAt: IndexSet(indexesToBeRemoved)) { [weak self] in
            indexesToBeRemoved.forEach { _ = self?.appliedElements.remove(at: $0) }
        }
    }

}

extension ArraySection: Equatable where Element: Equatable {
    public static func == (lhs: ArraySection<Element>, rhs: ArraySection<Element>) -> Bool {
        return lhs.appliedElements == rhs.appliedElements
    }
}

extension ArraySection: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        appliedElements.hash(into: &hasher)
    }
}

extension ArraySection: RangeReplaceableCollection {

    public func replaceSubrange<C: Swift.Collection, R: RangeExpression>(_ subrange: R, with newElements: C) where C.Element == Element, R.Bound == Index {
        guard let updateDelegate = updateDelegate else {
            appliedElements.replaceSubrange(subrange, with: newElements)
            pendingElements = appliedElements
            return
        }

        let range = subrange.relative(to: appliedElements)
        let diffCount = newElements.count - range.count

        updateDelegate.willBeginUpdating(self)

        pendingElements.replaceSubrange(subrange, with: newElements)

        defer {
            updateDelegate.didEndUpdating(self)
        }

        if diffCount == 0 {
            updateDelegate.section(self, didUpdateElementsAt: IndexSet(range)) { [weak self] in
                self?.appliedElements.replaceSubrange(subrange, with: newElements)
            }
        } else if diffCount > 0 {
            // `diffCount` elements have been inserted
//            if previousCount > 0 {
//                (0 ..< previousCount).forEach { index in
//                    updateDelegate?.section(self, didUpdateElementAt: index)
//                }
//            }
//
//            (previousCount ..< newCount).forEach { index in
//                updateDelegate?.section(self, didInsertElementAt: index)
//            }

            fatalError("Can't reason about this without tests")
        } else {
            // `diffCount` elements have been removed
//            if newCount > 0 {
//                (0 ..< newCount).forEach { index in
//                    updateDelegate?.section(self, didUpdateElementAt: index)
//                }
//            }
//
//            (newCount ..< previousCount).forEach { index in
//                updateDelegate?.section(self, didRemoveElementAt: index)
//            }

            fatalError("Can't reason about this without tests")
        }
    }

}

extension ArraySection: CustomStringConvertible {
    public var description: String {
        return String(describing: appliedElements)
    }
}
