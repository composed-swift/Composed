import Foundation

public protocol EditingHandler: Section {
    func allowsEditing(at index: Int) -> Bool
}

public extension EditingHandler {
    func allowsEditing(at index: Int) -> Bool { return false }
}

