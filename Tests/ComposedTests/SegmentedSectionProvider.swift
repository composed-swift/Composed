import Quick
import Nimble
import UIKit

@testable import Composed

final class SegmentedSectionProvider_Spec: QuickSpec {

    override func spec() {
        describe("SegmentedSectionProvider") {
            var global: SegmentedSectionProvider!
            var mapping: SectionProviderMapping!
            var child1: ComposedSectionProvider!
            var child2: ArraySection<String>!

            beforeEach {
                global = SegmentedSectionProvider()
                mapping = SectionProviderMapping(provider: global)

                child1 = ComposedSectionProvider()
                let child1a = ArraySection<String>()
                let child1b = ArraySection<String>()
                child2 = ArraySection<String>()

                global.append(child1)
                global.append(child2)

                child1.append(child1a)
                child1.append(child1b)
            }

            context("after changing the `currentIndex") {
                beforeEach {
                    global.currentIndex = 1
                }

                it("should unset the delegate of the previous child") {
                    expect(child1.updateDelegate).to(beNil())
                }

                it("should set the delegate of the current child") {
                    expect(child2.updateDelegate).toNot(beNil())
                }
            }

            context("without changing the `currentIndex`") {
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
