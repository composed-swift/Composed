# Composed

Composed is a protocol oriented framework for composing data from various sources in our app. It provides various concrete implementations for common use cases.

> If you prefer to look at code, there's a demo project here: [ComposedDemo](http://github.com/composed-swift/composed-demo

The library bases everything on just 2 primitives, `Section` and `SectionProvider`.

The primary benefits of using Composed include:

- The library makes heavy use of protocol-oriented design allowing your types to opt-in to behaviour rather than inherit it by default.
- From an API perspective you generally only care about a single section at a time, and so it's irrelevant to you how it's being composed.

1. [Getting Started](#Getting-Started)
2. [Behind the Scenes](#Behind-the-Scenes)
3. [User Interfaces](http://github.com/composed-swift/composedui)

## Getting Started

Composed includes 3 pre-defined sections as well as 2 providers that should satisfy a large majority of applications.

### Sections

**ArraySection**
Represents a section that manages its elements via an `Array`. This type of section is useful for representing in-memory data.

**ManagedSection**
Represents a section that provides its elements via an `NSFetchedResultsController`. This section is useful for representing data managed by CoreData.

**SingleElementSection**
Represents a section that manages a single element. This section is useful when only have a single element to manage. Hint: Use `Optional<T>` to represent an element that may or may not exist.

### Providers

**ComposedSectionProvider**
Represents an collection of `Section`'s and `SectionProvider`'s. The provider supports infinite nesting, including other `ComposedSectionProvider`'s. All children will be active at all times, so `numberOfSections` and `numberOfElements(in:)` will return values representative of all children.

**SegmentedSectionProvider**
Represents an collection of `Section`'s and `SectionProvider`'s. The provider supports infinite nesting, including other `SegmentedSectionProvider`'s. One or zero children may be active at any time, so `numberOfSections` and `numberOfElements(in:)` will return values representative of the currenly active child only.

### Example

Lets say we wanted to represent a users contacts library. Our contacts will have 2 groups, family and friends. Using Composed, we can easily model that as such:
 
```swift
let family = ArraySection<Person>()
family.append(Person(name: "Dad"))
family.append(Person(name: "Mum"))

let friends = ArraySection<Person>()
friends.append(Person(name: "Best mate"))
```

At this point we have 2 separate sections for representing our 2 groups of contacts. Now we can use a provider to compose these 2 together:

```swift
let contacts = ComposedSectionProvider()
contacts.append(family)
contacts.append(friends)
```

That's it! Now we can query our data using the provider without either of the individual sections even being aware that they're now contained in a larger structure:

```swift
contacts.numberOfSections        // 2
contacts.numberOfElements(in: 1) // 1
```

If we want to query individual data in a section (assuming we don't already have a reference to it):

```swift
let people = contacts.sections[0] as? ArraySection<Person>
people.element(at: 1)            // Mum
```

> Note: we have to cast the section to a known type because SectionProvider's can contain _any_ type of section as well as other nested providers.

### Opt-In Behaviours

If we now subclass ArraySection, we can extend our section through protocol conformance to do something more interesting:

```swift
final class People: ArraySection<Person> { ... }

protocol SelectionHandling: Section { 
    func didSelect(at index: Int)
}

extension People: SelectionHandling {
	func didSelect(at index: Int) {
		let person = element(at: index)
		print(person.name)
	}
}
```

In order to make this work, _something_ needs to call `didSelect`, so for the purposes of this example we'll leave out some details but to give you a preview for how you can build something like this yourself:

```swift
// Assume we want to select the 2nd element in the 1st section
let section = provider.sections[0] as? SelectionHandling
section?.didSelect(at: 1)        // Mum
```

Composed is handling all of the mapping and structure, allowing us to focus entirely on behavious and extension.

## Behind the Scenes

### Section

A section represents exactly what it says, a single section. The best thing about that is that we have no need for `IndexPath`'s within a section. Just indexes!

### SectionProvider

A section provider is a container type that contains either sections or other providers. Allowing infinite nesting and therefore infinite possibilities.

### Mappings

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
