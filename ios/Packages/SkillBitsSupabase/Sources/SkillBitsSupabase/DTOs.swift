import Foundation
import SkillBitsCore

struct CourseDTO: Decodable {
    let id: String
    let title: String
    let shortDesc: String
    let description: String
    let emoji: String
    let category: String
    let level: String
    let totalDuration: String
    let color1: String
    let color2: String
    let accessTier: String
    let instructor: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, category, level, color1, color2, instructor
        case shortDesc = "short_desc"
        case totalDuration = "total_duration"
        case accessTier = "access_tier"
    }

    func toDomain(modules: [Module], progress: Int) -> Course {
        Course(
            id: id, title: title, shortDesc: shortDesc, description: description,
            emoji: emoji, category: category, level: level, totalDuration: totalDuration,
            color1: color1, color2: color2,
            accessTier: accessTier == "premium" ? .premium : .free,
            instructor: instructor, progress: progress, modules: modules
        )
    }
}

struct ModuleDTO: Decodable {
    let id: String
    let courseId: String
    let title: String
    let description: String
    let duration: String
    let accessTier: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title, description, duration
        case courseId = "course_id"
        case accessTier = "access_tier"
        case sortOrder = "sort_order"
    }
}

struct LessonDTO: Decodable {
    let id: String
    let moduleId: String
    let title: String
    let duration: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title, duration
        case moduleId = "module_id"
        case sortOrder = "sort_order"
    }
}

struct LessonProgressDTO: Decodable {
    let lessonId: String
    let status: String
    let progress: Float

    enum CodingKeys: String, CodingKey {
        case status, progress
        case lessonId = "lesson_id"
    }
}

struct QuizAttemptDTO: Decodable {
    let moduleId: String
    let score: Int
    let passed: Bool

    enum CodingKeys: String, CodingKey {
        case score, passed
        case moduleId = "module_id"
    }
}

struct LessonBlockDTO: Decodable {
    let type: String
    let value: LessonBlockValue?
    let language: String?
    let text: String?
    let title: String?

    func toDomain() -> LessonBlock {
        switch type {
        case "heading":
            return .heading(value?.stringValue ?? "")
        case "heading2":
            return .heading2(value?.stringValue ?? "")
        case "paragraph":
            return .paragraph(value?.stringValue ?? "")
        case "list":
            return .list(value?.arrayValue ?? [])
        case "code":
            return .code(language: language ?? "", text: text ?? "")
        case "callout":
            return .callout(title: title, text: text ?? value?.stringValue ?? "")
        default:
            return .paragraph(value?.stringValue ?? "")
        }
    }
}

enum LessonBlockValue: Decodable {
    case string(String)
    case array([String])

    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    var arrayValue: [String]? {
        if case .array(let a) = self { return a }
        return nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .string(s)
            return
        }
        if let a = try? container.decode([String].self) {
            self = .array(a)
            return
        }
        throw DecodingError.typeMismatch(LessonBlockValue.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected String or [String]"))
    }
}
