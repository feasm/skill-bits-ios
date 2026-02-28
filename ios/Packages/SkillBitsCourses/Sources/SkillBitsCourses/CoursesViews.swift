import SwiftUI
import SkillBitsCore
import SkillBitsDesignSystem

public final class CoursesViewModel: ObservableObject {
    @Published public var courses: [Course] = []
    @Published public var search = ""
    @Published public var selectedFilter = "Todos"
    @Published public var isLoading = false
    @Published public var loadError = false
    @Published public var onboardingReason: String?
    private var hasLoadedOnce = false
    private var lastLoadedAt: Date?
    private let refreshInterval: TimeInterval = 300
    private let repo: CoursesRepository

    public init(repo: CoursesRepository, onboardingReason: String? = nil) {
        self.repo = repo
        self.onboardingReason = onboardingReason
    }

    public var recommendedCourse: Course? {
        guard let reason = onboardingReason else { return nil }
        let targetId: String
        switch reason {
        case "universidade", "curiosidade":
            targetId = "c2"
        case "carreira":
            targetId = "c1"
        case "evolucao":
            targetId = "c3"
        default:
            return nil
        }
        return courses.first { $0.id == targetId }
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

    public func load(force: Bool = false) async {
        guard force || shouldFetch else { return }
        await MainActor.run {
            isLoading = true
            loadError = false
        }
        do {
            let data = try await repo.fetchCourses()
            await MainActor.run {
                self.courses = data
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

    public func load(force: Bool = false) {
        Task { await load(force: force) as Void }
    }

    public func invalidateCache() {
        lastLoadedAt = nil
    }

    private var shouldFetch: Bool {
        guard hasLoadedOnce else { return true }
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) >= refreshInterval
    }

    public var filters: [String] {
        let categories = Set(courses.map(\.category))
        return ["Todos"] + categories.sorted()
    }

    public var filtered: [Course] {
        courses.filter { course in
            let searchMatch = search.isEmpty ||
                course.title.localizedCaseInsensitiveContains(search) ||
                course.shortDesc.localizedCaseInsensitiveContains(search)
            let filterMatch = selectedFilter == "Todos" || course.category == selectedFilter
            return searchMatch && filterMatch
        }
    }
}

public struct CoursesView: View {
    @ObservedObject var viewModel: CoursesViewModel
    let openCourse: (Course) -> Void
    @State private var animateIn = false

    public init(viewModel: CoursesViewModel, openCourse: @escaping (Course) -> Void) {
        self.viewModel = viewModel
        self.openCourse = openCourse
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            if viewModel.isInitialLoad {
                CoursesSkeletonView()
                    .transition(.opacity)
            } else if viewModel.shouldShowBlockingError {
                SBErrorState(message: "Nao foi possivel carregar os cursos.") {
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
                                    Text("Falha ao atualizar cursos. Exibindo os dados anteriores.")
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

                        Text("Cursos")
                            .font(SBFont.display(30))
                            .tracking(-0.5)

                        HStack(spacing: 10) {
                            SBTextField("Buscar cursos", icon: "magnifyingglass", text: $viewModel.search)
                            SBIconButton(icon: "slider.horizontal.3") {}
                        }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.filters, id: \.self) { filter in
                                Button {
                                    withAnimation(SBMotion.quick) {
                                        viewModel.selectedFilter = filter
                                    }
                                    SBHaptics.selection()
                                } label: {
                                    SBFilterPill(filter, active: viewModel.selectedFilter == filter)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    SBGradientBanner {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .bold))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Desbloqueie o Premium")
                                    .font(SBFont.label(15))
                                Text("Acesso completo a trilhas avancadas")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            Spacer()
                        }
                    }

                    if let recommended = viewModel.recommendedCourse {
                        recommendedCard(recommended)
                    }

                    ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, course in
                        Button {
                            openCourse(course)
                        } label: {
                            courseCard(course)
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 14)
                                .animation(SBMotion.medium.delay(Double(idx) * SBMotion.staggerDelay), value: animateIn)
                        }
                        .buttonStyle(SBPressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.load(force: true) as Void
                }
            }
        }
        .animation(SBMotion.medium, value: viewModel.isInitialLoad)
        .animation(SBMotion.medium, value: viewModel.isRefreshing)
        .animation(SBMotion.medium, value: viewModel.shouldShowInlineError)
        .onAppear {
            if viewModel.courses.isEmpty { viewModel.load() }
            animateIn = true
        }
    }

