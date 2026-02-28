import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseLessonRepository: LessonRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchLessonContent(courseId: String, moduleId: String, lessonId: String) async throws -> LessonContent {
        struct LessonRow: Decodable {
            let id: String
            let title: String
            let duration: String
            let content: [LessonBlockDTO]?
        }

        let row: LessonRow = try await client.from("lessons")
            .select("id, title, duration, content")
            .eq("id", value: lessonId)
            .single()
            .execute().value

        let blocks = (row.content ?? []).map { $0.toDomain() }
        return LessonContent(lessonId: row.id, title: row.title, readTime: row.duration, content: blocks)
    }

    public func completeLesson(courseId: String, moduleId: String, lessonId: String) async throws {
        try await client.rpc("complete_lesson", params: [
            "p_lesson_id": lessonId,
            "p_module_id": moduleId
        ]).execute()
    }
}
