import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem

@Observable
public final class QuizViewModel {
    public var questions: [QuizQuestion] = []
    public var currentIndex = 0
    public var selectedAnswer: Int?
    public var confirmedAnswers: [Int] = []
    public var result: QuizResult?
    public var isLoading = false
    public var isSubmitting = false
    public var loadErrorMessage: String?
    public var submitErrorMessage: String?
    public var showInstantFeedback = false
    public var wasLastCorrect = false
    public var confirmedCurrent = false
    public var quizFirst = false
    private let repo: QuizRepository
    private var moduleId = ""

    public init(repo: QuizRepository) { self.repo = repo }

    public func load(moduleId: String, quizFirst: Bool) {
        self.moduleId = moduleId
        self.quizFirst = quizFirst
        isLoading = true
        isSubmitting = false
        loadErrorMessage = nil
        submitErrorMessage = nil
        Task {
            do {
                let data = try await repo.fetchQuiz(moduleId: moduleId)
                await MainActor.run {
                    self.questions = data
                    self.currentIndex = 0
                    self.selectedAnswer = nil
                    self.confirmedAnswers = []
                    self.result = nil
                    self.confirmedCurrent = false
                    self.showInstantFeedback = false
                    self.isLoading = false
                    if data.isEmpty {
                        self.loadErrorMessage = "Nao foi possivel carregar o questionario."
                    }
                }
            } catch {
                await MainActor.run {
                    self.questions = []
                    self.currentIndex = 0
                    self.selectedAnswer = nil
                    self.confirmedAnswers = []
                    self.result = nil
                    self.confirmedCurrent = false
                    self.showInstantFeedback = false
                    self.isLoading = false
                    self.loadErrorMessage = "Nao foi possivel carregar o questionario."
                }
            }
        }
    }

    public var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    public var correctCount: Int {
        confirmedAnswers.enumerated().reduce(into: 0) { partialResult, pair in
            let (index, answer) = pair
            guard index < questions.count else { return }
            if answer == questions[index].correctIndex {
                partialResult += 1
            }
        }
    }

    public func confirmCurrent() {
        guard let selectedAnswer, let question = currentQuestion else { return }
        if confirmedCurrent { return }
        confirmedCurrent = true
        submitErrorMessage = nil
        confirmedAnswers.append(selectedAnswer)
        wasLastCorrect = selectedAnswer == question.correctIndex
        showInstantFeedback = true
        if wasLastCorrect { SBHaptics.success() } else { SBHaptics.error() }
    }

    public func moveNext() {
        guard !isSubmitting else { return }
        if currentIndex + 1 < questions.count {
            confirmedCurrent = false
            showInstantFeedback = false
            selectedAnswer = nil
            currentIndex += 1
        } else {
            submitAnswers()
        }
    }

    public func retryLoad() {
        guard !moduleId.isEmpty else { return }
        load(moduleId: moduleId, quizFirst: quizFirst)
    }

    public func retrySubmit() {
        guard !moduleId.isEmpty else { return }
        submitAnswers()
    }

    private func submitAnswers() {
        guard !isSubmitting else { return }
        isSubmitting = true
        submitErrorMessage = nil
        Task {
            do {
                let value = try await repo.submitQuiz(moduleId: moduleId, answers: confirmedAnswers, quizFirst: quizFirst)
                await MainActor.run {
                    self.result = value
                    self.isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.submitErrorMessage = "Nao foi possivel enviar suas respostas. Tente novamente."
                    SBHaptics.error()
                }
            }
        }
    }
}

public struct QuizIntroView: View {
    public let moduleTitle: String
    private let quizRepo: QuizRepository
    private let moduleId: String
    public let startStudyMode: () -> Void
    public let startQuizFirstMode: () -> Void
    @State private var animateIn = false
    @State private var questionCount: Int?
    @State private var isLoadingCount = true

    public init(
        moduleTitle: String,
        quizRepo: QuizRepository,
        moduleId: String,
        startStudyMode: @escaping () -> Void,
        startQuizFirstMode: @escaping () -> Void
    ) {
        self.moduleTitle = moduleTitle
        self.quizRepo = quizRepo
        self.moduleId = moduleId
        self.startStudyMode = startStudyMode
        self.startQuizFirstMode = startQuizFirstMode
    }

