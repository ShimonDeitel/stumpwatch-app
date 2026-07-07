import XCTest
@testable import Stumpwatch

@MainActor
final class StumpwatchTests: XCTestCase {
    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(JobEntry(treeLocation: "Test", workType: "Today", dateDone: "Good"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        let store = Store()
        store.isPro = false
        while store.entries.count < Store.freeLimit {
            store.add(JobEntry(treeLocation: "X", workType: "Y", dateDone: "Z"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProEvenAtLimit() {
        let store = Store()
        store.isPro = true
        while store.entries.count < Store.freeLimit {
            store.add(JobEntry(treeLocation: "X", workType: "Y", dateDone: "Z"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesEntry() {
        let store = Store()
        let entry = JobEntry(treeLocation: "ToDelete", workType: "Today", dateDone: "Good")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateModifiesEntry() {
        let store = Store()
        var entry = JobEntry(treeLocation: "Orig", workType: "Today", dateDone: "Good")
        store.add(entry)
        entry.treeLocation = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.treeLocation, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
