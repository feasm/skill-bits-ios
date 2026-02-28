import Foundation

public enum AccessTier: String, Codable, Sendable {
    case free
    case premium
}

public enum LessonStatus: String, Codable, Sendable {
    case locked
    case available
    case inProgress
    case completed
}

public struct Lesson: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let duration: String
    public var status: LessonStatus
    public var progress: Int?

    public init(id: String, title: String, duration: String, status: LessonStatus, progress: Int? = nil) {
        self.id = id
        self.title = title
        self.duration = duration
        self.status = status
        self.progress = progress
    }
}

public struct Module: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let duration: String
    public var lessons: [Lesson]
    public var quizAvailable: Bool
    public var quizCompleted: Bool
    public var quizScore: Int?
    public let accessTier: AccessTier

    public init(id: String, title: String, description: String, duration: String, lessons: [Lesson], quizAvailable: Bool, quizCompleted: Bool = false, quizScore: Int? = nil, accessTier: AccessTier = .free) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.lessons = lessons
        self.quizAvailable = quizAvailable
        self.quizCompleted = quizCompleted
        self.quizScore = quizScore
        self.accessTier = accessTier
    }
}

public struct Course: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let shortDesc: String
    public let description: String
    public let emoji: String
    public let category: String
    public let level: String
    public let totalDuration: String
    public let color1: String
    public let color2: String
    public let accessTier: AccessTier
    public let instructor: String
    public var progress: Int
    public var modules: [Module]

    public enum EffectiveAccess: String {
        case free, partial, premium
    }

    public var effectiveAccess: EffectiveAccess {
        let tiers = Set(modules.map(\.accessTier))
        if tiers == [.free] { return .free }
        if tiers == [.premium] { return .premium }
        return .partial
    }

    public init(
        id: String,
        title: String,
        shortDesc: String,
        description: String,
        emoji: String,
        category: String,
        level: String,
        totalDuration: String,
        color1: String,
        color2: String,
        accessTier: AccessTier,
        instructor: String = "Equipe SkillBits",
        progress: Int = 0,
        modules: [Module]
    ) {
        self.id = id
        self.title = title
        self.shortDesc = shortDesc
        self.description = description
        self.emoji = emoji
        self.category = category
        self.level = level
        self.totalDuration = totalDuration
        self.color1 = color1
        self.color2 = color2
        self.accessTier = accessTier
        self.instructor = instructor
        self.progress = progress
        self.modules = modules
    }
}

public enum LessonBlock: Codable, Hashable, Sendable {
    case heading(String)
    case heading2(String)
    case paragraph(String)
    case list([String])
    case code(language: String, text: String)
    case callout(title: String?, text: String)
}

public struct LessonContent: Codable, Hashable, Sendable {
    public let lessonId: String
    public let title: String
    public let readTime: String
    public let content: [LessonBlock]

    public init(lessonId: String, title: String, readTime: String, content: [LessonBlock]) {
        self.lessonId = lessonId
        self.title = title
        self.readTime = readTime
        self.content = content
    }
}

public struct QuizQuestion: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let question: String
    public let options: [String]
    public let correctIndex: Int
    public let explanation: String

    public init(id: String, question: String, options: [String], correctIndex: Int, explanation: String) {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
    }
}

public struct GuidedReviewPoint: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let topic: String
    public let explanation: String
    public let lessonId: String

    public init(id: String, topic: String, explanation: String, lessonId: String) {
        self.id = id
        self.topic = topic
        self.explanation = explanation
        self.lessonId = lessonId
    }
}

public struct QuizResult: Identifiable, Codable, Hashable, Sendable {
    public let moduleId: String
    public let score: Int
    public let correctCount: Int
    public let total: Int
    public let passed: Bool
    public let quizFirst: Bool
    public var id: String { moduleId + "-" + String(score) + "-" + String(correctCount) }

    public init(moduleId: String, score: Int, correctCount: Int, total: Int, passed: Bool, quizFirst: Bool) {
        self.moduleId = moduleId
        self.score = score
        self.correctCount = correctCount
        self.total = total
        self.passed = passed
        self.quizFirst = quizFirst
    }
}

public enum DailyGoal: Int, Codable, CaseIterable, Sendable {
    case minutes15 = 15
    case minutes30 = 30
}

public struct Badge: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
    public let unlocked: Bool

    public init(id: String, name: String, icon: String, unlocked: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.unlocked = unlocked
    }
}

public struct UserProgress: Codable, Hashable, Sendable {
    public var xp: Int
    public var streakDays: Int
    public var dailyGoal: DailyGoal
    public var studiedMinutesToday: Int
    public var badges: [Badge]

    public init(xp: Int, streakDays: Int, dailyGoal: DailyGoal, studiedMinutesToday: Int, badges: [Badge]) {
        self.xp = xp
        self.streakDays = streakDays
        self.dailyGoal = dailyGoal
        self.studiedMinutesToday = studiedMinutesToday
        self.badges = badges
    }
}
