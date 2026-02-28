import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseCoursesRepository: CoursesRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchCourses() async throws -> [Course] {
        let courses: [CourseDTO] = try await client.from("courses")
            .select().order("sort_order").execute().value
        var result: [Course] = []
        for dto in courses {
            result.append(try await buildCourse(dto))
        }
        return result
    }

    public func fetchCourse(id: String) async throws -> Course {
        let dto: CourseDTO = try await client.from("courses")
            .select().eq("id", value: id).single().execute().value
        return try await buildCourse(dto)
    }

    private func buildCourse(_ dto: CourseDTO) async throws -> Course {
        let moduleDTOs: [ModuleDTO] = try await client.from("modules")
            .select().eq("course_id", value: dto.id).order("sort_order").execute().value

        let moduleIds = moduleDTOs.map(\.id)

        let lessonDTOs: [LessonDTO] = try await client.from("lessons")
            .select("id, module_id, title, duration, sort_order")
            .in("module_id", values: moduleIds)
            .order("sort_order")
            .execute().value

        let userId = try await client.auth.session.user.id

        let progressDTOs: [LessonProgressDTO] = try await client.from("lesson_progress")
            .select("lesson_id, status, progress")
            .eq("user_id", value: userId.uuidString)
            .in("lesson_id", values: lessonDTOs.map(\.id))
            .execute().value

        let progressMap = Dictionary(uniqueKeysWithValues: progressDTOs.map { ($0.lessonId, $0) })

        let quizAttempts: [QuizAttemptDTO] = try await client.from("quiz_attempts")
            .select("module_id, score, passed")
            .eq("user_id", value: userId.uuidString)
            .in("module_id", values: moduleIds)
            .order("created_at", ascending: false)
            .execute().value

        let latestQuiz = Dictionary(grouping: quizAttempts, by: \.moduleId).compactMapValues(\.first)

        var modules: [Module] = []
        for modDTO in moduleDTOs {
            let lessons = lessonDTOs
                .filter { $0.moduleId == modDTO.id }
                .map { lDTO -> Lesson in
                    let prog = progressMap[lDTO.id]
                    let status = LessonStatus(rawValue: prog?.status ?? "locked") ?? .locked
                    return Lesson(id: lDTO.id, title: lDTO.title, duration: lDTO.duration,
                                  status: status, progress: prog.map { Int($0.progress) })
                }

            let quiz = latestQuiz[modDTO.id]
            modules.append(Module(
                id: modDTO.id, title: modDTO.title, description: modDTO.description,
                duration: modDTO.duration, lessons: lessons, quizAvailable: true,
                quizCompleted: quiz?.passed ?? false, quizScore: quiz?.score,
                accessTier: modDTO.accessTier == "premium" ? .premium : .free
            ))
        }

        let totalLessons = modules.flatMap(\.lessons).count
        let completed = modules.flatMap(\.lessons).filter { $0.status == .completed }.count
        let progress = totalLessons > 0 ? (completed * 100) / totalLessons : 0

        return dto.toDomain(modules: modules, progress: progress)
    }
}
