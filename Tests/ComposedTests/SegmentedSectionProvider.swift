import Quick
import Nimble
import UIKit

@testable import Composed

final class SegmentedSectionProvider_Spec: QuickSpec {

    override func spec() {
        var segment: SegmentedSectionProvider!
        var child1: ComposedSectionProvider!
        var child2: ArraySection<String>!
        var mapping: SectionProviderMapping!

        describe("SegmentedSectionProvider") {
            beforeEach {
                segment = SegmentedSectionProvider()
                mapping = SectionProviderMapping(provider: segment)

                child1 = ComposedSectionProvider()
                let child1a = ArraySection<String>()
                let child1b = ArraySection<String>()
                child2 = ArraySection<String>()

                segment.append(child1)
                segment.append(child2)

                child1.append(child1a)
                child1.append(child1b)

                print(segment.children)
            }

            context("after changing the `currentIndex") {
                beforeEach {
                    segment.currentIndex = 1
                }

                it("should contain 1 section") {
                    expect(segment.numberOfSections).to(equal(1))
                }

                it("should unset the delegate of the previous child") {
                    expect(child1.updateDelegate).to(beNil())
                }

                it("should set the delegate of the current child") {
                    expect(child2.updateDelegate).toNot(beNil())
                }
            }

            context("without changing the `currentIndex`") {
                it("should contain 2 section") {
                    expect(segment.numberOfSections).to(equal(2))
                }

                it("should set the delegate") {
                    expect(child1.updateDelegate).toNot(beNil())
                }

                it("should not set the delegate of children") {
                    expect(child2.updateDelegate).to(beNil())
                }

            }
        }
    }

}
