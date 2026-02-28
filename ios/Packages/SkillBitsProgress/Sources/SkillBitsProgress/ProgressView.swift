import SwiftUI
import Charts
import Observation
import SkillBitsCore
import SkillBitsDesignSystem
import SkillBitsGamification

@Observable
public final class ProgressViewModel {
    public var progress = UserProgress(xp: 0, streakDays: 0, dailyGoal: .minutes15, studiedMinutesToday: 0, badges: [])
    public var courses: [Course] = []
    private let repo: ProgressRepository
    private let coursesRepo: CoursesRepository

    public init(repo: ProgressRepository, coursesRepo: CoursesRepository) {
        self.repo = repo
        self.coursesRepo = coursesRepo
    }

    public func load() {
        Task {
            let value = (try? await repo.fetchProgress()) ?? progress
            let courseData = (try? await coursesRepo.fetchCourses()) ?? []
            await MainActor.run {
                self.progress = value
                self.courses = courseData
            }
        }
    }
}

public struct ProgressScreenView: View {
    @Bindable var viewModel: ProgressViewModel
    @State private var animateIn = false
    @State private var selectedDay: String = "Sex"

    private struct WeekBar: Identifiable {
        let id = UUID()
        let day: String
        let value: Int
    }

    private var weeklyData: [WeekBar] {
        [
            WeekBar(day: "Seg", value: 10),
            WeekBar(day: "Ter", value: 18),
            WeekBar(day: "Qua", value: 24),
            WeekBar(day: "Qui", value: 14),
            WeekBar(day: "Sex", value: 26),
            WeekBar(day: "Sab", value: 30),
            WeekBar(day: "Dom", value: 20)
        ]
    }

    private var selectedBar: WeekBar {
        weeklyData.first(where: { $0.day == selectedDay }) ?? weeklyData[0]
    }

    private var weekTotal: Int {
        weeklyData.reduce(0) { $0 + $1.value }
    }

    private var dailyGoalRatio: Double {
        Double(viewModel.progress.studiedMinutesToday) / Double(max(1, viewModel.progress.dailyGoal.rawValue))
    }

