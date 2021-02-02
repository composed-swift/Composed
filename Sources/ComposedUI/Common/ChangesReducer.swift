import Foundation

/**
 A value that collects and reduces changes to allow them to allow multiple changes
 to be applied at once.

 The logic of how to reduce the changes is designed to match that of `UICollectionView`
 and `UITableView`, allowing for reuse between both.

 `ChangesReducer` uses the generalised terms "group" and "element", which can be mapped directly
 to "section" and "row" for `UITableView`s and "section" and "item" for `UICollectionView`.

 Final updates are applied in the order:

 | Update           | Order       | Indexes  |
 |------------------|-------------|----------|
 | Element Removals | High to low | Original |
 | Element Reloads  | N/A         | Original |
 | Group removals   | High to low | Original |

 https://developer.apple.com/videos/play/wwdc2018/225/ is useful. Page 62 of the slides helps confirm the above table.

 - Element removals
   - Using original index paths
 - Group removals
   - Using original index paths
 - Element moves
   - Decomposed in to delete and insert
   - Delete post-element removals, but pre-group removals?

 To confirm:
 - Group inserts
   - Using index paths after removals
 - Element inserts
   - Using index paths after removals
 - Group reloads
   - Using index paths after removals and inserts
 - Element reloads
   - Using index paths after removals and inserts
 */
internal struct ChangesReducer {
    internal var hasActiveUpdates: Bool {
        return activeUpdates > 0
    }

    private var activeUpdates = 0

    private var changeset: Changeset = Changeset()

    /// Clears existing updates, keeping active updates count.
    internal mutating func clearUpdates() {
        changeset = Changeset()
    }

    /// Begin performing updates. This must be called prior to making updates.
    ///
    /// It is possible to call this function multiple times to build up a batch of changes.
    ///
    /// All calls to this must be balanced with a call to `endUpdating`.
    internal mutating func beginUpdating() {
        activeUpdates += 1
    }

    /// End the current collection of updates.
    ///
    /// - Returns: The completed changeset, if this ends the last update in the batch.
    internal mutating func endUpdating() -> Changeset? {
        activeUpdates -= 1

        guard activeUpdates == 0 else {
            assert(activeUpdates > 0, "`endUpdating` calls must be balanced with `beginUpdating`")
            return nil
        }

        let changeset = self.changeset
        self.changeset = Changeset()
        return changeset
    }

    internal mutating func insertGroups(_ groups: IndexSet) {
        groups.forEach { insertedGroup in
            changeset.groupsInserted = Set(changeset.groupsInserted.map { existingInsertedGroup in
                if existingInsertedGroup >= insertedGroup {
                    return existingInsertedGroup + 1
                }

                return existingInsertedGroup
            })

            if changeset.groupsRemoved.contains(insertedGroup) {
                changeset.groupsInserted.insert(insertedGroup)
            } else {
                changeset.groupsInserted.insert(insertedGroup)
            }

            changeset.elementsInserted = Set(changeset.elementsInserted.map { insertedIndexPath in
                var insertedIndexPath = insertedIndexPath

                if insertedIndexPath.section >= insertedGroup {
                    insertedIndexPath.section += 1
                }

                return insertedIndexPath
            })

            changeset.elementsMoved = Set(changeset.elementsMoved.map { move in
                var move = move

                if move.from.section > insertedGroup {
                    move.from.section += 1
                }

                if move.to.section > insertedGroup {
                    move.to.section += 1
                }

                return move
            })
        }
    }

    internal mutating func removeGroups(_ groups: [Int]) {
        removeGroups(IndexSet(groups))
    }