    private var estimatedMinutes: Int {
        max(1, (questionCount ?? 0) * 2)
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerGradient

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        statsRow
                            .padding(.top, 20)

                        stepsCard

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 24)
                }

                buttonsSection
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 16)
            .animation(SBMotion.medium, value: animateIn)
        }
        .onAppear {
            animateIn = true
            loadQuestionCount()
        }
    }

    private var headerGradient: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.skillBits
                .frame(height: 200)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .offset(x: 40, y: -30)
                }
                .overlay(alignment: .bottomLeading) {
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 100, height: 100)
                        .offset(x: -20, y: 30)
                }

            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.2))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                    )

                Text("Questionario")
                    .font(SBFont.display(24))
                    .foregroundStyle(.white)

                Text(moduleTitle)
                    .font(SBFont.body(14))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 24)
        }
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 28,
                bottomTrailingRadius: 28
            )
        )
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: questionCount.map { "\($0)" },
                label: "Perguntas",
                icon: "list.bullet.clipboard",
                color: SBColor.accent
            )
            statDivider
            statItem(
                value: questionCount.map { _ in "~\(estimatedMinutes) min" },
                label: "Estimado",
                icon: "clock",
                color: SBColor.purple
            )
            statDivider
            statItem(
                value: "70%",
                label: "Minimo",
                icon: "target",
                color: SBColor.success
            )
        }
        .padding(.vertical, 14)
        .background(SBColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(SBColor.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statItem(value: String?, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            if let value {
                Text(value)
                    .font(SBFont.stat(18))
                    .foregroundStyle(SBColor.textPrimary)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(SBColor.border)
                    .frame(width: 28, height: 18)
                    .opacity(isLoadingCount ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isLoadingCount)
            }
            Text(label)
                .font(SBFont.body(11))
                .foregroundStyle(SBColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(SBColor.border)
            .frame(width: 1, height: 40)
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como funciona")
                .font(SBFont.label(13))
                .foregroundStyle(SBColor.textTertiary)

            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                HStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient.skillBits.opacity(0.15))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(idx + 1)")
                                .font(SBFont.label(12))
                                .foregroundStyle(SBColor.accent)
                        )
                    Text(step)
                        .font(SBFont.body(14))
                        .foregroundStyle(SBColor.textSecondary)
                }
            }
        }
        .padding(16)
        .background(SBColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(SBColor.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var steps: [String] {
        [
            "Leia com calma cada pergunta",
            "Confirme sua resposta",
            "Veja o feedback imediato",
            "Continue para a proxima etapa"
        ]
    }

    private var buttonsSection: some View {
        VStack(spacing: 10) {
            SBPrimaryButton("Estudar primeiro", size: .lg, icon: "book.fill") {
                startStudyMode()
            }
            SBOutlineButton("Ir direto para o quiz") {
                startQuizFirstMode()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(SBColor.surface)
        .sbShadow(.sticky)
    }

    private func loadQuestionCount() {
        Task {
            do {
                let questions = try await quizRepo.fetchQuiz(moduleId: moduleId)
                await MainActor.run {
                    withAnimation(SBMotion.quick) {
                        questionCount = questions.count
                        isLoadingCount = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(SBMotion.quick) {
                        questionCount = nil
                        isLoadingCount = false
                    }
                }
            }
        }
    }
}

public struct QuizQuestionView: View {
    @State private var viewModel: QuizViewModel
    private let moduleId: String
    private let quizFirst: Bool
    public let onExit: () -> Void
    public let onFinish: (QuizResult) -> Void
    @State private var showExitConfirmation = false

    public init(repo: QuizRepository, moduleId: String, quizFirst: Bool, onExit: @escaping () -> Void = {}, onFinish: @escaping (QuizResult) -> Void) {
        self._viewModel = State(initialValue: QuizViewModel(repo: repo))
        self.moduleId = moduleId
        self.quizFirst = quizFirst
        self.onExit = onExit
        self.onFinish = onFinish
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading {
                    loadingState
                } else if let errorMessage = viewModel.loadErrorMessage {
                    loadErrorState(message: errorMessage)
                } else if let question = viewModel.currentQuestion {
                    HStack {
                        SBIconButton(icon: "chevron.left") {
                            showExitConfirmation = true
                        }
                        .accessibilityLabel("Sair do questionario")
                        .accessibilityHint("Abre confirmacao para sair e perder o progresso.")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pergunta \(viewModel.currentIndex + 1) de \(viewModel.questions.count)")
                                .font(SBFont.label(13))
                            Text("\(viewModel.correctCount) acertos")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textTertiary)
                        }
                        Spacer()
                    }
                    SBProgressBar(value: Double(viewModel.currentIndex + (viewModel.confirmedCurrent ? 1 : 0)) / Double(max(viewModel.questions.count, 1)))
                        .accessibilityLabel("Progresso do questionario")
                        .accessibilityValue("Pergunta \(viewModel.currentIndex + 1) de \(max(viewModel.questions.count, 1))")

                    SBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PERGUNTA \(viewModel.currentIndex + 1)")
                                .font(SBFont.label(12))
                                .foregroundStyle(SBColor.textTertiary)
                            Text(question.question)
                                .font(SBFont.title(17))
                                .foregroundStyle(SBColor.textPrimary)
                        }
                    }

                    ForEach(Array(question.options.enumerated()), id: \.offset) { idx, option in
                        Button {
                            guard !viewModel.confirmedCurrent else { return }
                            viewModel.selectedAnswer = idx
                            SBHaptics.selection()
                        } label: {
                            optionRow(index: idx, option: option, question: question)
                        }
                        .buttonStyle(SBPressableButtonStyle())
                        .disabled(viewModel.confirmedCurrent)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(optionAccessibilityLabel(index: idx, option: option, question: question))
                        .accessibilityHint(viewModel.confirmedCurrent ? "Resposta ja confirmada." : "Toque para selecionar esta resposta.")
                        .accessibilityAddTraits(viewModel.selectedAnswer == idx ? .isSelected : [])
                    }

                    if viewModel.showInstantFeedback {
                        SBCard {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: viewModel.wasLastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(viewModel.wasLastCorrect ? SBColor.success : SBColor.error)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.wasLastCorrect ? "Correto!" : "Nao foi dessa vez")
                                        .font(SBFont.title(16))
                                    Text(question.explanation)
                                        .font(SBFont.body(13))
                                        .foregroundStyle(SBColor.textSecondary)
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .accessibilityElement(children: .combine)
                    }

                    Spacer()
                    if !viewModel.confirmedCurrent {
                        SBPrimaryButton("Confirmar resposta", size: .lg, disabled: viewModel.selectedAnswer == nil || viewModel.isSubmitting) {
                            viewModel.confirmCurrent()
                        }
                    } else {
                        SBPrimaryButton(
                            viewModel.currentIndex + 1 == viewModel.questions.count ? "Finalizar" : "Proxima pergunta",
                            size: .lg,
                            icon: "arrow.right",
                            disabled: viewModel.isSubmitting
                        ) {
                            viewModel.moveNext()
                        }
                        .accessibilityHint(viewModel.currentIndex + 1 == viewModel.questions.count ? "Envia o resultado final do quiz." : "Vai para a proxima pergunta.")
                    }

                    if let submitErrorMessage = viewModel.submitErrorMessage {
                        SBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Falha ao enviar")
                                    .font(SBFont.label(14))
                                    .foregroundStyle(SBColor.error)
                                Text(submitErrorMessage)
                                    .font(SBFont.body(13))
                                    .foregroundStyle(SBColor.textSecondary)
                                SBOutlineButton("Tentar novamente") {
                                    viewModel.retrySubmit()
                                }
                            }
                        }
                    }
                } else {
                    loadErrorState(message: "Nao encontramos perguntas para este modulo.")
                }
            }
            .padding(20)
        }
        .animation(SBMotion.quick, value: viewModel.showInstantFeedback)
        .onAppear { viewModel.load(moduleId: moduleId, quizFirst: quizFirst) }
        .alert("Sair do questionario?", isPresented: $showExitConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) { onExit() }
        } message: {
            Text("Seu progresso atual sera perdido.")
        }
        .onChange(of: viewModel.result) { _, newValue in
            if let newValue { onFinish(newValue) }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Text("Carregando questionario...")
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Carregando questionario")
    }

    private func loadErrorState(message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            SBCard {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundStyle(SBColor.error)
                    Text("Nao foi possivel abrir o quiz")
                        .font(SBFont.title(17))
                    Text(message)
                        .font(SBFont.body(13))
                        .foregroundStyle(SBColor.textSecondary)
                        .multilineTextAlignment(.center)
                    SBPrimaryButton("Tentar novamente", size: .md) {
                        viewModel.retryLoad()
                    }
                }
            }
            SBSecondaryButton("Sair do questionario") {
                onExit()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func optionAccessibilityLabel(index: Int, option: String, question: QuizQuestion) -> String {
        let letters = ["A", "B", "C", "D", "E"]
        let letter = index < letters.count ? letters[index] : "\(index + 1)"
        let selected = viewModel.selectedAnswer == index
        if !viewModel.confirmedCurrent {
            return "Opcao \(letter). \(option). \(selected ? "Selecionada." : "Nao selecionada.")"
        }
        if index == question.correctIndex {
            return "Opcao \(letter). \(option). Resposta correta."
        }
        if selected {
            return "Opcao \(letter). \(option). Sua resposta, incorreta."
        }
        return "Opcao \(letter). \(option)."
    }

    private func optionRow(index: Int, option: String, question: QuizQuestion) -> some View {
        let letters = ["A", "B", "C", "D", "E"]
        let selected = viewModel.selectedAnswer == index
        let isCorrect = index == question.correctIndex
        let showFeedback = viewModel.confirmedCurrent
        let bgColor: Color = {
            if !showFeedback { return selected ? SBColor.accentBg : SBColor.surface }
            if isCorrect { return SBColor.successBg }
            if selected && !isCorrect { return SBColor.errorBg }
            return SBColor.surface
        }()
        let borderColor: Color = {
            if !showFeedback { return selected ? SBColor.accent : SBColor.border }
            if isCorrect { return SBColor.success }
            if selected && !isCorrect { return SBColor.error }
            return SBColor.border
        }()

        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(borderColor.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(letters[index])
                        .font(SBFont.label(12))
                        .foregroundStyle(borderColor)
                )
            Text(option)
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textPrimary)
            Spacer()
            if showFeedback && isCorrect {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(SBColor.success)
            } else if showFeedback && selected && !isCorrect {
                Image(systemName: "xmark.circle.fill").foregroundStyle(SBColor.error)
            }
        }
        .padding(12)
        .background(bgColor)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

