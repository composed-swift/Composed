<img src="composed.png" width=20%/>

`Composed` is a protocol oriented framework for composing data from multiple sources and building flexible UIs that display the data.

The primary benefits of using Composed include:

- The library makes heavy use of protocol-oriented design allowing your types to opt-in to behaviour rather than inherit it by default.
- Each section is isolated from the others, removing the need to think about how the data is composed.

> If you prefer to look at code, there's a demo project here: [ComposedDemo](http://github.com/composed-swift/composed-demo)

The package contains 3 libraries, each built on top of each other:

- Composed
- ComposedUI
- ComposedLayouts

## Composed

The `Composed` library provides the data layer. `Composed` is centered around primitives, `Section` and `SectionProvider`.

## Getting Started

Composed includes 3 pre-defined sections as well as 2 providers that should satisfy a large majority of applications.

### Sections

A `Section` is a collection of data with a simple set of requirements:

```swift
/// Represents a single section of data.
public protocol Section: AnyObject {
    /// The number of elements in this section
    var numberOfElements: Int { get }

    /// The delegate that will respond to updates
    var updateDelegate: SectionUpdateDelegate? { get set }
}
```

`Composed` provides some sections that should cover a majority of use cases.

#### `ArraySection`

Represents a section that manages a collection of same-type elements by using an `Array` backing store. This type of section is useful for representing in-memory data, e.g. data loaded from a network or read from the file system.

#### `SingleElementSection`

Represents a section that manages a single element. This section is useful when only have a single element to manage.

If the stored value is `nil` it will return `0` for `numberOfElements`, allowing for any UI elements the section provides to be hidden (more on this later).

#### `FlatSection`

A `FlatSection` behaved similarly to a `ComposedSectionProvider` but rather than providing a collections of sections it returns a single section that contains every element in the flattened collection of `Section`s and `SectionProvider`s. This has limited use for data alone but proves useful when representing the data in the UI; `FlatSection` allows for multiple sections to be displayed in a single UI section, enabling features such as headers that pin to visible bounds ("sticky headers").

#### `ManagedSection`

`ManagedSection` wraps an `NSManagedObjectContext` and responds to the `NSFetchedResultsControllerDelegate` functions by forwarding them to the `SectionUpdateDelegate`. This enables a single data hierarchy to include a mixture of sections that are backed by core data and other storage mechanisms.

### `SectionProvider`s

`SectionProvider`s are the next layer up, dealing with `Section`s directly by providing an ordered collection of sections:

```swift
/// Represents a collection of `Section`'s.
public protocol SectionProvider: AnyObject {
    /// The child sections contained in this provider
    var sections: [Section] { get }

    /// The delegate that will respond to updates
    var updateDelegate: SectionProviderUpdateDelegate? { get set }
}
```

#### `ComposedSectionProvider`

Represents an collection of `Section`'s and `SectionProvider`'s. The provider supports infinite nesting, including other `ComposedSectionProvider`'s, by providing a flattened hierarchy.

#### `SegmentedSectionProvider`

Provides the same nesting support as `ComposedSectionProvider` but allows for different segments of children to be active. This could be used to represent a series of tabs with different section providers in each tab.

### Example

Lets say we wanted to represent a users contacts library. Our contacts will have 2 groups, family and friends. Using Composed, we can easily model that as such:

```swift
let family = ArraySection<Person>()
family.append(Person(name: "Dad"))
family.append(Person(name: "Mum"))

let businesses = ArraySection<Business>()
businesses.append(Person(name: "ACME Inc."))
```

At this point we have 2 separate sections for representing our 2 groups of contacts. Now we can use a provider to compose these 2 together:

```swift
let contacts = ComposedSectionProvider()
contacts.append(family)
contacts.append(businesses)
```

That's it! Now we can query our data using the provider without either of the individual sections even being aware that they're now contained in a larger structure:

```swift
contacts.numberOfSections        // 2
contacts.numberOfElements(in: 1) // 1
```

Swapping to a `FlatSection` would flatten these sections while maintaining all the data:

```swift
let contacts = FlatSection()
contacts.append(family)
contacts.append(businesses)
contacts.numberOfElements // 3
```

## ComposedUI

The `ComposedUI` library builds on top of `Composed` by providing protocols that enable `Section`s to provide UI elements that can then be displayed by a view coordinator.

### UI Coordinators

Various coordinators are provided that enable interfacing with `UIKit` by adding extra protocol conformances to your `Section`s.

#### `CollectionCoordinator`

`CollectionCoordinator` allows for the most flexible UIs by coordinating with a `UICollectionView`.

View the [`CollectionCoordinator` README.md](./Sources/ComposedUI/CollectionView/README.md) to learn more.
