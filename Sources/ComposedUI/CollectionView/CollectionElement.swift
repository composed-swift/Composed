import UIKit
import Composed

/// A `UICollectionView` supports different elementKind's for supplementary view, this provides a solution
/// A collection view can provide headers and footers via custom elementKind's or it using built-in definitions, this provides a solution for specifying which option to use
public enum CollectionElementKind {
    /// Either `elementKindSectionHeader` or `elementKindSectionFooter` will be used
    case automatic
    /// The custom `kind` value will be used
    case custom(kind: String)

    internal var rawValue: String {
        switch self {
        case .automatic: return "automatic"
        case let .custom(kind): return kind
        }
    }
}

/// Defines an element used by a `CollectionSection` to provide configurations for a cell, header and/or footer.
public protocol CollectionElement {

    /// The method to use for registering and dequeueing a view for this element
    var dequeueMethod: AnyDequeueMethod { get }

    /// A closure that will be called whenever the elements view needs to be configured
    var configure: (UICollectionReusableView, Int, Section) -> Void { get }

    /// The reuseIdentifier to use for this element
    var reuseIdentifier: String { get }

    /// A closure that will be called before the elements view is appeared
    var willAppear: ((UICollectionReusableView, Int, Section) -> Void)? { get }

    /// A closure that will be called after the elements view has disappeared
    var didDisappear: ((UICollectionReusableView, Int, Section) -> Void)? { get }

}

extension CollectionElement {
    public var willAppear: ((UICollectionReusableView, Int, Section) -> Void)? { nil }
    public var didDisappear: ((UICollectionReusableView, Int, Section) -> Void)? { nil }
}

/// Defines a cell element to be used by a `CollectionSection` to provide a configuration for a cell
open class CollectionCellElement: CollectionElement {

    public let dequeueMethod: AnyDequeueMethod
    public let configure: (UICollectionReusableView, Int, Section) -> Void
    public let reuseIdentifier: String

    /// The closure that will be called before the elements view appears
    public let willAppear: ((UICollectionReusableView, Int, Section) -> Void)?
    /// The closure that will be called after the elements view disappears
    public let didDisappear: ((UICollectionReusableView, Int, Section) -> Void)?

    /// Makes a new element for representing a cell
    /// - Parameters:
    ///   - section: The section where this element's cell will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a cell for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    public init<Section, View: UICollectionViewCell>(section: Section,
                         dequeueMethod: DequeueMethod<View>,
                         reuseIdentifier: String? = nil,
                         configure: @escaping (View, Int, Section) -> Void)
    where Section: Composed.Section {
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod.erasedAsAnyDequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, section in
            configure(view as! View, index, section as! Section)
        }

        willAppear = nil
        didDisappear = nil
    }

    /// Makes a new element for representing a cell
    /// - Parameters:
    ///   - section: The section where this element's cell will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a cell for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    public init<Section, View: UICollectionViewCell>(section: Section,
                                                     dequeueMethod: AnyDequeueMethod,
                                                     reuseIdentifier: String? = nil,
                                                     configure: @escaping (View, Int, Section) -> Void)
    where Section: Composed.Section {
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, section in
            configure(view as! View, index, section as! Section)
        }

        willAppear = nil
        didDisappear = nil
    }

    /// Makes a new element for representing a cell
    /// - Parameters:
    ///   - section: The section where this element's cell will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a cell for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    ///   - willAppear: A closure that will be called before the elements view appears
    ///   - didDisappear: A closure that will be called after the elements view disappears
    public init<Section, View: UICollectionViewCell>(section: Section,
                         dequeueMethod: DequeueMethod<View>,
                         reuseIdentifier: String? = nil,
                         configure: @escaping (View, Int, Section) -> Void,
                         willAppear: ((View, Int, Section) -> Void)? = nil,
                         didDisappear: ((View, Int, Section) -> Void)? = nil)
    where Section: Composed.Section {
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod.erasedAsAnyDequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, section in
            configure(view as! View, index, section as! Section)
        }

        self.willAppear = { view, index, section in
            willAppear?(view as! View, index, section as! Section)
        }

        self.didDisappear = { view, index, section in
            didDisappear?(view as! View, index, section as! Section)
        }
    }

    /// Makes a new element for representing a cell
    /// - Parameters:
    ///   - section: The section where this element's cell will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a cell for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    ///   - willAppear: A closure that will be called before the elements view appears
    ///   - didDisappear: A closure that will be called after the elements view disappears
    public init<Section, View: UICollectionViewCell>(section: Section,
                                                     dequeueMethod: AnyDequeueMethod,
                                                     reuseIdentifier: String? = nil,
                                                     configure: @escaping (View, Int, Section) -> Void,
                                                     willAppear: ((View, Int, Section) -> Void)? = nil,
                                                     didDisappear: ((View, Int, Section) -> Void)? = nil)
    where Section: Composed.Section {
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, section in
            configure(view as! View, index, section as! Section)
        }

        self.willAppear = { view, index, section in
            willAppear?(view as! View, index, section as! Section)
        }

        self.didDisappear = { view, index, section in
            didDisappear?(view as! View, index, section as! Section)
        }
    }

    /// Makes a new element for representing a cell
    /// - Parameters:
    ///   - dequeueMethod: The method to use for registering and dequeueing a cell for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    ///   - willAppear: A closure that will be called before the elements view appears
    ///   - didDisappear: A closure that will be called after the elements view disappears
    public init<View: UICollectionViewCell>(
        dequeueMethod: AnyDequeueMethod,
        reuseIdentifier: String? = nil,
        configure: @escaping (View, Int) -> Void,
        willAppear: ((View, Int) -> Void)? = nil,
        didDisappear: ((View, Int) -> Void)? = nil) {
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, _ in
            configure(view as! View, index)
        }

        self.willAppear = { view, index, _ in
            willAppear?(view as! View, index)
        }

        // TODO: Fix a memory leak that occurs here? It appears to only be caused when `FlattenedCollectionCellElement` is used.
        self.didDisappear = { view, index, _ in
            didDisappear?(view as! View, index)
        }
    }

}