public struct QuizResultView: View {
    public let result: QuizResult
    public let onReview: () -> Void
    public let onRetry: () -> Void
    public let onContinue: () -> Void

    public init(result: QuizResult, onReview: @escaping () -> Void, onRetry: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self.result = result
        self.onReview = onReview
        self.onRetry = onRetry
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    SBScoreCircle(score: result.score)
                        .accessibilityLabel("Pontuacao final")
                        .accessibilityValue("\(result.score) de 100")
                    SBBadge(
                        result.passed ? "Aprovado" : "Reprovado",
                        kind: .custom(
                            background: result.passed ? SBColor.successBg : SBColor.errorBg,
                            text: result.passed ? SBColor.success : SBColor.error
                        )
                    )
                    Text(result.passed ? "Excelente resultado" : "Continue praticando")
                        .font(SBFont.display(24))
                    Text("Voce acertou \(result.correctCount) de \(result.total) perguntas.")
                        .font(SBFont.body(14))
                        .foregroundStyle(SBColor.textSecondary)

                    HStack(spacing: 10) {
                        SBStatCard(icon: "checkmark.circle.fill", value: "\(result.correctCount)", label: "Corretas", tint: SBColor.success)
                        SBStatCard(icon: "xmark.circle.fill", value: "\(max(0, result.total - result.correctCount))", label: "Incorretas", tint: SBColor.error)
                        SBStatCard(icon: "target", value: "70%", label: "Minimo", tint: SBColor.accent)
                    }

                    if !result.passed {
                        SBCard {
                            Button {
                                onReview()
                            } label: {
                                HStack {
                                    Image(systemName: "scope")
                                        .foregroundStyle(SBColor.purple)
                                    Text("Ver revisao guiada")
                                        .font(SBFont.label(14))
                                        .foregroundStyle(SBColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(SBColor.textTertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if result.passed {
                        SBPrimaryButton("Continuar para proxima aula", size: .lg) { onContinue() }
                    } else {
                        SBPrimaryButton("Ver revisao guiada", size: .lg) { onReview() }
                    }
                    SBSecondaryButton("Refazer quiz") { onRetry() }
                }
                .padding(24)
            }
        }
        .onAppear {
            if result.passed { SBHaptics.success() } else { SBHaptics.error() }
        }
    }
}

public struct GuidedReviewView: View {
    public let points: [GuidedReviewPoint]
    public let openLesson: (String) -> Void

    public init(points: [GuidedReviewPoint], openLesson: @escaping (String) -> Void) {
        self.points = points
        self.openLesson = openLesson
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    SBNavBar(title: "Revisao guiada", subtitle: "Pontos que precisam de atencao")
                    SBCard {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(SBColor.purple)
                            Text("Revise estes temas antes de refazer o quiz.")
                                .font(SBFont.body(13))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    }
                    ForEach(Array(points.enumerated()), id: \.element.id) { idx, point in
                        SBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Circle()
                                        .fill(LinearGradient.skillBits)
                                        .frame(width: 32, height: 32)
                                        .overlay(Text("\(idx + 1)").font(SBFont.label(12)).foregroundStyle(.white))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(point.topic).font(SBFont.label(14))
                                        Text("Ponto fraco detectado").font(SBFont.body(12)).foregroundStyle(SBColor.textTertiary)
                                    }
                                    Spacer()
                                }
                                Text("\"\(point.explanation)\"")
                                    .font(SBFont.body(13))
                                    .italic()
                                    .foregroundStyle(SBColor.textSecondary)
                                    .padding(10)
                                    .background(SBColor.background)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(SBColor.border))
                                SBOutlineButton("Ver trecho no conteudo") { openLesson(point.lessonId) }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

public struct NextLessonView: View {
    public let nextLessonTitle: String
    public let onContinue: () -> Void

    public init(nextLessonTitle: String, onContinue: @escaping () -> Void) {
        self.nextLessonTitle = nextLessonTitle
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            SBMeshBackground()
            ScrollView {
                VStack(spacing: 14) {
                    Circle()
                        .fill(SBColor.success)
                        .frame(width: 76, height: 76)
                        .overlay(Image(systemName: "checkmark.circle.fill").font(.system(size: 38)).foregroundStyle(.white))
                        .scaleEffect(1.0)
                    Text("Licao concluida!")
                        .font(SBFont.display(26))

                    SBCard {
                        HStack {
                            Text("✨")
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("+")
                                    SBAnimatedCounter(target: 25, font: SBFont.stat(22), color: SBColor.success)
                                    Text("XP")
                                }
                                .font(SBFont.label(14))
                                Text("Continue assim para subir de nivel")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                            }
                            Spacer()
                        }
                    }

                    SBCard {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient.skillBits)
                                .frame(width: 42, height: 42)
                                .overlay(Image(systemName: "play.circle.fill").foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Proxima aula")
                                    .font(SBFont.body(12))
                                    .foregroundStyle(SBColor.textTertiary)
                                Text(nextLessonTitle)
                                    .font(SBFont.label(14))
                            }
                            Spacer()
                        }
                    }
                    SBPrimaryButton("Continuar", size: .lg, icon: "arrow.right") { onContinue() }
                }
                .padding(24)
            }
        }
        .onAppear { SBHaptics.xpGain() }
    }
}
