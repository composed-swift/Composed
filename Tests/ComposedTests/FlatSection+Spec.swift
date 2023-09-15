import Quick
import Nimble
import Foundation

@testable import Composed

final class FlatSection_Spec: QuickSpec {

    override func spec() {
        describe("FlatSection") {
            var global: FlatSection!
            var child1: ComposedSectionProvider!
                var child1a: ArraySection<String>!
                var child1b: ArraySection<String>!
            var child2: ComposedSectionProvider!
                var child2a: ComposedSectionProvider!
                    var child2b: ArraySection<String>!
                    var child2c: ArraySection<String>!
                    var child2d: ArraySection<String>!
                var child2e: ComposedSectionProvider!
                var child2f: ArraySection<String>!
                var child2g: ComposedSectionProvider!
                    var child2h: ArraySection<String>!
            var child3: ArraySection<String>!
            var child4: ArraySection<String>!
            var child5: ComposedSectionProvider!

            beforeEach {
                global = FlatSection()

                child1 = ComposedSectionProvider()
                    child1a = ArraySection<String>(["child1a index 0", "child1a index 1"])
                    child1b = ArraySection<String>(["child1b index 0", "child1b index 1", "child1b index 2"])
                child2 = ComposedSectionProvider()
                    child2a = ComposedSectionProvider()
                        child2b = ArraySection<String>(["child2b index 0"])
                        child2c = ArraySection<String>()
                        child2d = ArraySection<String>(["child2d index 0", "child2d index 1", "child2d index 2"])
                    child2e = ComposedSectionProvider()
                    child2f = ArraySection<String>(["child2f index 0", "child2f index 1", "child2f index 2"])
                    child2g = ComposedSectionProvider()
                        child2h = ArraySection<String>(["child2h index 0", "child2h index 1", "child2h index 2"])
                child3 = ArraySection<String>(["child3 index 0", "child3 index 1", "child3 index 2"])
                child4 = ArraySection<String>(["child4 index 0", "child4 index 1"])
                child5 = ComposedSectionProvider()

                child1.append(child1a)
                child1.insert(child1b, after: child1a)

                child2.append(child2a)
                child2a.append(child2c)
                child2a.insert(child2b, before: child2c)
                child2a.insert(child2d, after: child2c)

                child2.insert(child2e, after: child2a)
                child2.append(child2f)
                child2g.append(child2h)
                child2.append(child2g)
                global.append(child1)
                global.append(child2)
                global.append(child3)
                global.append(child4)
                global.append(child5)
            }

            it("should contain 20 elements") {
                expect(global.numberOfElements) == 20
            }

            it("should return the correct first element indexes") {
                expect(global.indexForFirstElement(of: child1)) == 0
                expect(global.indexForFirstElement(of: child1a)) == 0
                expect(global.indexForFirstElement(of: child1b)) == 2
                expect(global.indexForFirstElement(of: child2)) == 5
                expect(global.indexForFirstElement(of: child2a)) == 5
                expect(global.indexForFirstElement(of: child2b)) == 5
                expect(global.indexForFirstElement(of: child2c)) == 6
                expect(global.indexForFirstElement(of: child2d)) == 6
                expect(global.indexForFirstElement(of: child2e)) == 9
                expect(global.indexForFirstElement(of: child2f)) == 9
                expect(global.indexForFirstElement(of: child2g)) == 12
                expect(global.indexForFirstElement(of: child2h)) == 12
                expect(global.indexForFirstElement(of: child3)) == 15
                expect(global.indexForFirstElement(of: child4)) == 18
                expect(global.indexForFirstElement(of: child5)) == 20
            }

            it("should return the correct section for element index") {
                expect(global.sectionForElementIndex(0)?.section) === child1a
                expect(global.sectionForElementIndex(1)?.section) === child1a
                expect(global.sectionForElementIndex(2)?.section) === child1b
                expect(global.sectionForElementIndex(3)?.section) === child1b
                expect(global.sectionForElementIndex(4)?.section) === child1b
                expect(global.sectionForElementIndex(5)?.section) === child2b
                expect(global.sectionForElementIndex(6)?.section) === child2d
                expect(global.sectionForElementIndex(7)?.section) === child2d
                expect(global.sectionForElementIndex(8)?.section) === child2d
                expect(global.sectionForElementIndex(9)?.section) === child2f
                expect(global.sectionForElementIndex(10)?.section) === child2f
                expect(global.sectionForElementIndex(11)?.section) === child2f
                expect(global.sectionForElementIndex(12)?.section) === child2h
                expect(global.sectionForElementIndex(13)?.section) === child2h
                expect(global.sectionForElementIndex(14)?.section) === child2h
                expect(global.sectionForElementIndex(15)?.section) === child3
                expect(global.sectionForElementIndex(16)?.section) === child3
                expect(global.sectionForElementIndex(17)?.section) === child3
                expect(global.sectionForElementIndex(18)?.section) === child4
                expect(global.sectionForElementIndex(19)?.section) === child4
            }

            it("should return the correct child indexes") {
                expect(global.childIndex(of: child1)) == 0
                expect(global.childIndex(of: child1a)).to(beNil())
                expect(global.childIndex(of: child1b)).to(beNil())
                expect(global.childIndex(of: child2)) == 1
                expect(global.childIndex(of: child2a)).to(beNil())
                expect(global.childIndex(of: child2b)).to(beNil())
                expect(global.childIndex(of: child2c)).to(beNil())
                expect(global.childIndex(of: child2d)).to(beNil())
                expect(global.childIndex(of: child2e)).to(beNil())
                expect(global.childIndex(of: child2f)).to(beNil())
                expect(global.childIndex(of: child2g)).to(beNil())
                expect(global.childIndex(of: child2h)).to(beNil())
                expect(global.childIndex(of: child3)) == 2
                expect(global.childIndex(of: child4)) == 3
                expect(global.childIndex(of: child5)) == 4
            }

            context("after child `ComposedSectionProvider` has been removed") {
                beforeEach {
                    global.remove(child2)
                }

                it("should contain 10 elements") {
                    expect(global.numberOfElements) == 10
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: child1b)) == 2
                    expect(global.indexForFirstElement(of: child3)) == 5
                    expect(global.indexForFirstElement(of: child4)) == 8
                    expect(global.indexForFirstElement(of: child5)) == 10
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child1b
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child3
                    expect(global.sectionForElementIndex(6)?.section) === child3
                    expect(global.sectionForElementIndex(7)?.section) === child3
                    expect(global.sectionForElementIndex(8)?.section) === child4
                    expect(global.sectionForElementIndex(9)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child3)) == 1
                    expect(global.childIndex(of: child4)) == 2
                    expect(global.childIndex(of: child5)) == 3
                }
            }

            context("after child `Section` has been removed") {
                beforeEach {
                    global.remove(child3)
                }

                it("should contain 17 elements") {
                    expect(global.numberOfElements) == 17
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: child1b)) == 2
                    expect(global.indexForFirstElement(of: child2)) == 5
                    expect(global.indexForFirstElement(of: child2a)) == 5
                    expect(global.indexForFirstElement(of: child2b)) == 5
                    expect(global.indexForFirstElement(of: child2c)) == 6
                    expect(global.indexForFirstElement(of: child2d)) == 6
                    expect(global.indexForFirstElement(of: child2e)) == 9
                    expect(global.indexForFirstElement(of: child2f)) == 9
                    expect(global.indexForFirstElement(of: child2g)) == 12
                    expect(global.indexForFirstElement(of: child2h)) == 12
                    expect(global.indexForFirstElement(of: child4)) == 15
                    expect(global.indexForFirstElement(of: child5)) == 17
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child1b
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child2b
                    expect(global.sectionForElementIndex(6)?.section) === child2d
                    expect(global.sectionForElementIndex(7)?.section) === child2d
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2f
                    expect(global.sectionForElementIndex(10)?.section) === child2f
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2h
                    expect(global.sectionForElementIndex(13)?.section) === child2h
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child4
                    expect(global.sectionForElementIndex(16)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child4)) == 2
                    expect(global.childIndex(of: child5)) == 3
                }
            }

            context("after a section has been inserted after a child") {
                var mockDelegate: MockSectionUpdateDelegate!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection(["new section index 0", "new section index 1"])

                    global.insert(newSection, after: child3)
                }

                it("should contain 22 elements") {
                    expect(global.numberOfElements) == 22
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: child1b)) == 2
                    expect(global.indexForFirstElement(of: child2)) == 5
                    expect(global.indexForFirstElement(of: child2a)) == 5
                    expect(global.indexForFirstElement(of: child2b)) == 5
                    expect(global.indexForFirstElement(of: child2c)) == 6
                    expect(global.indexForFirstElement(of: child2d)) == 6
                    expect(global.indexForFirstElement(of: child2e)) == 9
                    expect(global.indexForFirstElement(of: child2f)) == 9
                    expect(global.indexForFirstElement(of: child2g)) == 12
                    expect(global.indexForFirstElement(of: child2h)) == 12
                    expect(global.indexForFirstElement(of: child3)) == 15
                    expect(global.indexForFirstElement(of: newSection)) == 18
                    expect(global.indexForFirstElement(of: child4)) == 20
                    expect(global.indexForFirstElement(of: child5)) == 22
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child1b
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child2b
                    expect(global.sectionForElementIndex(6)?.section) === child2d
                    expect(global.sectionForElementIndex(7)?.section) === child2d
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2f
                    expect(global.sectionForElementIndex(10)?.section) === child2f
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2h
                    expect(global.sectionForElementIndex(13)?.section) === child2h
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child3
                    expect(global.sectionForElementIndex(16)?.section) === child3
                    expect(global.sectionForElementIndex(17)?.section) === child3
                    expect(global.sectionForElementIndex(18)?.section) === newSection
                    expect(global.sectionForElementIndex(19)?.section) === newSection
                    expect(global.sectionForElementIndex(20)?.section) === child4
                    expect(global.sectionForElementIndex(21)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 2
                    expect(global.childIndex(of: newSection)) == 3
                    expect(global.childIndex(of: child4)) == 4
                    expect(global.childIndex(of: child5)) == 5
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didInsertElementCalls.count) == 2
                    expect(mockDelegate.didInsertElementCalls[0].section) === global
                    expect(mockDelegate.didInsertElementCalls[0].index) == 18
                    expect(mockDelegate.didInsertElementCalls[1].section) === global
                    expect(mockDelegate.didInsertElementCalls[1].index) == 19
                }
            }

            context("after a section has been inserted at a set index") {
                var mockDelegate: MockSectionUpdateDelegate!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection(["new section index 0", "new section index 1"])

                    global.insert(newSection, at: 3)
                }

                it("should contain 22 elements") {
                    expect(global.numberOfElements) == 22
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: child1b)) == 2
                    expect(global.indexForFirstElement(of: child2)) == 5
                    expect(global.indexForFirstElement(of: child2a)) == 5
                    expect(global.indexForFirstElement(of: child2b)) == 5
                    expect(global.indexForFirstElement(of: child2c)) == 6
                    expect(global.indexForFirstElement(of: child2d)) == 6
                    expect(global.indexForFirstElement(of: child2e)) == 9
                    expect(global.indexForFirstElement(of: child2f)) == 9
                    expect(global.indexForFirstElement(of: child2g)) == 12
                    expect(global.indexForFirstElement(of: child2h)) == 12
                    expect(global.indexForFirstElement(of: child3)) == 15
                    expect(global.indexForFirstElement(of: newSection)) == 18
                    expect(global.indexForFirstElement(of: child4)) == 20
                    expect(global.indexForFirstElement(of: child5)) == 22
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child1b
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child2b
                    expect(global.sectionForElementIndex(6)?.section) === child2d
                    expect(global.sectionForElementIndex(7)?.section) === child2d
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2f
                    expect(global.sectionForElementIndex(10)?.section) === child2f
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2h
                    expect(global.sectionForElementIndex(13)?.section) === child2h
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child3
                    expect(global.sectionForElementIndex(16)?.section) === child3
                    expect(global.sectionForElementIndex(17)?.section) === child3
                    expect(global.sectionForElementIndex(18)?.section) === newSection
                    expect(global.sectionForElementIndex(19)?.section) === newSection
                    expect(global.sectionForElementIndex(20)?.section) === child4
                    expect(global.sectionForElementIndex(21)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 2
                    expect(global.childIndex(of: newSection)) == 3
                    expect(global.childIndex(of: child4)) == 4
                    expect(global.childIndex(of: child5)) == 5
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didInsertElementCalls.count) == 2
                    expect(mockDelegate.didInsertElementCalls[0].section) === global
                    expect(mockDelegate.didInsertElementCalls[0].index) == 18
                    expect(mockDelegate.didInsertElementCalls[1].section) === global
                    expect(mockDelegate.didInsertElementCalls[1].index) == 19
                }
            }

            context("after a section has been inserted at index 0") {
                var mockDelegate: MockSectionUpdateDelegate!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection(["new section index 0", "new section index 1"])

                    global.insert(newSection, at: 0)
                }

                it("should contain 22 elements") {
                    expect(global.numberOfElements) == 22
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: newSection)) == 0
                    expect(global.indexForFirstElement(of: child1)) == 2
                    expect(global.indexForFirstElement(of: child1a)) == 2
                    expect(global.indexForFirstElement(of: child1b)) == 4
                    expect(global.indexForFirstElement(of: child2)) == 7
                    expect(global.indexForFirstElement(of: child2a)) == 7
                    expect(global.indexForFirstElement(of: child2b)) == 7
                    expect(global.indexForFirstElement(of: child2c)) == 8
                    expect(global.indexForFirstElement(of: child2d)) == 8
                    expect(global.indexForFirstElement(of: child2e)) == 11
                    expect(global.indexForFirstElement(of: child2f)) == 11
                    expect(global.indexForFirstElement(of: child2g)) == 14
                    expect(global.indexForFirstElement(of: child2h)) == 14
                    expect(global.indexForFirstElement(of: child3)) == 17
                    expect(global.indexForFirstElement(of: child4)) == 20
                    expect(global.indexForFirstElement(of: child5)) == 22
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === newSection
                    expect(global.sectionForElementIndex(1)?.section) === newSection
                    expect(global.sectionForElementIndex(2)?.section) === child1a
                    expect(global.sectionForElementIndex(3)?.section) === child1a
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child1b
                    expect(global.sectionForElementIndex(6)?.section) === child1b
                    expect(global.sectionForElementIndex(7)?.section) === child2b
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2d
                    expect(global.sectionForElementIndex(10)?.section) === child2d
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2f
                    expect(global.sectionForElementIndex(13)?.section) === child2f
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child2h
                    expect(global.sectionForElementIndex(16)?.section) === child2h
                    expect(global.sectionForElementIndex(17)?.section) === child3
                    expect(global.sectionForElementIndex(18)?.section) === child3
                    expect(global.sectionForElementIndex(19)?.section) === child3
                    expect(global.sectionForElementIndex(20)?.section) === child4
                    expect(global.sectionForElementIndex(21)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: newSection)) == 0
                    expect(global.childIndex(of: child1)) == 1
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 2
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 3
                    expect(global.childIndex(of: child4)) == 4
                    expect(global.childIndex(of: child5)) == 5
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didInsertElementCalls.count) == 2
                    expect(mockDelegate.didInsertElementCalls[0].section) === global
                    expect(mockDelegate.didInsertElementCalls[0].index) == 0
                    expect(mockDelegate.didInsertElementCalls[1].section) === global
                    expect(mockDelegate.didInsertElementCalls[1].index) == 1
                }
            }

            context("after a section has been inserted at a final index") {
                var mockDelegate: MockSectionUpdateDelegate!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection(["new section index 0", "new section index 1"])

                    global.insert(newSection, at: 5)
                }

                it("should contain 22 elements") {
                    expect(global.numberOfElements) == 22
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: child1b)) == 2
                    expect(global.indexForFirstElement(of: child2)) == 5
                    expect(global.indexForFirstElement(of: child2a)) == 5
                    expect(global.indexForFirstElement(of: child2b)) == 5
                    expect(global.indexForFirstElement(of: child2c)) == 6
                    expect(global.indexForFirstElement(of: child2d)) == 6
                    expect(global.indexForFirstElement(of: child2e)) == 9
                    expect(global.indexForFirstElement(of: child2f)) == 9
                    expect(global.indexForFirstElement(of: child2g)) == 12
                    expect(global.indexForFirstElement(of: child2h)) == 12
                    expect(global.indexForFirstElement(of: child3)) == 15
                    expect(global.indexForFirstElement(of: child4)) == 18
                    expect(global.indexForFirstElement(of: child5)) == 20
                    expect(global.indexForFirstElement(of: newSection)) == 20
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child1b
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child2b
                    expect(global.sectionForElementIndex(6)?.section) === child2d
                    expect(global.sectionForElementIndex(7)?.section) === child2d
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2f
                    expect(global.sectionForElementIndex(10)?.section) === child2f
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2h
                    expect(global.sectionForElementIndex(13)?.section) === child2h
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child3
                    expect(global.sectionForElementIndex(16)?.section) === child3
                    expect(global.sectionForElementIndex(17)?.section) === child3
                    expect(global.sectionForElementIndex(18)?.section) === child4
                    expect(global.sectionForElementIndex(19)?.section) === child4
                    expect(global.sectionForElementIndex(20)?.section) === newSection
                    expect(global.sectionForElementIndex(21)?.section) === newSection
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 2
                    expect(global.childIndex(of: child4)) == 3
                    expect(global.childIndex(of: child5)) == 4
                    expect(global.childIndex(of: newSection)) == 5
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didInsertElementCalls.count) == 2
                    expect(mockDelegate.didInsertElementCalls[0].section) === global
                    expect(mockDelegate.didInsertElementCalls[0].index) == 20
                    expect(mockDelegate.didInsertElementCalls[1].section) === global
                    expect(mockDelegate.didInsertElementCalls[1].index) == 21
                }
            }

            context("after a section has been inserted in a child section provider") {
                var mockDelegate: MockSectionUpdateDelegate!
                var newSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    newSection = ArraySection(["new section index 0", "new section index 1"])

                    child1.insert(newSection, at: 1)
                }

                it("should contain 22 elements") {
                    expect(global.numberOfElements) == 22
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: child1a)) == 0
                    expect(global.indexForFirstElement(of: newSection)) == 2
                    expect(global.indexForFirstElement(of: child1b)) == 4
                    expect(global.indexForFirstElement(of: child2)) == 7
                    expect(global.indexForFirstElement(of: child2a)) == 7
                    expect(global.indexForFirstElement(of: child2b)) == 7
                    expect(global.indexForFirstElement(of: child2c)) == 8
                    expect(global.indexForFirstElement(of: child2d)) == 8
                    expect(global.indexForFirstElement(of: child2e)) == 11
                    expect(global.indexForFirstElement(of: child2f)) == 11
                    expect(global.indexForFirstElement(of: child2g)) == 14
                    expect(global.indexForFirstElement(of: child2h)) == 14
                    expect(global.indexForFirstElement(of: child3)) == 17
                    expect(global.indexForFirstElement(of: child4)) == 20
                    expect(global.indexForFirstElement(of: child5)) == 22
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1a
                    expect(global.sectionForElementIndex(1)?.section) === child1a
                    expect(global.sectionForElementIndex(2)?.section) === newSection
                    expect(global.sectionForElementIndex(3)?.section) === newSection
                    expect(global.sectionForElementIndex(4)?.section) === child1b
                    expect(global.sectionForElementIndex(5)?.section) === child1b
                    expect(global.sectionForElementIndex(6)?.section) === child1b
                    expect(global.sectionForElementIndex(7)?.section) === child2b
                    expect(global.sectionForElementIndex(8)?.section) === child2d
                    expect(global.sectionForElementIndex(9)?.section) === child2d
                    expect(global.sectionForElementIndex(10)?.section) === child2d
                    expect(global.sectionForElementIndex(11)?.section) === child2f
                    expect(global.sectionForElementIndex(12)?.section) === child2f
                    expect(global.sectionForElementIndex(13)?.section) === child2f
                    expect(global.sectionForElementIndex(14)?.section) === child2h
                    expect(global.sectionForElementIndex(15)?.section) === child2h
                    expect(global.sectionForElementIndex(16)?.section) === child2h
                    expect(global.sectionForElementIndex(17)?.section) === child3
                    expect(global.sectionForElementIndex(18)?.section) === child3
                    expect(global.sectionForElementIndex(19)?.section) === child3
                    expect(global.sectionForElementIndex(20)?.section) === child4
                    expect(global.sectionForElementIndex(21)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: child1a)).to(beNil())
                    expect(global.childIndex(of: newSection)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 2
                    expect(global.childIndex(of: child4)) == 3
                    expect(global.childIndex(of: child5)) == 4
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didInsertElementCalls.count) == 2
                    expect(mockDelegate.didInsertElementCalls[0].section) === global
                    expect(mockDelegate.didInsertElementCalls[0].index) == 2
                    expect(mockDelegate.didInsertElementCalls[1].section) === global
                    expect(mockDelegate.didInsertElementCalls[1].index) == 3
                }

                context("elements inserted in that child should be propagated") {
                    beforeEach {
                        mockDelegate = MockSectionUpdateDelegate()
                        global.updateDelegate = mockDelegate

                        newSection.append("new section index 2")
                    }

                    it("should make correct delegate calls") {
                        expect(mockDelegate.didInsertElementCalls.count) == 1
                        expect(mockDelegate.didInsertElementCalls[0].section) === global
                        expect(mockDelegate.didInsertElementCalls[0].index) == 4
                    }
                }

                context("elements removed from that child should be propagated") {
                    beforeEach {
                        mockDelegate = MockSectionUpdateDelegate()
                        global.updateDelegate = mockDelegate

                        newSection.removeLast()
                    }

                    it("should make correct delegate calls") {
                        expect(mockDelegate.didRemoveElementCalls.count) == 1
                        expect(mockDelegate.didRemoveElementCalls[0].section) === global
                        expect(mockDelegate.didRemoveElementCalls[0].index) == 3
                    }
                }
            }

            context("after a section has been removed from a child section provider") {
                var mockDelegate: MockSectionUpdateDelegate!
                var removedSection: ArraySection<String>!

                beforeEach {
                    mockDelegate = MockSectionUpdateDelegate()
                    global.updateDelegate = mockDelegate

                    removedSection = child1a

                    child1.remove(removedSection)
                }

                it("should contain 18 elements") {
                    expect(global.numberOfElements) == 18
                }

                it("should return the correct first element indexes") {
                    expect(global.indexForFirstElement(of: child1)) == 0
                    expect(global.indexForFirstElement(of: removedSection)).to(beNil())
                    expect(global.indexForFirstElement(of: child1b)) == 0
                    expect(global.indexForFirstElement(of: child2)) == 3
                    expect(global.indexForFirstElement(of: child2a)) == 3
                    expect(global.indexForFirstElement(of: child2b)) == 3
                    expect(global.indexForFirstElement(of: child2c)) == 4
                    expect(global.indexForFirstElement(of: child2d)) == 4
                    expect(global.indexForFirstElement(of: child2e)) == 7
                    expect(global.indexForFirstElement(of: child2f)) == 7
                    expect(global.indexForFirstElement(of: child2g)) == 10
                    expect(global.indexForFirstElement(of: child2h)) == 10
                    expect(global.indexForFirstElement(of: child3)) == 13
                    expect(global.indexForFirstElement(of: child4)) == 16
                    expect(global.indexForFirstElement(of: child5)) == 18
                }

                it("should return the correct section for element index") {
                    expect(global.sectionForElementIndex(0)?.section) === child1b
                    expect(global.sectionForElementIndex(1)?.section) === child1b
                    expect(global.sectionForElementIndex(2)?.section) === child1b
                    expect(global.sectionForElementIndex(3)?.section) === child2b
                    expect(global.sectionForElementIndex(4)?.section) === child2d
                    expect(global.sectionForElementIndex(5)?.section) === child2d
                    expect(global.sectionForElementIndex(6)?.section) === child2d
                    expect(global.sectionForElementIndex(7)?.section) === child2f
                    expect(global.sectionForElementIndex(8)?.section) === child2f
                    expect(global.sectionForElementIndex(9)?.section) === child2f
                    expect(global.sectionForElementIndex(10)?.section) === child2h
                    expect(global.sectionForElementIndex(11)?.section) === child2h
                    expect(global.sectionForElementIndex(12)?.section) === child2h
                    expect(global.sectionForElementIndex(13)?.section) === child3
                    expect(global.sectionForElementIndex(14)?.section) === child3
                    expect(global.sectionForElementIndex(15)?.section) === child3
                    expect(global.sectionForElementIndex(16)?.section) === child4
                    expect(global.sectionForElementIndex(17)?.section) === child4
                }

                it("should return the correct child indexes") {
                    expect(global.childIndex(of: child1)) == 0
                    expect(global.childIndex(of: removedSection)).to(beNil())
                    expect(global.childIndex(of: child1b)).to(beNil())
                    expect(global.childIndex(of: child2)) == 1
                    expect(global.childIndex(of: child2a)).to(beNil())
                    expect(global.childIndex(of: child2b)).to(beNil())
                    expect(global.childIndex(of: child2c)).to(beNil())
                    expect(global.childIndex(of: child2d)).to(beNil())
                    expect(global.childIndex(of: child2e)).to(beNil())
                    expect(global.childIndex(of: child2f)).to(beNil())
                    expect(global.childIndex(of: child2g)).to(beNil())
                    expect(global.childIndex(of: child2h)).to(beNil())
                    expect(global.childIndex(of: child3)) == 2
                    expect(global.childIndex(of: child4)) == 3
                    expect(global.childIndex(of: child5)) == 4
                }

                it("should make correct delegate calls") {
                    expect(mockDelegate.didRemoveElementCalls.count) == 2
                    expect(mockDelegate.didRemoveElementCalls[0].section) === global
                    expect(mockDelegate.didRemoveElementCalls[0].index) == 1
                    expect(mockDelegate.didRemoveElementCalls[1].section) === global
                    expect(mockDelegate.didRemoveElementCalls[1].index) == 0
                }
            }
        }
    }

}

