import SwiftUI
import SkillBitsCore
import SkillBitsDesignSystem
import SkillBitsGamification

public final class HomeViewModel: ObservableObject {
    @Published public var progress = UserProgress(xp: 0, streakDays: 0, dailyGoal: .minutes15, studiedMinutesToday: 0, badges: [])
    @Published public var courses: [Course] = []
    @Published public var userName: String
    @Published public var isLoading = false
    @Published public var loadError = false
    private var hasLoadedOnce = false
    private var lastLoadedAt: Date?
    private let refreshInterval: TimeInterval = 300
    private let repo: ProgressRepository
    private let coursesRepo: CoursesRepository

    public init(repo: ProgressRepository, coursesRepo: CoursesRepository, userName: String = "Estudante") {
        self.repo = repo
        self.coursesRepo = coursesRepo
        self.userName = userName
    }

    public var isInitialLoad: Bool {
        isLoading && !hasLoadedOnce && courses.isEmpty
    }

    public var shouldShowBlockingError: Bool {
        loadError && !hasLoadedOnce && courses.isEmpty
    }

    public var shouldShowInlineError: Bool {
        loadError && (hasLoadedOnce || !courses.isEmpty)
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
                await MainActor.run {
                    self.progress = value
                    self.courses = courseData
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
    @ObservedObject var viewModel: HomeViewModel
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

            if viewModel.isInitialLoad {
                HomeSkeletonView()
                    .transition(.opacity)
            } else if viewModel.shouldShowBlockingError {
                SBErrorState(message: "Nao foi possivel carregar seus dados de estudo.") {
                    viewModel.load(force: true)
                }
                .transition(.opacity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
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
                                    Text("Nao foi possivel atualizar os dados agora.")
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
                .refreshable { viewModel.load(force: true) }
            }
        }
        .animation(SBMotion.medium, value: viewModel.isInitialLoad)
        .animation(SBMotion.medium, value: viewModel.isRefreshing)
        .animation(SBMotion.medium, value: viewModel.shouldShowInlineError)
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

private struct HomeSkeletonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SBSkeletonBlock(width: 170, height: 24, cornerRadius: 8)
                    SBSkeletonBlock(width: 210, height: 14, cornerRadius: 7)
                }

                SBSkeletonBlock(height: 92, cornerRadius: SBRadius.card)

                SBCard {
                    VStack(alignment: .leading, spacing: 10) {
                        SBSkeletonBlock(width: 86, height: 12, cornerRadius: 6)
                        HStack {
                            SBSkeletonBlock(width: 110, height: 20, cornerRadius: 8)
                            Spacer()
                            SBSkeletonBlock(width: 88, height: 12, cornerRadius: 6)
                        }
                        SBSkeletonBlock(height: 8, cornerRadius: 4)
                    }
                }

                SBSkeletonBlock(width: 140, height: 12, cornerRadius: 6)
                SBSkeletonCard()
                SBSkeletonCard()

                SBSkeletonBlock(width: 180, height: 12, cornerRadius: 6)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { _ in
                            SBCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    SBSkeletonBlock(width: 144, height: 62, cornerRadius: 12)
                                    SBSkeletonBlock(width: 120, height: 13, cornerRadius: 6)
                                    SBSkeletonBlock(width: 64, height: 20, cornerRadius: 10)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

private struct MyStudySkeletonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SBSpacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    SBSkeletonBlock(width: 160, height: 28, cornerRadius: 8)
                    SBSkeletonBlock(width: 240, height: 14, cornerRadius: 7)
                }

                SBSkeletonBlock(height: 190, cornerRadius: SBRadius.card)

                SBSkeletonBlock(width: 120, height: 12, cornerRadius: 6)
                SBSkeletonCard()

                SBSkeletonBlock(width: 180, height: 12, cornerRadius: 6)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SBSpacing.md) {
                        ForEach(0..<3, id: \.self) { _ in
                            SBCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    SBSkeletonBlock(width: 144, height: 62, cornerRadius: 12)
                                    SBSkeletonBlock(width: 120, height: 13, cornerRadius: 6)
                                    SBSkeletonBlock(width: 64, height: 20, cornerRadius: 10)
                                }
                            }
                        }
                    }
                }

                SBSkeletonBlock(width: 110, height: 12, cornerRadius: 6)
                SBCard {
                    VStack(spacing: SBSpacing.md) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: SBSpacing.md) {
                                SBSkeletonBlock(width: 32, height: 32, cornerRadius: 8)
                                SBSkeletonBlock(width: 150, height: 13, cornerRadius: 6)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, SBSpacing.xl)
            .padding(.vertical, SBSpacing.lg)
        }
    }
}

