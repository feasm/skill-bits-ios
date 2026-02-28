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
    public var weeklyStudy: [WeeklyStudyDay] = []
    public var isLoading = false
    public var loadError = false
    private var hasLoadedOnce = false
    private var lastLoadedAt: Date?
    private let refreshInterval: TimeInterval = 300
    private let repo: ProgressRepository
    private let coursesRepo: CoursesRepository

    public init(repo: ProgressRepository, coursesRepo: CoursesRepository) {
        self.repo = repo
        self.coursesRepo = coursesRepo
    }

    public var isInitialLoad: Bool {
        isLoading && !hasLoadedOnce && progress.xp == 0
    }

    public var shouldShowBlockingError: Bool {
        loadError && !hasLoadedOnce && progress.xp == 0
    }

    public var shouldShowInlineError: Bool {
        loadError && (hasLoadedOnce || progress.xp > 0)
    }

    public var isRefreshing: Bool {
        isLoading && hasLoadedOnce
    }

    public func load(force: Bool = false) {
        guard force || shouldFetch else { return }
        isLoading = true
        loadError = false
        Task {
            do {
                let value = try await repo.fetchProgress()
                let courseData = (try? await coursesRepo.fetchCourses()) ?? []
                let weekData = (try? await repo.fetchWeeklyStudy()) ?? []
                await MainActor.run {
                    self.progress = value
                    self.courses = courseData
                    self.weeklyStudy = weekData
                    self.isLoading = false
                    self.hasLoadedOnce = true
                    self.lastLoadedAt = Date()
                }
            } catch {
                await MainActor.run {
                    self.loadError = true
                    self.isLoading = false
                }
            }
        }
    }

    public func invalidateCache() {
        lastLoadedAt = nil
    }

    private var shouldFetch: Bool {
        guard hasLoadedOnce else { return true }
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) >= refreshInterval
    }
}

