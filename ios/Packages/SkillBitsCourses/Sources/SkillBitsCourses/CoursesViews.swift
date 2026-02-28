import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem

@Observable
public final class CoursesViewModel {
    public var courses: [Course] = []
    public var search = ""
    public var selectedFilter = "Todos"
    private let repo: CoursesRepository

    public init(repo: CoursesRepository) { self.repo = repo }

    public func load() async {
        let data = (try? await repo.fetchCourses()) ?? []
        await MainActor.run { self.courses = data }
    }

    public func load() {
        Task { await load() }
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
    @Bindable var viewModel: CoursesViewModel
    let openCourse: (Course) -> Void
    @State private var animateIn = false

    public init(viewModel: CoursesViewModel, openCourse: @escaping (Course) -> Void) {
        self.viewModel = viewModel
        self.openCourse = openCourse
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
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
                await viewModel.load()
            }
        }
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

public struct CourseDetailView: View {
    public let course: Course
    public let openModule: (Module) -> Void
    public let startLesson: (Module, Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var expandedModules: Set<String> = []

    public init(course: Course, openModule: @escaping (Module) -> Void, startLesson: @escaping (Module, Lesson) -> Void) {
        self.course = course
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
                        .frame(height: 260)
                        .overlay(
                            VStack(alignment: .leading, spacing: 12) {
                                Text(course.category.uppercased())
                                    .font(SBFont.label(12))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                                Text(course.title)
                                    .font(SBFont.display(26))
                                    .foregroundStyle(.white)
                                Text(course.emoji)
                                    .font(.system(size: 34))
                                HStack {
                                    Label(course.totalDuration, systemImage: "clock.fill")
                                    Spacer()
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
                            Button {
                                dismiss()
                            } label: {
                                SBGlassCard {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                        Spacer()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SBCard {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: course.color1), Color(hex: course.color2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(course.instructor.prefix(1)))
                                        .font(SBFont.label(16))
                                        .foregroundStyle(.white)
                                )
                            VStack(alignment: .leading, spacing: 1) {
                                Text(course.instructor)
                                    .font(SBFont.label(14))
                                Text("Instrutor principal")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                            }
                            Spacer()
                        }
                    }

                    SBSectionHeader("Sobre o curso")
                    Text(course.description)
                        .font(SBFont.body(15))
                        .foregroundStyle(SBColor.textSecondary)

                    SBSectionHeader("Modulos")
                    ForEach(course.modules) { module in
                        moduleAccordion(module)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            SBCard {
                SBPrimaryButton("Iniciar curso", size: .lg, icon: "play.fill") {
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
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func moduleAccordion(_ module: Module) -> some View {
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
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(module.title)
                                .font(SBFont.label(14))
                                .foregroundStyle(SBColor.textPrimary)
                            Text(module.description)
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textTertiary)
                                .lineLimit(1)
                        }
                        Spacer()
                        if module.accessTier == .premium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(SBColor.accent)
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
    @State private var appeared = false

    public init(course: Course, module: Module, startLesson: @escaping (Lesson) -> Void, startQuiz: @escaping (Bool) -> Void) {
        self.course = course
        self.module = module
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
                SBNavBar(title: module.title, subtitle: "\(course.title) > modulo", onBack: nil)

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