public struct MyStudyView: View {
    public let courses: [Course]
    public let progress: UserProgress?
    public let isLoading: Bool
    public let loadError: Bool
    public let openCourse: (Course) -> Void
    public let onExploreCourses: () -> Void
    public let onRetry: () -> Void
    @State private var appeared = false

    public init(
        courses: [Course],
        progress: UserProgress?,
        isLoading: Bool,
        loadError: Bool,
        openCourse: @escaping (Course) -> Void,
        onExploreCourses: @escaping () -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.courses = courses
        self.progress = progress
        self.isLoading = isLoading
        self.loadError = loadError
        self.openCourse = openCourse
        self.onExploreCourses = onExploreCourses
        self.onRetry = onRetry
    }

    // MARK: - Computed

    private var inProgressCourses: [Course] {
        courses.filter { $0.progress > 0 }.sorted { $0.progress > $1.progress }
    }

    private var recommendedCourses: [Course] {
        courses.filter { $0.progress == 0 }.prefix(3).map { $0 }
    }

    private var continueCourse: Course? {
        inProgressCourses.first
    }

    private var hasProgress: Bool {
        !inProgressCourses.isEmpty
    }

    private var completedQuizCount: Int {
        courses.flatMap(\.modules).filter(\.quizCompleted).count
    }

