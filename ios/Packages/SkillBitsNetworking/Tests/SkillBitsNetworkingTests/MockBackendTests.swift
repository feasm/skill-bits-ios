import XCTest
@testable import SkillBitsNetworking

final class MockBackendTests: XCTestCase {
    func testQuizPassRule() async {
        let backend = MockBackendService()
        let result = await backend.submit(moduleId: "m1", answers: [1, 1], quizFirst: false)
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.score, 100)
    }

    func testFreemiumToggleAfterPurchase() async {
        let backend = MockBackendService()
        let before = await backend.isPremium()
        XCTAssertFalse(before)
        await backend.setPremium(true)
        let after = await backend.isPremium()
        XCTAssertTrue(after)
    }
}
