import XCTest
@testable import BorderStamp

@MainActor
final class BorderStampTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(Entry(country: "Test", crossingPoint: "Test2", stayDays: 1, visitCount: 2))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(Entry(country: "X", crossingPoint: "Y", stayDays: 1, visitCount: 1))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() {
        let entry = Entry(country: "Del", crossingPoint: "Me", stayDays: 1, visitCount: 1)
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        var entry = Entry(country: "Old", crossingPoint: "Old2", stayDays: 1, visitCount: 1)
        store.add(entry)
        entry.country = "New"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.country, "New")
    }

    func testDeleteAtOffsets() {
        store.add(Entry(country: "A", crossingPoint: "B", stayDays: 1, visitCount: 1))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