public struct ProgressScreenView: View {
    @Bindable var viewModel: ProgressViewModel
    @State private var animateIn = false
    @State private var selectedDate: String = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }()

    private struct WeekBar: Identifiable {
        let id: String
        let day: String
        let value: Int
    }

    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let weekdayNames = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"]

    private static func dayLabel(from dateString: String) -> String {
        guard let date = dateParser.date(from: dateString) else { return "?" }
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekdayNames[weekday - 1]
    }

    private var weeklyBars: [WeekBar] {
        viewModel.weeklyStudy.map { entry in
            WeekBar(
                id: entry.studyDate,
                day: Self.dayLabel(from: entry.studyDate),
                value: entry.minutes
            )
        }
    }

    private var selectedBar: WeekBar? {
        weeklyBars.first(where: { $0.id == selectedDate }) ?? weeklyBars.last
    }

    private var weekTotal: Int {
        weeklyBars.reduce(0) { $0 + $1.value }
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

            if viewModel.isInitialLoad {
                ProgressSkeletonView()
                    .transition(.opacity)
            } else if viewModel.shouldShowBlockingError {
                SBErrorState(message: "Nao foi possivel carregar seu progresso.") {
                    viewModel.load(force: true)
                }
                .transition(.opacity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if viewModel.isRefreshing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }

                        if viewModel.shouldShowInlineError {
                            SBCard {
                                HStack(spacing: 10) {
                                    Image(systemName: "wifi.exclamationmark")
                                        .foregroundStyle(SBColor.error)
                                    Text("Nao foi possivel atualizar seu progresso agora.")
                                        .font(SBFont.body(12))
                                        .foregroundStyle(SBColor.textSecondary)
                                    Spacer()
                                    Button("Tentar") { viewModel.load(force: true) }
                                        .font(SBFont.label(12))
                                        .buttonStyle(.plain)
                                        .foregroundStyle(SBColor.accent)
                                }
                            }
                            .transition(.opacity)
                        }

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
                                if let selected = selectedBar {
                                    Text("\(selected.day) • \(selected.value) min")
                                        .font(SBFont.body(12))
                                        .foregroundStyle(SBColor.textTertiary)
                                }
                            }

                            Chart(weeklyBars) { bar in
                                BarMark(
                                    x: .value("Dia", bar.day),
                                    y: .value("Minutos", animateIn ? bar.value : 0)
                                )
                                .foregroundStyle(
                                    bar.id == selectedDate
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

                            HStack(spacing: 8) {
                                ForEach(weeklyBars) { bar in
                                    Button {
                                        withAnimation(SBMotion.quick) {
                                            selectedDate = bar.id
                                        }
                                    } label: {
                                        Text(bar.day)
                                            .font(SBFont.label(12))
                                            .foregroundStyle(bar.id == selectedDate ? .white : SBColor.textSecondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                bar.id == selectedDate
                                                ? AnyShapeStyle(LinearGradient.skillBits)
                                                : AnyShapeStyle(SBColor.background)
                                            )
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            if let selected = selectedBar {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(SBColor.purple)
                                    Text("No dia \(selected.day), voce estudou \(selected.value) minutos.")
                                        .font(SBFont.body(12))
                                        .foregroundStyle(SBColor.textSecondary)
                                }
                                .padding(10)
                                .background(SBColor.purpleBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
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
                .refreshable { viewModel.load(force: true) }
            }
        }
        .animation(SBMotion.medium, value: viewModel.isInitialLoad)
        .animation(SBMotion.medium, value: viewModel.isRefreshing)
        .animation(SBMotion.medium, value: viewModel.shouldShowInlineError)
        .onAppear {
            if viewModel.progress.xp == 0 { viewModel.load() }
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

private struct ProgressSkeletonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        SBSkeletonBlock(width: 140, height: 26, cornerRadius: 8)
                        SBSkeletonBlock(width: 250, height: 14, cornerRadius: 7)
                    }
                    Spacer()
                    SBSkeletonBlock(width: 52, height: 52, cornerRadius: 26)
                }

                SBSkeletonBlock(height: 124, cornerRadius: SBRadius.card)

                SBSkeletonBlock(width: 96, height: 12, cornerRadius: 6)
                SBCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            SBSkeletonBlock(width: 88, height: 14, cornerRadius: 6)
                            Spacer()
                            SBSkeletonBlock(width: 76, height: 16, cornerRadius: 8)
                        }
                        SBSkeletonBlock(height: 8, cornerRadius: 4)
                        SBSkeletonBlock(width: 180, height: 12, cornerRadius: 6)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(0..<4, id: \.self) { _ in
                        SBCard {
                            HStack(spacing: 8) {
                                SBSkeletonBlock(width: 34, height: 34, cornerRadius: 10)
                                VStack(alignment: .leading, spacing: 4) {
                                    SBSkeletonBlock(width: 50, height: 16, cornerRadius: 6)
                                    SBSkeletonBlock(width: 70, height: 11, cornerRadius: 5)
                                }
                                Spacer()
                            }
                        }
                    }
                }

                SBSkeletonBlock(width: 130, height: 12, cornerRadius: 6)
                SBCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            SBSkeletonBlock(width: 100, height: 14, cornerRadius: 6)
                            Spacer()
                            SBSkeletonBlock(width: 80, height: 12, cornerRadius: 6)
                        }
                        HStack(alignment: .bottom, spacing: 6) {
                            ForEach(0..<7, id: \.self) { i in
                                SBSkeletonBlock(
                                    height: CGFloat([50, 70, 90, 55, 80, 100, 65][i]),
                                    cornerRadius: 4
                                )
                            }
                        }
                        .frame(height: 100)
                        HStack(spacing: 8) {
                            ForEach(0..<7, id: \.self) { _ in
                                SBSkeletonBlock(height: 28, cornerRadius: 14)
                            }
                        }
                        SBSkeletonBlock(height: 36, cornerRadius: 12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}
