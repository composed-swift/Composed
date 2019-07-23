import Quick
import Nimble

@testable import Composed

final class ComposedSectionProvider_Spec: QuickSpec {

    override func spec() {
        describe("ComposedSectionProvider") {
            let global = ComposedSectionProvider()

            let child1 = ComposedSectionProvider()
                let child1a = ArraySection<String>()
                let child1b = ArraySection<String>()
            let child2 = ComposedSectionProvider()
                let child2a = ComposedSectionProvider()
                    let child2b = ArraySection<String>()
                    let child2c = ArraySection<String>()
                let child2z = ComposedSectionProvider()
                let child2d = ArraySection<String>()
                let child2e = ComposedSectionProvider()
                    let child2f = ArraySection<String>()

            child1.append(child1a)
            child1.append(child1b)
            child2.append(child2a)
            child2a.append(child2b)
            child2a.append(child2c)
            child2.append(child2z)
            child2.append(child2d)
            child2e.append(child2f)
            child2.append(child2e)
            global.append(child1)
            global.append(child2)

            it("should contain 2 global sections") {
                expect(global.numberOfSections) == 6
            }

            it("cache should contain 2 providers") {
                expect(global.providers.count) == 2
            }

            it("should return the right offsets") {
                expect(global.sectionOffset(for: child1)) == 0
                expect(global.sectionOffset(for: child2)) == 2
                expect(global.sectionOffset(for: child2a)) == 2
                expect(global.sectionOffset(for: child2z)) == 4
                expect(global.sectionOffset(for: child2e)) == 5
                
                expect(child2.sectionOffset(for: child2a)) == 0
                expect(child2.sectionOffset(for: child2z)) == 2
                expect(child2.sectionOffset(for: child2e)) == 3
            }
        }
    }

}
