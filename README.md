# Composed

Composed is a protocol oriented framework for composing data from various sources in our app. It provides various concrete implementations for common use cases. 

The library bases everything on just 2 primitives, `Section` and `SectionProvider`.

The primary benefits of using Composed include:

- The library makes heavy use of protocol-oriented design allowing your types to opt-in to behaviour rather than inherit it by default.
- From an API perspective you generally only care about a single section at a time, and so it's irrelevant to you how it's being composed.

To better understand how this is achieved, lets take a look behind the scenes.

## Section

A section represents exactly what it says, a single section. The best thing about that is that we have no need for `IndexPath`'s within a section. Just indexes!

## SectionProvider

A section provider is a container type that contains either sections or other providers. Allowing infinite nesting and therefore infinite possibilities.

## Mappings

Mappings provide the glue between your 'tree' structure and the resulting `flattened` structure. Lets take a look at an example.

```swift

// we can define our structure as such:
- Provider
    - Section 1
    - Provider
        - Section 2
        - Section 3
    - Section 4

// mappings will then convert this to:
- Section 1
- Section 2
- Section 3
- Section 4
```

Furthermore, mappings take care of the conversion from local to global indexes and more importantly `IndexPath`'s which allows for even more interesting use cases.

> To find out more, checkout [ComposedUI](http://github.com/composed-swift/ComposedUI) which provides user interface implementations that work with `UICollectionView` and `UITableView`, allowing you to power an entire screen from simple reusable `Section`s.

## Handlers

Since Composed is protocol based, it makes heavy use of protocols to extend its features and behaviour. There are various protocols included but lets highlight a fairly common one, selection.

```swift
protocol SelectionHandler { }
```

By simply conforming out section to this protocol, we gain selection superpowers when dealing with user interface components. For example, `UICollectionView` makes use of this protocol to validate selection events and also notify you of selections. You can even call included methods on that protocol to perform selections on the view itself. Lets look at an example.

```swift
extension PeopleSection: SelectionHandler {

    // this is called when our element is selected
    func didSelect(at index: Int) {
        // ... handle the selection
        // then deselect if we prefer
        deselect(at: index)
    }

}
```

As you can see this protocol based approach allows us to opt-in to just the API we are interested in. Without this extension, our section knows nothing about selection at all!
