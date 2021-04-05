import Foundation

/**
 A collection of changes to be applied in batch.
 */
public struct Changeset {
    public struct Move: Hashable {
        public var from: IndexPath
        public var to: IndexPath

        public init(from: IndexPath, to: IndexPath) {
            self.from = from
            self.to = to
        }
    }

    public var groupsInserted: Set<Int> = []
    public var groupsRemoved: Set<Int> = []
    public var groupsUpdated: Set<Int> = []
    public var elementsRemoved: Set<IndexPath> = []
    public var elementsInserted: Set<IndexPath> = []
    public var elementsMoved: Set<Move> = []
    public var elementsUpdated: Set<IndexPath> = []
}