    private func courseCard(_ course: Course) -> some View {
        SBCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(Text(course.emoji))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(course.title)
                            .font(SBFont.title(16))
                            .foregroundStyle(SBColor.textPrimary)
                        Text(course.shortDesc)
                            .font(SBFont.body(13))
                            .foregroundStyle(SBColor.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    SBBadge(
                        badgeText(for: course),
                        kind: badgeKind(for: course)
                    )
                }

                HStack(spacing: 6) {
                    tag(course.category)
                    tag(course.level)
                }

                if course.progress > 0 {
                    SBProgressBar(value: Double(course.progress) / 100)
                }

                HStack {
                    Label(course.totalDuration, systemImage: "clock")
                    Spacer()
                    Label("\(course.modules.count) modulos", systemImage: "person.2")
                    Spacer()
                    SBBadge(course.level, kind: .level(course.level))
                }
                .font(SBFont.body(11))
                .foregroundStyle(SBColor.textTertiary)
            }
        }
    }

    private func badgeText(for course: Course) -> String {
        switch course.effectiveAccess {
        case .free: "Gratis"
        case .partial: "Parcial"
        case .premium: "Premium"
        }
    }

    private func badgeKind(for course: Course) -> SBBadge.Kind {
        switch course.effectiveAccess {
        case .free: .free
        case .partial: .partial
        case .premium: .premium
        }
    }

    private func recommendedCard(_ course: Course) -> some View {
        Button {
            openCourse(course)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("Recomendado para voce")
                        .font(SBFont.label(12))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)

                HStack(spacing: 12) {
                    Text(course.emoji)
                        .font(.system(size: 28))
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(course.title)
                            .font(SBFont.title(16))
                            .foregroundStyle(.white)
                        Text(recommendedSubtitle)
                            .font(SBFont.body(12))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: course.color1), Color(hex: course.color2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
        }
        .buttonStyle(SBPressableButtonStyle())
    }

    private var recommendedSubtitle: String {
        switch viewModel.onboardingReason {
        case "carreira":
            return "Ideal para quem quer migrar de carreira"
        case "universidade":
            return "Perfeito para complementar seus estudos"
        case "curiosidade":
            return "Uma otima base para comecar"
        case "evolucao":
            return "Avance suas habilidades tecnicas"
        default:
            return "Comece por aqui"
        }
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(SBFont.label(11))
            .foregroundStyle(SBColor.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(SBColor.background)
            .overlay(RoundedRectangle(cornerRadius: SBRadius.tag).stroke(SBColor.border))
            .clipShape(RoundedRectangle(cornerRadius: SBRadius.tag))
    }
}

private struct CoursesSkeletonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Cursos")
                    .font(SBFont.display(30))
                    .tracking(-0.5)

                SBSkeletonBlock(height: 52, cornerRadius: SBRadius.input)

                HStack(spacing: 8) {
                    SBSkeletonBlock(width: 74, height: 30, cornerRadius: SBRadius.pill)
                    SBSkeletonBlock(width: 88, height: 30, cornerRadius: SBRadius.pill)
                    SBSkeletonBlock(width: 96, height: 30, cornerRadius: SBRadius.pill)
                }

                SBSkeletonBlock(height: 72, cornerRadius: SBRadius.card)
                SBSkeletonBlock(height: 88, cornerRadius: SBRadius.card)
                SBSkeletonCard()
                SBSkeletonCard()
                SBSkeletonCard()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

public struct CourseDetailView: View {
    public let course: Course
    public let openModule: (Module) -> Void
    public let startLesson: (Module, Lesson) -> Void
    public let onClose: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var expandedModules: Set<String> = []