private final class MockSectionUpdateDelegate: SectionUpdateDelegate {
    private(set) var willBeginUpdatingCalls: [Section] = []
    private(set) var didEndUpdatingCalls: [Section] = []
    private(set) var invalidateAllCalls: [Section] = []
    private(set) var didInsertElementCalls: [(section: Section, index: Int)] = []
    private(set) var didRemoveElementCalls: [(section: Section, index: Int)] = []

    func willBeginUpdating(_ section: Section) {
        willBeginUpdatingCalls.append(section)
    }

    func didEndUpdating(_ section: Section) {
        didEndUpdatingCalls.append(section)
    }

    func invalidateAll(_ section: Section) {
        invalidateAllCalls.append(section)
    }

    func section(_ section: Section, didInsertElementAt index: Int) {
        didInsertElementCalls.append((section, index))
    }

    func section(_ section: Section, didRemoveElementAt index: Int) {
        didRemoveElementCalls.append((section, index))
    }

    func section(_ section: Section, didUpdateElementAt index: Int) {}

    func section(_ section: Section, didMoveElementAt index: Int, to newIndex: Int) {}

    func selectedIndexes(in section: Section) -> [Int] { [] }

    func section(_ section: Section, select index: Int) {}

    func section(_ section: Section, deselect index: Int) {}

    func section(_ section: Section, move sourceIndex: Int, to destinationIndex: Int) {}

    func sectionDidInvalidateHeader(_ section: Section) {}
    func sectionDidInvalidateFooter(_ section: Section) {}
}