    public init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progresso")
                                .font(SBFont.display(30))
                            Text("Você está no ritmo de subir de nível hoje")
                                .font(SBFont.body(14))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                        Spacer()
                        Circle()
                            .fill(SBColor.purpleBg)
                            .frame(width: 52, height: 52)
                            .overlay(
                                VStack(spacing: 0) {
                                    Text("Lv")
                                        .font(SBFont.body(10))
                                        .foregroundStyle(SBColor.purple)
                                    Text("\(LevelService.level(for: viewModel.progress.xp))")
                                        .font(SBFont.stat(16))
                                        .foregroundStyle(SBColor.purple)
                                }
                            )
                    }

                    SBGradientBanner {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("XP desta conta")
                                        .font(SBFont.body(12))
                                        .foregroundStyle(.white.opacity(0.82))
                                    Text("\(viewModel.progress.xp) XP")
                                        .font(SBFont.display(28))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Sequência")
                                        .font(SBFont.body(12))
                                        .foregroundStyle(.white.opacity(0.82))
                                    Text("🔥 \(viewModel.progress.streakDays) dias")
                                        .font(SBFont.title(18))
                                        .foregroundStyle(.white)
                                }
                            }
                            SBProgressBar(value: Double(viewModel.progress.xp % 250) / 250.0)
                            Text("\(250 - (viewModel.progress.xp % 250)) XP para o próximo nível")
                                .font(SBFont.body(12))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    SBSectionHeader("Missão diária")
                    SBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Meta de hoje")
                                    .font(SBFont.label(14))
                                Spacer()
                                Text("\(viewModel.progress.studiedMinutesToday)/\(viewModel.progress.dailyGoal.rawValue) min")
                                    .font(SBFont.title(16))
                                    .foregroundStyle(SBColor.accent)
                            }
                            SBProgressBar(value: min(1, dailyGoalRatio))
                            Text(dailyGoalRatio >= 1 ? "Missão completa! +20 XP" : "Complete a meta para ganhar +20 XP")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        gamifiedStat(icon: "flame.fill", value: "\(viewModel.progress.streakDays)", label: "Dias seguidos", tint: SBColor.warningAlt, bg: SBColor.warningAlt.opacity(0.12))
                        gamifiedStat(icon: "clock.fill", value: "\(viewModel.progress.studiedMinutesToday) min", label: "Hoje", tint: SBColor.accent, bg: SBColor.accentBg)
                        gamifiedStat(icon: "trophy.fill", value: "\(viewModel.progress.badges.filter { $0.unlocked }.count)", label: "Conquistas", tint: SBColor.success, bg: SBColor.successBg)
                        gamifiedStat(icon: "chart.bar.fill", value: "\(weekTotal) min", label: "Semana", tint: SBColor.purple, bg: SBColor.purpleBg)
                    }

                    SBSectionHeader("Evolução semanal")
                    SBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Minutos por dia")
                                    .font(SBFont.label(14))
                                Spacer()
                                Text("Selecionado: \(selectedBar.day) • \(selectedBar.value) min")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                            }

                            Chart(weeklyData) { bar in
                                BarMark(
                                    x: .value("Dia", bar.day),
                                    y: .value("Minutos", animateIn ? bar.value : 0)
                                )
                                .foregroundStyle(
                                    bar.day == selectedDay
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [SBColor.purple, SBColor.accent],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [SBColor.teal, SBColor.accent.opacity(0.85)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                )
                                .cornerRadius(4)
                            }
                            .chartYAxis(.hidden)
                            .frame(height: 158)
                            .animation(.easeOut(duration: 0.8), value: animateIn)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(weeklyData) { day in
                                        Button {
                                            withAnimation(SBMotion.quick) {
                                                selectedDay = day.day
                                            }
                                        } label: {
                                            Text(day.day)
                                                .font(SBFont.label(12))
                                                .foregroundStyle(selectedDay == day.day ? .white : SBColor.textSecondary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(
                                                    selectedDay == day.day
                                                    ? AnyShapeStyle(LinearGradient.skillBits)
                                                    : AnyShapeStyle(SBColor.background)
                                                )
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(SBColor.purple)
                                Text("No dia \(selectedBar.day), você estudou \(selectedBar.value) minutos.")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textSecondary)
                            }
                            .padding(10)
                            .background(SBColor.purpleBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }

                    SBSectionHeader("Cursos para subir de nível")
                    ForEach(viewModel.courses.filter { $0.progress > 0 }) { course in
                        SBCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .overlay(Text(course.emoji).font(.system(size: 22)))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(course.title)
                                            .font(SBFont.label(14))
                                        Text("\(course.progress)% concluído")
                                            .font(SBFont.body(12))
                                            .foregroundStyle(SBColor.textTertiary)
                                    }
                                    Spacer()
                                    Text("+\(max(10, course.progress / 2)) XP")
                                        .font(SBFont.label(11))
                                        .foregroundStyle(SBColor.success)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(SBColor.successBg)
                                        .clipShape(Capsule())
                                }
                                SBProgressBar(value: Double(course.progress) / 100)
                            }
                        }
                    }

                    SBSectionHeader("Conquistas")
                    ForEach(viewModel.progress.badges) { badge in
                        Group {
                            if badge.unlocked {
                                SBCard {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(LinearGradient.skillBits)
                                            .frame(width: 42, height: 42)
                                            .overlay(Image(systemName: "trophy.fill").foregroundStyle(.white))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(badge.name)
                                                .font(SBFont.label(14))
                                            Text("Desbloqueado • +40 XP")
                                                .font(SBFont.body(12))
                                                .foregroundStyle(SBColor.textTertiary)
                                        }
                                        Spacer()
                                        Text("ATIVO")
                                            .font(SBFont.label(10))
                                            .foregroundStyle(SBColor.success)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(SBColor.successBg)
                                            .clipShape(Capsule())
                                    }
                                }
                            } else {
                                SBCard {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                                            .foregroundStyle(SBColor.border)
                                            .frame(width: 42, height: 42)
                                            .overlay(Image(systemName: "lock.fill").foregroundStyle(SBColor.textTertiary))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(badge.name)
                                                .font(SBFont.label(14))
                                            Text("Bloqueado • complete 2 módulos")
                                                .font(SBFont.body(12))
                                                .foregroundStyle(SBColor.textTertiary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    SBCard {
                        HStack {
                            Image(systemName: "flag.checkered")
                                .foregroundStyle(SBColor.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Meta da semana")
                                    .font(SBFont.label(13))
                                Text("Estudar 140 min • faltam \(max(0, 140 - weekTotal)) min")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textSecondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            viewModel.load()
            animateIn = true
        }
    }

    private func gamifiedStat(icon: String, value: String, label: String, tint: Color, bg: Color) -> some View {
        SBCard {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bg)
                    .frame(width: 34, height: 34)
                    .overlay(Image(systemName: icon).foregroundStyle(tint))
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(SBFont.title(18))
                        .foregroundStyle(SBColor.textPrimary)
                    Text(label)
                        .font(SBFont.body(11))
                        .foregroundStyle(SBColor.textTertiary)
                }
                Spacer()
            }
        }
    }
}