/// Defines a supplementary element to be used by a `CollectionSection` to provide a configuration for a supplementary view
public final class CollectionSupplementaryElement: CollectionElement {

    public let dequeueMethod: AnyDequeueMethod
    public let configure: (UICollectionReusableView, Int, Section) -> Void
    public let reuseIdentifier: String

    /// The `elementKind` this element represents
    public let kind: CollectionElementKind

    /// A closure that will be called before the elements view is appeared
    public let willAppear: ((UICollectionReusableView, Int, Section) -> Void)?
    /// A closure that will be called after the elements view has disappeared
    public let didDisappear: ((UICollectionReusableView, Int, Section) -> Void)?

    /// Makes a new element for representing a supplementary view
    /// - Parameters:
    ///   - section: The section where this element's view will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a view for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - kind: The `elementKind` this element represents
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    public init<Section, View: UICollectionReusableView>(
        section: Section,
        dequeueMethod: DequeueMethod<View>,
        reuseIdentifier: String? = nil,
        kind: CollectionElementKind = .automatic,
        configure: @escaping (_ view: View, _ sectionIndex: Int, _ section: Section) -> Void
    ) where Section: Composed.Section {
        self.kind = kind
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod.erasedAsAnyDequeueMethod

        self.configure = { view, index, section in
            // swiftlint:disable force_cast
            configure(view as! View, index, section as! Section)
        }

        willAppear = nil
        didDisappear = nil
    }

    /// Makes a new element for representing a supplementary view
    /// - Parameters:
    ///   - section: The section where this element's view will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a view for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - kind: The `elementKind` this element represents
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    public init<Section, View: UICollectionReusableView>(
        section: Section,
        dequeueMethod: AnyDequeueMethod,
        reuseIdentifier: String? = nil,
        kind: CollectionElementKind = .automatic,
        configure: @escaping (_ view: View, _ sectionIndex: Int, _ section: Section) -> Void
    ) where Section: Composed.Section {
        self.kind = kind
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod

        self.configure = { view, index, section in
            // swiftlint:disable force_cast
            configure(view as! View, index, section as! Section)
        }

        willAppear = nil
        didDisappear = nil
    }

    /// Makes a new element for representing a supplementary view
    /// - Parameters:
    ///   - section: The section where this element's view will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a view for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - kind: The `elementKind` this element represents
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    ///   - willAppear: A closure that will be called before the elements view appears
    ///   - didDisappear: A closure that will be called after the elements view disappears
    public init<Section, View: UICollectionReusableView>(
        section: Section,
                         dequeueMethod: DequeueMethod<View>,
                         reuseIdentifier: String? = nil,
                         kind: CollectionElementKind = .automatic,
                         configure: @escaping (View, Int, Section) -> Void,
                         willAppear: ((View, Int, Section) -> Void)? = nil,
                         didDisappear: ((View, Int, Section) -> Void)? = nil
    ) where Section: Composed.Section {
        self.kind = kind
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod.erasedAsAnyDequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, section in
            configure(view as! View, index, section as! Section)
        }

        self.willAppear = { view, index, section in
            willAppear?(view as! View, index, section as! Section)
        }

        self.didDisappear = { view, index, section in
            didDisappear?(view as! View, index, section as! Section)
        }
    }

    /// Makes a new element for representing a supplementary view
    /// - Parameters:
    ///   - section: The section where this element's view will be shown in
    ///   - dequeueMethod: The method to use for registering and dequeueing a view for this element
    ///   - reuseIdentifier: The reuseIdentifier to use for this element
    ///   - kind: The `elementKind` this element represents
    ///   - configure: A closure that will be called whenever the elements view needs to be configured
    ///   - willAppear: A closure that will be called before the elements view appears
    ///   - didDisappear: A closure that will be called after the elements view disappears
    public init<View: UICollectionReusableView>(
        dequeueMethod: DequeueMethod<View>,
        reuseIdentifier: String? = nil,
        kind: CollectionElementKind = .automatic,
        configure: @escaping (View, Int) -> Void,
        willAppear: ((View, Int) -> Void)? = nil,
        didDisappear: ((View, Int) -> Void)? = nil
    ) {
        self.kind = kind
        self.reuseIdentifier = reuseIdentifier ?? View.reuseIdentifier
        self.dequeueMethod = dequeueMethod.erasedAsAnyDequeueMethod

        // swiftlint:disable force_cast

        self.configure = { view, index, _ in
            configure(view as! View, index)
        }

        self.willAppear = { view, index, _ in
            willAppear?(view as! View, index)
        }

        self.didDisappear = { view, index, _ in
            didDisappear?(view as! View, index)
        }
    }

}
