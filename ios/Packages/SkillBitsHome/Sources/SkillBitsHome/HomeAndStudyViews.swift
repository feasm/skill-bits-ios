import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem
import SkillBitsGamification

@Observable
public final class HomeViewModel {
    public var progress = UserProgress(xp: 0, streakDays: 0, dailyGoal: .minutes15, studiedMinutesToday: 0, badges: [])
    public var courses: [Course] = []
    public var userName: String
    public var isLoading = false
    public var loadError = false
    private let repo: ProgressRepository
    private let coursesRepo: CoursesRepository

    public init(repo: ProgressRepository, coursesRepo: CoursesRepository, userName: String = "Estudante") {
        self.repo = repo
        self.coursesRepo = coursesRepo
        self.userName = userName
    }

    public func load() {
        isLoading = true
        loadError = false
        Task {
            do {
                let value = try await repo.fetchProgress()
                let courseData = (try? await coursesRepo.fetchCourses()) ?? []
                await MainActor.run {
                    self.progress = value
                    self.courses = courseData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.loadError = true
                    self.isLoading = false
                }
            }
        }
    }

    public var inProgressCourses: [Course] {
        courses.filter { $0.progress > 0 }.sorted { $0.progress > $1.progress }
    }

    public var recommendedCourses: [Course] {
        courses.filter { $0.progress == 0 }.prefix(3).map { $0 }
    }

    public func nextLesson(for course: Course) -> Lesson? {
        for module in course.modules {
            if let target = module.lessons.first(where: { $0.status == .inProgress || $0.status == .available }) {
                return target
            }
        }
        return nil
    }
}

public struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    public let openCourse: (Course) -> Void
    public let openNextLesson: (Course, Lesson) -> Void
    @State private var appeared = false

    public init(
        viewModel: HomeViewModel,
        openCourse: @escaping (Course) -> Void,
        openNextLesson: @escaping (Course, Lesson) -> Void
    ) {
        self.viewModel = viewModel
        self.openCourse = openCourse
        self.openNextLesson = openNextLesson
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.courses.isEmpty {
                SBLoadingState("Carregando seus dados...")
            } else if viewModel.loadError && viewModel.courses.isEmpty {
                SBErrorState(message: "Nao foi possivel carregar seus dados de estudo.") {
                    viewModel.load()
                }
            } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ola, \(viewModel.userName)")
                            .font(SBFont.title(24))
                            .foregroundStyle(SBColor.textPrimary)
                        Text("Vamos manter o ritmo hoje")
                            .font(SBFont.body(14))
                            .foregroundStyle(SBColor.textSecondary)
                    }

                    SBGradientBanner {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white.opacity(0.2))
                                .frame(width: 52, height: 52)
                                .overlay(Text("🔥").font(.system(size: 28)))
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    SBAnimatedCounter(target: viewModel.progress.streakDays, font: SBFont.stat(22), color: .white)
                                    Text("dias seguidos!")
                                        .font(SBFont.label(20))
                                        .foregroundStyle(.white)
                                }
                                Text("Voce esta construindo consistencia diaria")
                                    .font(SBFont.body(13))
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                            Spacer()
                        }
                    }

                    SBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SBSectionHeader("Meta diaria")
                            HStack {
                                Text("\(viewModel.progress.studiedMinutesToday)/\(viewModel.progress.dailyGoal.rawValue) min")
                                    .font(SBFont.stat(22))
                                Spacer()
                                Text("Faltam \(max(0, viewModel.progress.dailyGoal.rawValue - viewModel.progress.studiedMinutesToday)) min")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                            }
                            SBProgressBar(value: min(1, Double(viewModel.progress.studiedMinutesToday) / Double(viewModel.progress.dailyGoal.rawValue)))
                        }
                    }

                    SBSectionHeader("Continuar estudando")
                    if viewModel.inProgressCourses.isEmpty {
                        SBCard {
                            Text("Inicie um curso para acompanhar seu progresso aqui.")
                                .font(SBFont.body(13))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.inProgressCourses) { course in
                                Button {
                                    SBHaptics.selection()
                                    openCourse(course)
                                } label: {
                                    homeCourseRow(course: course)
                                }
                                .buttonStyle(SBPressableButtonStyle())
                            }
                        }
                    }

                    SBSectionHeader("Recomendados para voce")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.recommendedCourses) { course in
                                Button {
                                    SBHaptics.selection()
                                    openCourse(course)
                                } label: {
                                    recommendedCard(course: course)
                                }
                                .buttonStyle(SBPressableButtonStyle())
                            }
                        }
                    }

                    SBSectionHeader("Atividade recente")
                    SBCard {
                        VStack(spacing: 12) {
                            activityRow(icon: "clock.fill", title: "\(viewModel.progress.studiedMinutesToday) minutos estudados", subtitle: "Hoje")
                            activityRow(icon: "flame.fill", title: "Sequencia de \(viewModel.progress.streakDays) dias", subtitle: "Meta em andamento")
                            activityRow(icon: "star.fill", title: "\(viewModel.progress.badges.filter { $0.unlocked }.count) badges desbloqueadas", subtitle: "Continue para liberar mais")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(SBMotion.medium, value: appeared)
            }
            .refreshable { viewModel.load() }
            }
        }
        .onAppear {
            if viewModel.courses.isEmpty { viewModel.load() }
            appeared = true
        }
    }

    private func homeCourseRow(course: Course) -> some View {
        let nextLesson = viewModel.nextLesson(for: course)
        return SBCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay(Text(course.emoji).font(.system(size: 22)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(course.title)
                            .font(SBFont.label(14))
                            .foregroundStyle(SBColor.textPrimary)
                        Text(nextLesson?.title ?? "Continue de onde parou")
                            .font(SBFont.body(12))
                            .foregroundStyle(SBColor.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer()
                    if let nextLesson {
                        Button {
                            SBHaptics.selection()
                            openNextLesson(course, nextLesson)
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                SBProgressBar(value: Double(course.progress) / 100)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(course.title), \(course.progress)% concluido")
    }

    private func recommendedCard(course: Course) -> some View {
        SBCard {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: course.color1), Color(hex: course.color2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 62)
                    .overlay(Text(course.emoji).font(.system(size: 30)))
                Text(course.title)
                    .font(SBFont.label(13))
                    .foregroundStyle(SBColor.textPrimary)
                    .lineLimit(2)
                SBBadge(course.accessTier == .free ? "Gratis" : "Premium", kind: course.accessTier == .free ? .free : .premium)
            }
            .frame(width: 176, alignment: .leading)
        }
    }

    private func activityRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(SBColor.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SBFont.label(13))
                Text(subtitle)
                    .font(SBFont.body(12))
                    .foregroundStyle(SBColor.textTertiary)
            }
            Spacer()
        }
    }
}

public struct MyStudyView: View {
    public let courses: [Course]
    public let openCourse: (Course) -> Void

    public init(courses: [Course], openCourse: @escaping (Course) -> Void) {
        self.courses = courses
        self.openCourse = openCourse
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Meu estudo")
                        .font(SBFont.display(28))
                        .padding(.bottom, 4)
                    ForEach(courses.filter { $0.progress > 0 }) { course in
                        Button {
                            openCourse(course)
                        } label: {
                            SBCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(course.title)
                                            .font(SBFont.label(15))
                                            .foregroundStyle(SBColor.textPrimary)
                                        Spacer()
                                        Text("\(course.progress)%")
                                            .font(SBFont.label(12))
                                            .foregroundStyle(SBColor.accent)
                                    }
                                    Text(course.shortDesc)
                                        .font(SBFont.body(13))
                                        .foregroundStyle(SBColor.textSecondary)
                                    SBProgressBar(value: Double(course.progress) / 100)
                                }
                            }
                        }
                        .buttonStyle(SBPressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }
}
