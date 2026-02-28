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
        Task {
            let data = (try? await repo.fetchQuiz(moduleId: moduleId)) ?? []
            await MainActor.run {
                self.questions = data
                self.currentIndex = 0
                self.selectedAnswer = nil
                self.confirmedAnswers = []
                self.result = nil
                self.confirmedCurrent = false
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
        confirmedAnswers.append(selectedAnswer)
        wasLastCorrect = selectedAnswer == question.correctIndex
        showInstantFeedback = true
        if wasLastCorrect { SBHaptics.success() } else { SBHaptics.error() }
    }

    public func moveNext() {
        confirmedCurrent = false
        showInstantFeedback = false
        selectedAnswer = nil
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            Task {
                let value = try? await repo.submitQuiz(moduleId: moduleId, answers: confirmedAnswers, quizFirst: quizFirst)
                await MainActor.run { self.result = value }
            }
        }
    }
}

public struct QuizIntroView: View {
    public let startStudyMode: () -> Void
    public let startQuizFirstMode: () -> Void
    @State private var animateIn = false

    public init(startStudyMode: @escaping () -> Void, startQuizFirstMode: @escaping () -> Void) {
        self.startStudyMode = startStudyMode
        self.startQuizFirstMode = startQuizFirstMode
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(LinearGradient.skillBits)
                        .frame(width: 88, height: 88)
                        .overlay(Image(systemName: "questionmark.circle.fill").font(.system(size: 44)).foregroundStyle(.white))
                        .sbShadow(.logo)

                    Text("Questionario rapido")
                        .font(SBFont.display(24))
                        .foregroundStyle(SBColor.textPrimary)
                    Text("Responda as perguntas e acompanhe sua evolucao em tempo real.")
                        .font(SBFont.body(15))
                        .foregroundStyle(SBColor.textSecondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 10) {
                        stat("3", "Perguntas", SBColor.accent)
                        stat("5", "Minutos", SBColor.purple)
                        stat("70%", "Minimo", SBColor.success)
                    }

                    SBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SBSectionHeader("Como funciona")
                            Text("1. Leia com calma cada pergunta\n2. Confirme sua resposta\n3. Veja o feedback imediato\n4. Continue para a proxima etapa")
                                .font(SBFont.body(13))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    }

                    SBPrimaryButton("Estudar primeiro", size: .lg, icon: "book.fill") {
                        startStudyMode()
                    }
                    SBOutlineButton("Ir direto para o quiz") {
                        startQuizFirstMode()
                    }
                }
                .padding(24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                .animation(SBMotion.medium, value: animateIn)
            }
        }
        .onAppear { animateIn = true }
    }

    private func stat(_ value: String, _ title: String, _ color: Color) -> some View {
        SBCard {
            VStack(spacing: 4) {
                Text(value).font(SBFont.stat(18)).foregroundStyle(color)
                Text(title).font(SBFont.body(11)).foregroundStyle(SBColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

public struct QuizQuestionView: View {
    @Bindable var viewModel: QuizViewModel
    public let onFinish: (QuizResult) -> Void

    public init(viewModel: QuizViewModel, onFinish: @escaping (QuizResult) -> Void) {
        self.viewModel = viewModel
        self.onFinish = onFinish
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                if let question = viewModel.currentQuestion {
                    HStack {
                        SBIconButton(icon: "chevron.left") {}
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
                    }

                    Spacer()
                    if !viewModel.confirmedCurrent {
                        SBPrimaryButton("Confirmar resposta", size: .lg, disabled: viewModel.selectedAnswer == nil) {
                            viewModel.confirmCurrent()
                        }
                    } else {
                        SBPrimaryButton(
                            viewModel.currentIndex + 1 == viewModel.questions.count ? "Finalizar" : "Proxima pergunta",
                            size: .lg,
                            icon: "arrow.right"
                        ) {
                            viewModel.moveNext()
                        }
                    }
                }
            }
            .padding(20)
        }
        .animation(SBMotion.quick, value: viewModel.showInstantFeedback)
        .onChange(of: viewModel.result) { _, newValue in
            if let newValue { onFinish(newValue) }
        }
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
