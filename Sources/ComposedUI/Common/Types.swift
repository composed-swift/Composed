import UIKit

/// The method to use when dequeuing a view from a UICollectionView
///
/// - nib: Load from a XIB
/// - `class`: Load from a class
public enum DequeueMethod<View: UIView> {
    /// Load from a nib
    case fromNib(View.Type)
    // Load from a class
    case fromClass(View.Type)
    /// Load from a storyboard
    case fromStoryboard(View.Type)

    internal var erasedAsAnyDequeueMethod: AnyDequeueMethod {
        switch self {
        case .fromNib(let viewType):
            return AnyDequeueMethod(method: .fromNib(viewType))
        case .fromClass(let viewType):
            return AnyDequeueMethod(method: .fromClass(viewType))
        case .fromStoryboard(let viewType):
            return AnyDequeueMethod(method: .fromStoryboard(viewType))
        }
    }
}

public struct AnyDequeueMethod {
    internal enum Method {
        /// Load from a nib
        case fromNib(UIView.Type)
        // Load from a class
        case fromClass(UIView.Type)
        /// Load from a storyboard
        case fromStoryboard(UIView.Type)
    }

    internal let method: Method
}
