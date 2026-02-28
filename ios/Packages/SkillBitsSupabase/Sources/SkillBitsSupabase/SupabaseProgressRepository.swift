import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseProgressRepository: ProgressRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchProgress() async throws -> UserProgress {
        struct BadgeDTO: Decodable {
            let id: String
            let name: String
            let icon: String
            let unlocked: Bool
        }

        struct ProgressDTO: Decodable {
            let xp: Int
            let streakDays: Int
            let dailyGoal: String
            let studiedMinutesToday: Int
            let badges: [BadgeDTO]

            enum CodingKeys: String, CodingKey {
                case xp, badges
                case streakDays = "streak_days"
                case dailyGoal = "daily_goal"
                case studiedMinutesToday = "studied_minutes_today"
            }
        }

        let userId = try await client.auth.session.user.id

        let dto: ProgressDTO = try await client.from("user_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute().value

        return UserProgress(
            xp: dto.xp,
            streakDays: dto.streakDays,
            dailyGoal: dto.dailyGoal == "minutes30" ? .minutes30 : .minutes15,
            studiedMinutesToday: dto.studiedMinutesToday,
            badges: dto.badges.map { Badge(id: $0.id, name: $0.name, icon: $0.icon, unlocked: $0.unlocked) }
        )
    }

    public func saveProgress(_ progress: UserProgress) async throws {
        struct UpdatePayload: Encodable {
            let xp: Int
            let streak_days: Int
            let daily_goal: String
            let studied_minutes_today: Int
        }

        let userId = try await client.auth.session.user.id

        try await client.from("user_progress")
            .update(UpdatePayload(
                xp: progress.xp,
                streak_days: progress.streakDays,
                daily_goal: progress.dailyGoal == .minutes30 ? "minutes30" : "minutes15",
                studied_minutes_today: progress.studiedMinutesToday
            ))
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}
