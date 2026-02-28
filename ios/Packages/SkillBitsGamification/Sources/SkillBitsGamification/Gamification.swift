import Foundation
import SkillBitsCore

public enum LevelService {
    public static func level(for xp: Int) -> Int {
        switch xp {
        case ..<300: return 1
        case ..<1000: return 2
        case ..<3000: return 3
        case ..<7000: return 4
        default: return 5
        }
    }

    public static func levelName(for xp: Int) -> String {
        switch level(for: xp) {
        case 1: return "Bit"
        case 2: return "Byte"
        case 3: return "KiloByte"
        case 4: return "MegaByte"
        default: return "GigaByte"
        }
    }
}

public enum XPService {
    public static func xpForLessonCompleted() -> Int { 20 }
    public static func xpForQuiz(score: Int, quizFirst: Bool) -> Int {
        var xp = 30
        if score == 100 { xp += 50 }
        if score == 100 && quizFirst { xp += 75 }
        return xp
    }
}

public enum StreakService {
    public static func increase(_ current: Int, studiedToday: Bool) -> Int {
        studiedToday ? current + 1 : current
    }
}

public enum BadgeService {
    public static func apply(progress: UserProgress) -> [Badge] {
        progress.badges.map { badge in
            if badge.id == "b2" && progress.xp >= 300 {
                return Badge(id: badge.id, name: badge.name, icon: badge.icon, unlocked: true)
            }
            return badge
        }
    }
}