    private func nextLesson(for course: Course) -> Lesson? {
        for module in course.modules {
            if let target = module.lessons.first(where: { $0.status == .inProgress || $0.status == .available }) {
                return target
            }
        }
        return nil
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            if isLoading {
                MyStudySkeletonView()
                    .transition(.opacity)
            } else if loadError {
                SBErrorState(message: "Nao foi possivel carregar seus estudos.") {
                    onRetry()
                }
                .transition(.opacity)
            } else if hasProgress {
                studyHubContent
                    .transition(.opacity)
            } else {
                emptyStateView
                    .transition(.opacity)
            }
        }
        .animation(SBMotion.medium, value: isLoading)
        .animation(SBMotion.medium, value: loadError)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: SBSpacing.xl) {
                studyHeader(subtitle: "Seu plano de aprendizado comeca aqui")

                SBCard {
                    VStack(spacing: SBSpacing.lg) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundStyle(SBColor.accent)

                        Text("Comece com um curso curto hoje")
                            .font(SBFont.title(17))
                            .multilineTextAlignment(.center)

                        Text("Em 15 minutos voce ja destrava seu primeiro progresso.")
                            .font(SBFont.body(14))
                            .foregroundStyle(SBColor.textSecondary)
                            .multilineTextAlignment(.center)

                        SBPrimaryButton("Explorar cursos", icon: "arrow.right") {
                            SBHaptics.selection()
                            onExploreCourses()
                        }
                        .accessibilityHint("Abre o catalogo de cursos disponiveis")
                    }
                }

                if !recommendedCourses.isEmpty {
                    VStack(alignment: .leading, spacing: SBSpacing.md) {
                        SBSectionHeader("Recomendados para iniciantes")
                        ForEach(recommendedCourses) { course in
                            Button {
                                SBHaptics.selection()
                                openCourse(course)
                            } label: {
                                recommendedRow(course: course)
                            }
                            .buttonStyle(SBPressableButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, SBSpacing.xl)
            .padding(.vertical, SBSpacing.lg)
        }
    }

    // MARK: - Study Hub

    private var studyHubContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SBSpacing.lg) {
                studyHeader(subtitle: "Continue do ponto onde voce parou")

                if let course = continueCourse {
                    continueNowCard(course: course)
                }

                if inProgressCourses.count > 1 {
                    SBSectionHeader("Em andamento")
                    ForEach(inProgressCourses.dropFirst()) { course in
                        Button {
                            SBHaptics.selection()
                            openCourse(course)
                        } label: {
                            inProgressRow(course: course)
                        }
                        .buttonStyle(SBPressableButtonStyle())
                    }
                }

                if !recommendedCourses.isEmpty {
                    SBSectionHeader("Proximas recomendacoes")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: SBSpacing.md) {
                            ForEach(recommendedCourses) { course in
                                Button {
                                    SBHaptics.selection()
                                    openCourse(course)
                                } label: {
                                    recommendedHorizontalCard(course: course)
                                }
                                .buttonStyle(SBPressableButtonStyle())
                            }
                        }
                    }
                }

                consistencySection
            }
            .padding(.horizontal, SBSpacing.xl)
            .padding(.vertical, SBSpacing.lg)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(SBMotion.medium, value: appeared)
        }
        .onAppear { appeared = true }
    }

    // MARK: - Shared Header

    private func studyHeader(subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Meus estudos")
                .font(SBFont.display(28))
                .foregroundStyle(SBColor.textPrimary)
            Text(subtitle)
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Continuar Agora

    private func continueNowCard(course: Course) -> some View {
        let lesson = nextLesson(for: course)
        return SBGradientBanner {
            VStack(alignment: .leading, spacing: SBSpacing.md) {
                HStack(spacing: SBSpacing.md) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(Text(course.emoji).font(.system(size: 24)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CONTINUAR AGORA")
                            .font(SBFont.label(11))
                            .tracking(0.4)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(course.title)
                            .font(SBFont.title(17))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }

                if let lesson {
                    Text(lesson.title)
                        .font(SBFont.body(13))
                        .foregroundStyle(.white.opacity(0.84))
                }

                HStack(spacing: SBSpacing.sm) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.white.opacity(0.2))
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.white)
                                .frame(width: geo.size.width * min(max(Double(course.progress) / 100, 0), 1))
                                .animation(.easeOut(duration: 0.4), value: course.progress)
                        }
                    }
                    .frame(height: 6)
                    Text("\(course.progress)%")
                        .font(SBFont.label(12))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Button {
                    SBHaptics.selection()
                    openCourse(course)
                } label: {
                    HStack(spacing: 8) {
                        Text("Continuar")
                            .font(SBFont.label(14))
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(SBColor.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
                }
                .buttonStyle(SBPressableButtonStyle())
                .accessibilityLabel("Continuar curso \(course.title)")
                .accessibilityHint("Abre o curso para continuar estudando")
            }
        }
    }

    // MARK: - Em Andamento Row

    private func inProgressRow(course: Course) -> some View {
        let lesson = nextLesson(for: course)
        return SBCard {
            VStack(alignment: .leading, spacing: SBSpacing.sm) {
                HStack(alignment: .top, spacing: SBSpacing.md) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .overlay(Text(course.emoji).font(.system(size: 20)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(course.title)
                            .font(SBFont.label(14))
                            .foregroundStyle(SBColor.textPrimary)
                        Text(lesson?.title ?? "Continue de onde parou")
                            .font(SBFont.body(12))
                            .foregroundStyle(SBColor.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(course.progress)%")
                        .font(SBFont.label(12))
                        .foregroundStyle(SBColor.accent)
                }
                SBProgressBar(value: Double(course.progress) / 100)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(course.title), \(course.progress)% concluido")
    }

    // MARK: - Recommended Row (empty state)

    private func recommendedRow(course: Course) -> some View {
        SBCard {
            HStack(spacing: SBSpacing.md) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: course.color1), Color(hex: course.color2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                    .overlay(Text(course.emoji).font(.system(size: 20)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(course.title)
                        .font(SBFont.label(14))
                        .foregroundStyle(SBColor.textPrimary)
                    Text(course.shortDesc)
                        .font(SBFont.body(12))
                        .foregroundStyle(SBColor.textTertiary)
                        .lineLimit(1)
                }
                Spacer()
                SBBadge(course.accessTier == .free ? "Gratis" : "Premium", kind: course.accessTier == .free ? .free : .premium)
            }
        }
    }

    // MARK: - Recommended Horizontal Card (study hub)

    private func recommendedHorizontalCard(course: Course) -> some View {
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

    // MARK: - Consistencia

    @ViewBuilder
    private var consistencySection: some View {
        SBSectionHeader("Consistencia")
        SBCard {
            VStack(spacing: SBSpacing.md) {
                consistencyRow(
                    icon: "clock.fill",
                    title: "\(progress?.studiedMinutesToday ?? 0) minutos hoje",
                    tint: SBColor.accent
                )
                Divider()
                consistencyRow(
                    icon: "flame.fill",
                    title: "\(progress?.streakDays ?? 0) dias de sequencia",
                    tint: SBColor.warning
                )
                Divider()
                consistencyRow(
                    icon: "checkmark.seal.fill",
                    title: "\(completedQuizCount) quizzes concluidos",
                    tint: SBColor.success
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Resumo de consistencia")
    }

    private func consistencyRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: SBSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .font(SBFont.label(13))
                .foregroundStyle(SBColor.textPrimary)
            Spacer()
        }
    }
}