    public init(course: Course, onClose: (() -> Void)? = nil, openModule: @escaping (Module) -> Void, startLesson: @escaping (Module, Lesson) -> Void) {
        self.course = course
        self.onClose = onClose
        self.openModule = openModule
        self.startLesson = startLesson
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color(hex: course.color1), Color(hex: course.color2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                        .frame(height: 220)
                        .overlay(
                            VStack(alignment: .leading, spacing: 10) {
                                Text(course.category.uppercased())
                                    .font(SBFont.label(12))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                                HStack(alignment: .center, spacing: 12) {
                                    Text(course.title)
                                        .font(SBFont.display(26))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    SBGlassCard {
                                        Text(course.emoji)
                                            .font(.system(size: 24))
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                HStack(spacing: 16) {
                                    Label(course.totalDuration, systemImage: "clock.fill")
                                    Label("\(course.modules.count) modulos", systemImage: "book.fill")
                                }
                                .font(SBFont.body(12))
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(20),
                            alignment: .bottomLeading
                        )
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                if let onClose {
                                    onClose()
                                } else {
                                    dismiss()
                                }
                            } label: {
                                SBGlassCard {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                        Spacer()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        SBBadge(course.level, kind: .level(course.level))
                        SBBadge(badgeText, kind: badgeKind)
                    }

                    Text(course.description)
                        .font(SBFont.body(15))
                        .foregroundStyle(SBColor.textSecondary)
                        .lineSpacing(5)

                    if course.progress > 0 {
                        SBCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Seu progresso")
                                        .font(SBFont.label(13))
                                    Spacer()
                                    Text("\(course.progress)%")
                                        .font(SBFont.stat(22))
                                }
                                SBProgressBar(value: Double(course.progress) / 100)
                            }
                        }
                    }

                    SBSectionHeader("Modulos")
                    ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                        moduleAccordion(module, index: index)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            SBCard {
                SBPrimaryButton(
                    course.progress > 0 ? "Continuar curso" : "Iniciar curso",
                    size: .lg,
                    icon: course.progress > 0 ? "arrow.right" : "play.fill"
                ) {
                    if let first = course.modules.first {
                        openModule(first)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(SBColor.surface)
            .sbShadow(.sticky)
        }
        .background(SBColor.background)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var badgeText: String {
        switch course.effectiveAccess {
        case .free: "Gratis"
        case .partial: "Parcial"
        case .premium: "Premium"
        }
    }

    private var badgeKind: SBBadge.Kind {
        switch course.effectiveAccess {
        case .free: .free
        case .partial: .partial
        case .premium: .premium
        }
    }

    @ViewBuilder
    private func moduleAccordion(_ module: Module, index: Int) -> some View {
        let isExpanded = expandedModules.contains(module.id)
        SBCard(padded: false) {
            VStack(spacing: 0) {
                Button {
                    withAnimation(SBMotion.springSmooth) {
                        if isExpanded {
                            expandedModules.remove(module.id)
                        } else {
                            expandedModules.insert(module.id)
                        }
                    }
                    SBHaptics.selection()
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 34, height: 34)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(SBFont.label(14))
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(module.title)
                                .font(SBFont.label(14))
                                .foregroundStyle(SBColor.textPrimary)
                            Text("\(module.lessons.count) aulas · \(module.duration)")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textTertiary)
                        }

                        Spacer()

                        if module.accessTier == .premium {
                            SBBadge("Premium", kind: .premium)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SBColor.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(SBMotion.quick, value: isExpanded)
                    }
                    .padding(14)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Divider().overlay(SBColor.border)
                    VStack(spacing: 0) {
                        ForEach(module.lessons) { lesson in
                            Button {
                                startLesson(module, lesson)
                            } label: {
                                HStack {
                                    Image(systemName: iconForStatus(lesson.status))
                                        .foregroundStyle(colorForStatus(lesson.status))
                                    Text(lesson.title)
                                        .font(SBFont.body(13))
                                        .foregroundStyle(SBColor.textPrimary)
                                    Spacer()
                                }
                                .padding(14)
                            }
                            .buttonStyle(.plain)
                            .disabled(lesson.status == .locked)
                            if lesson.id != module.lessons.last?.id {
                                Divider().overlay(SBColor.border)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func iconForStatus(_ status: LessonStatus) -> String {
        switch status {
        case .completed: "checkmark.circle.fill"
        case .locked: "lock.fill"
        case .inProgress: "play.circle.fill"
        case .available: "circle"
        }
    }

    private func colorForStatus(_ status: LessonStatus) -> Color {
        switch status {
        case .completed: SBColor.success
        case .locked: SBColor.textTertiary
        case .inProgress: SBColor.accent
        case .available: SBColor.textSecondary
        }
    }
}

public struct ModuleDetailView: View {
    public let course: Course
    public let module: Module
    public let startLesson: (Lesson) -> Void
    public let startQuiz: (Bool) -> Void
    public let onClose: (() -> Void)?
    @State private var appeared = false
    @Environment(\.dismiss) private var dismiss

    public init(course: Course, module: Module, onClose: (() -> Void)? = nil, startLesson: @escaping (Lesson) -> Void, startQuiz: @escaping (Bool) -> Void) {
        self.course = course
        self.module = module
        self.onClose = onClose
        self.startLesson = startLesson
        self.startQuiz = startQuiz
    }

    private var completion: Double {
        guard !module.lessons.isEmpty else { return 0 }
        let done = module.lessons.filter { $0.status == .completed }.count
        return Double(done) / Double(module.lessons.count)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SBNavBar(title: module.title, subtitle: "\(course.title) > modulo", onBack: { dismiss() }, onClose: onClose)

                SBCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Progresso")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                                Text("\(Int(completion * 100))%")
                                    .font(SBFont.stat(22))
                            }
                            Spacer()
                            Circle()
                                .fill(LinearGradient.skillBits)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: completion >= 1 ? "trophy.fill" : "list.bullet.rectangle.portrait.fill")
                                        .foregroundStyle(.white)
                                )
                        }
                        SBProgressBar(value: completion)
                        HStack {
                            Text(module.duration)
                            Spacer()
                            Text("\(module.lessons.filter { $0.status == .completed }.count)/\(module.lessons.count) aulas")
                        }
                        .font(SBFont.body(12))
                        .foregroundStyle(SBColor.textTertiary)
                    }
                }

                SBSectionHeader("Aulas")
                ForEach(Array(module.lessons.enumerated()), id: \.element.id) { idx, lesson in
                    Button {
                        startLesson(lesson)
                    } label: {
                        SBCard {
                            HStack {
                                Image(systemName: iconForStatus(lesson.status))
                                    .foregroundStyle(colorForStatus(lesson.status))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title)
                                        .font(SBFont.label(14))
                                        .foregroundStyle(SBColor.textPrimary)
                                    Text(lesson.duration)
                                        .font(SBFont.body(12))
                                        .foregroundStyle(SBColor.textTertiary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(SBColor.textTertiary)
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(SBMotion.medium.delay(Double(idx) * SBMotion.staggerDelay), value: appeared)
                    }
                    .buttonStyle(SBPressableButtonStyle())
                    .disabled(lesson.status == .locked)
                }

                SBCard {
                    Button {
                        startQuiz(false)
                    } label: {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(SBColor.purpleBg)
                                .frame(width: 38, height: 38)
                                .overlay(Image(systemName: module.quizCompleted ? "trophy.fill" : "questionmark.circle.fill").foregroundStyle(SBColor.purple))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(module.quizCompleted ? "Quiz concluido" : "Iniciar quiz")
                                    .font(SBFont.label(14))
                                    .foregroundStyle(SBColor.textPrimary)
                                Text(module.quizCompleted ? "Pontuacao: \(module.quizScore ?? 0)%" : "Teste seus conhecimentos")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(SBColor.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(SBColor.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { appeared = true }
    }

    private func iconForStatus(_ status: LessonStatus) -> String {
        switch status {
        case .completed: "checkmark.circle.fill"
        case .locked: "lock.fill"
        case .inProgress: "play.circle.fill"
        case .available: "circle"
        }
    }

    private func colorForStatus(_ status: LessonStatus) -> Color {
        switch status {
        case .completed: SBColor.success
        case .locked: SBColor.textTertiary
        case .inProgress: SBColor.accent
        case .available: SBColor.textSecondary
        }
    }
}