    internal mutating func removeGroups(_ groups: IndexSet) {
        print(#function, groups)
        groups.sorted(by: >).forEach { removedGroup in
            print("Removing", removedGroup)
            print("groupsInserted", changeset.groupsInserted)

            /**

             */
//            changeset.groupsRemoved = Set(changeset.groupsRemoved
//                .sorted(by: >)
//                .map { existingRemovedGroup in
//                    existingRemovedGroup
//                }
//                .reduce(into: (previous: Int?.none, groupsRemoved: [Int]()), { (result, groupsRemoved) in
//                    if groupsRemoved == removedGroup {
//                        result.groupsRemoved.append(groupsRemoved)
//                        result.groupsRemoved.append(groupsRemoved + 1)
//                        result.previous = groupsRemoved + 1
//                    } else if let previous = result.previous, groupsRemoved == previous {
//                        // TODO: Test this
//                        result.groupsRemoved.append(groupsRemoved + 1)
//                        result.previous = groupsRemoved + 1
//                    } else {
//                        result.groupsRemoved.append(groupsRemoved)
//                        result.previous = groupsRemoved
//                    }
//                })
//                .groupsRemoved
//            )

            var removedGroup = removedGroup

            if changeset.groupsInserted.remove(removedGroup) != nil {
                // TODO: Offset future indexes?
                removedGroup = transformSection(removedGroup)
            } else {
                removedGroup = transformSection(removedGroup)
                changeset.groupsRemoved.insert(removedGroup)
            }


//            if !changeset.groupsRemoved.contains(removedGroup) {

//            }

            changeset.groupsInserted = Set(changeset.groupsInserted.map { insertedGroup in
                if insertedGroup > removedGroup {
                    return insertedGroup - 1
                }

                return insertedGroup
            })

//            changeset.elementsUpdated = Set(changeset.elementsUpdated.compactMap { updatedIndexPath in
//                guard updatedIndexPath.section != removedGroup else { return nil }
//
//                var updatedIndexPath = updatedIndexPath
//
//                if updatedIndexPath.section > removedGroup {
//                    updatedIndexPath.section -= 1
//                }
//
//                return updatedIndexPath
//            })

            changeset.elementsInserted = Set(changeset.elementsInserted.compactMap { insertedIndexPath in
                guard insertedIndexPath.section != removedGroup else { return nil }

                var batchedRowInsert = insertedIndexPath

                if batchedRowInsert.section > removedGroup {
                    batchedRowInsert.section -= 1
                }

                return batchedRowInsert
            })

            changeset.elementsMoved = Set(changeset.elementsMoved.compactMap { move in
                guard move.to.section != removedGroup else { return nil }

                var move = move

                if move.from.section > removedGroup {
                    move.from.section -= 1
                }

                if move.to.section > removedGroup {
                    move.to.section -= 1
                }

                return move
            })
        }
    }

    internal mutating func insertElements(at indexPaths: [IndexPath]) {
        indexPaths.forEach { insertedIndexPath in
            changeset.elementsInserted.insert(insertedIndexPath)
        }
    }

    internal mutating func removeElements(at indexPaths: [IndexPath]) {
        /**
         Element removals are handled before all other updates.
         */
        indexPaths.sorted(by: { $0.item > $1.item }).forEach { removedIndexPath in
            var removedIndexPath = transformIndexPath(removedIndexPath, toContext: .original)

            if !changeset.groupsInserted.contains(removedIndexPath.section) {
                let itemInsertsInSection = changeset
                    .elementsInserted
                    .filter { $0.section == removedIndexPath.section }
                    .map(\.item)

                if changeset.elementsRemoved.contains(removedIndexPath), changeset.elementsInserted.remove(removedIndexPath) != nil {
                    return
                }

                changeset.elementsInserted = Set(changeset.elementsInserted.map { existingInsertedIndexPath in
                    guard existingInsertedIndexPath.section == removedIndexPath.section else {
                        // Different section; don't modify
                        return existingInsertedIndexPath
                    }

                    guard !changeset.elementsRemoved.contains(existingInsertedIndexPath) else {
                        // This insert is really a reload (delete and insert)
                        return existingInsertedIndexPath
                    }

                    var existingInsertedIndexPath = existingInsertedIndexPath

                    if existingInsertedIndexPath.item > removedIndexPath.item {
                        existingInsertedIndexPath.item -= 1
                    } else if existingInsertedIndexPath.item == removedIndexPath.item && !changeset.elementsRemoved.contains(existingInsertedIndexPath) {
                        existingInsertedIndexPath.item -= 1
                    }

                    return existingInsertedIndexPath
                })

                let itemRemovalsInSection = changeset
                    .elementsRemoved
                    .filter { $0.section == removedIndexPath.section }
                    .map(\.item)

                let availableSpaces = (0..<Int.max)
                    .lazy
                    .filter { !itemRemovalsInSection.contains($0) || itemInsertsInSection.contains($0) }

                let availableSpaceIndex = availableSpaces.index(availableSpaces.startIndex, offsetBy: removedIndexPath.item)

                removedIndexPath.item = availableSpaces[availableSpaceIndex]

                changeset.elementsRemoved.insert(removedIndexPath)
            }
        }
    }

    internal mutating func updateElements(at indexPaths: [IndexPath]) {
        indexPaths.sorted(by: { $0.item > $1.item }).forEach { updatedElement in
            let updatedElement = transformIndexPath(updatedElement, toContext: .original)

            if !changeset.groupsInserted.contains(updatedElement.section) {
                changeset.elementsUpdated.insert(updatedElement)
            }
        }
    }

    internal mutating func moveElements(_ moves: [Changeset.Move]) {
        changeset.elementsMoved.formUnion(moves)
    }

    internal mutating func moveElements(_ moves: [(from: IndexPath, to: IndexPath)]) {
        moveElements(moves.map { Changeset.Move(from: $0.from, to: $0.to) })
    }

    private enum IndexPathContext {
        /// Start of updates.
        case original

        /// After deletes and reloads
        case afterUpdates
    }

    private func transformIndexPath(_ indexPath: IndexPath, toContext context: IndexPathContext) -> IndexPath {
        var indexPath = indexPath

        switch context {
        case .original:
            indexPath.section = transformSection(indexPath.section)
        case .afterUpdates:
            break
        }

        return indexPath
    }

    private func transformSection(_ section: Int) -> Int {
        let groupsRemoved = changeset.groupsRemoved
        let groupsInserted = changeset.groupsInserted
        let availableSpaces = (0..<Int.max)
            .lazy
            .filter { !groupsRemoved.contains($0) || groupsInserted.contains($0) }
        let availableSpaceIndex = availableSpaces.index(availableSpaces.startIndex, offsetBy: section)

        return availableSpaces[availableSpaceIndex]
    }
}
