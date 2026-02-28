import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseQuizRepository: QuizRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchQuiz(moduleId: String) async throws -> [QuizQuestion] {
        struct QuizDTO: Decodable {
            let id: String
            let question: String
            let options: [String]
            let correctIndex: Int
            let explanation: String

            enum CodingKeys: String, CodingKey {
                case id, question, options, explanation
                case correctIndex = "correct_index"
            }
        }

        let dtos: [QuizDTO] = try await client.from("quiz_questions")
            .select()
            .eq("module_id", value: moduleId)
            .order("sort_order")
            .execute().value

        return dtos.map {
            QuizQuestion(id: $0.id, question: $0.question, options: $0.options,
                        correctIndex: $0.correctIndex, explanation: $0.explanation)
        }
    }

    public func submitQuiz(moduleId: String, answers: [Int], quizFirst: Bool) async throws -> QuizResult {
        struct SubmitParams: Encodable {
            let p_module_id: String
            let p_answers: [Int]
            let p_quiz_first: Bool
        }

        struct SubmitResponse: Decodable {
            let moduleId: String
            let score: Int
            let correctCount: Int
            let total: Int
            let passed: Bool
            let quizFirst: Bool

            enum CodingKeys: String, CodingKey {
                case score, total, passed
                case moduleId = "module_id"
                case correctCount = "correct_count"
                case quizFirst = "quiz_first"
            }
        }

        let result: SubmitResponse = try await client.rpc("submit_quiz", params: SubmitParams(
            p_module_id: moduleId,
            p_answers: answers,
            p_quiz_first: quizFirst
        )).execute().value

        return QuizResult(
            moduleId: result.moduleId, score: result.score,
            correctCount: result.correctCount, total: result.total,
            passed: result.passed, quizFirst: result.quizFirst
        )
    }

    public func fetchGuidedReview(moduleId: String) async throws -> [GuidedReviewPoint] {
        struct ReviewDTO: Decodable {
            let id: String
            let topic: String
            let explanation: String
            let lessonId: String

            enum CodingKeys: String, CodingKey {
                case id, topic, explanation
                case lessonId = "lesson_id"
            }
        }

        struct ReviewParams: Encodable {
            let p_module_id: String
        }

        let dtos: [ReviewDTO] = try await client.rpc("get_guided_review", params: ReviewParams(
            p_module_id: moduleId
        )).execute().value

        return dtos.map {
            GuidedReviewPoint(id: $0.id, topic: $0.topic, explanation: $0.explanation, lessonId: $0.lessonId)
        }
    }
}
