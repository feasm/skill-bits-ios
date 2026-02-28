import XCTest
@testable import SkillBitsGamification

final class GamificationTests: XCTestCase {
    func testLevelBoundaries() {
        XCTAssertEqual(LevelService.level(for: 0), 1)
        XCTAssertEqual(LevelService.level(for: 300), 2)
        XCTAssertEqual(LevelService.level(for: 1000), 3)
        XCTAssertEqual(LevelService.level(for: 7000), 5)
    }

    func testQuizXPWithPerfectQuizFirst() {
        XCTAssertEqual(XPService.xpForQuiz(score: 100, quizFirst: true), 105)
    }

    func testStreakIncreaseWhenStudied() {
        XCTAssertEqual(StreakService.increase(4, studiedToday: true), 5)
        XCTAssertEqual(StreakService.increase(4, studiedToday: false), 4)
    }
}
