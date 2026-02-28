import SwiftUI
import AVFoundation
import Observation
import SkillBitsCore
import SkillBitsDesignSystem

@Observable
public final class LessonViewModel {
    public var lessonContent: LessonContent?
    public var speed: Float = 1.0
    public var isSpeaking = false
    private let repo: LessonRepository
    private let synthesizer = AVSpeechSynthesizer()

    public init(repo: LessonRepository) { self.repo = repo }

    public func load(courseId: String, moduleId: String, lessonId: String) {
        Task {
            let content = try? await repo.fetchLessonContent(courseId: courseId, moduleId: moduleId, lessonId: lessonId)
            await MainActor.run { self.lessonContent = content }
        }
    }

    public func speak() {
        guard let lessonContent else { return }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }
        let text = lessonContent.content.map { block -> String in
            switch block {
            case .heading(let value), .heading2(let value), .paragraph(let value): return value
            case .list(let items): return items.joined(separator: ". ")
            case .code(_, let text): return text
            case .callout(_, let text): return text
            }
        }.joined(separator: " ")
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speed * 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    public func completeLesson(courseId: String, moduleId: String, lessonId: String) {
        Task {
            try? await repo.completeLesson(courseId: courseId, moduleId: moduleId, lessonId: lessonId)
        }
    }
}

public struct LessonReaderView: View {
    @Bindable var viewModel: LessonViewModel
    public let courseId: String
    public let moduleId: String
    public let lesson: Lesson
    public let onComplete: () -> Void
    public let onStartQuiz: () -> Void
    @State private var showAudioSheet = false
    @State private var showFontSheet = false
    @State private var fontSize: CGFloat = 16
    @State private var lineSpacing: CGFloat = 6
    @State private var audioProgress: Double = 0
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: LessonViewModel, courseId: String, moduleId: String, lesson: Lesson, onComplete: @escaping () -> Void, onStartQuiz: @escaping () -> Void) {
        self.viewModel = viewModel
        self.courseId = courseId
        self.moduleId = moduleId
        self.lesson = lesson
        self.onComplete = onComplete
        self.onStartQuiz = onStartQuiz
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        SBIconButton(icon: "chevron.left") { dismiss() }
                        Spacer()
                        Text(viewModel.lessonContent?.title ?? lesson.title)
                            .font(SBFont.label(14))
                            .lineLimit(1)
                        Spacer()
                        SBIconButton(icon: "textformat.size") {
                            showFontSheet = true
                        }
                    }

                    Text("Aula - \(lesson.duration)")
                        .font(SBFont.label(12))
                        .foregroundStyle(SBColor.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(SBColor.accentBg)
                        .clipShape(Capsule())

                    Text(viewModel.lessonContent?.title ?? lesson.title)
                        .font(SBFont.display(28))
                        .foregroundStyle(SBColor.textPrimary)

                    ForEach(Array((viewModel.lessonContent?.content ?? []).enumerated()), id: \.offset) { _, block in
                        blockView(block)
                    }

                    SBSectionHeader("Acoes")
                    SBPrimaryButton(viewModel.isSpeaking ? "Parar audio" : "Ouvir texto", icon: "speaker.wave.2.fill") {
                        showAudioSheet = true
                        viewModel.speak()
                        withAnimation(SBMotion.medium) {
                            audioProgress = viewModel.isSpeaking ? 0.65 : 0
                        }
                    }
                    SBSecondaryButton("Marcar concluida") {
                        viewModel.completeLesson(courseId: courseId, moduleId: moduleId, lessonId: lesson.id)
                        SBHaptics.success()
                        onComplete()
                    }
                    SBOutlineButton("Iniciar questionario") {
                        onStartQuiz()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear { viewModel.load(courseId: courseId, moduleId: moduleId, lessonId: lesson.id) }
        .sheet(isPresented: $showFontSheet) {
            SBBottomSheet(title: "Preferencias de leitura") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tamanho da fonte")
                        .font(SBFont.label(14))
                    HStack {
                        ForEach([14.0, 16.0, 18.0, 20.0], id: \.self) { size in
                            Button("A") { fontSize = size }
                                .font(.system(size: size == fontSize ? 20 : 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(size == fontSize ? AnyShapeStyle(LinearGradient.skillBits) : AnyShapeStyle(SBColor.surface))
                                .foregroundStyle(size == fontSize ? .white : SBColor.textSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    Text("Espacamento")
                        .font(SBFont.label(14))
                    Slider(value: $lineSpacing, in: 2...12, step: 1)
                        .tint(SBColor.accent)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAudioSheet) {
            SBBottomSheet(title: "Audio da aula") {
                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient.skillBits)
                        .frame(width: 42, height: 42)
                        .overlay(Image(systemName: "speaker.wave.2.fill").foregroundStyle(.white))

                    SBProgressBar(value: audioProgress)

                    Button {
                        viewModel.speak()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isSpeaking ? "pause.fill" : "play.fill")
                            Text(viewModel.isSpeaking ? "Pausar" : "Reproduzir")
                                .font(SBFont.label(15))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LinearGradient.skillBits)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(SBPressableButtonStyle())

                    HStack {
                        Button("-") { viewModel.speed = max(0.8, viewModel.speed - 0.25) }
                        Spacer()
                        Text(String(format: "%.2fx", viewModel.speed))
                            .font(SBFont.stat(20))
                        Spacer()
                        Button("+") { viewModel.speed = min(2.0, viewModel.speed + 0.25) }
                    }
                    .font(SBFont.label(18))
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.isSpeaking) { _, speaking in
            withAnimation(SBMotion.medium) {
                audioProgress = speaking ? 0.8 : 0
            }
        }
    }

    @ViewBuilder
    private func blockView(_ block: LessonBlock) -> some View {
        switch block {
        case .heading(let value):
            Text(value)
                .font(SBFont.display(fontSize + 8))
                .tracking(-0.5)
                .foregroundStyle(SBColor.textPrimary)
        case .heading2(let value):
            Text(value)
                .font(SBFont.title(fontSize + 4))
                .tracking(-0.3)
                .foregroundStyle(SBColor.textPrimary)
        case .paragraph(let value):
            Text(value)
                .font(SBFont.body(fontSize))
                .foregroundStyle(SBColor.textSecondary)
                .lineSpacing(lineSpacing)
        case .list(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(LinearGradient.skillBits)
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        Text(item)
                            .font(SBFont.body(fontSize))
                            .foregroundStyle(SBColor.textSecondary)
                            .lineSpacing(lineSpacing)
                    }
                }
            }
        case .code(let language, let text):
            VStack(spacing: 0) {
                HStack {
                    Text(language.uppercased())
                        .font(SBFont.label(11))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(Color.red).frame(width: 7)
                        Circle().fill(Color.yellow).frame(width: 7)
                        Circle().fill(Color.green).frame(width: 7)
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Color(red: 0.127, green: 0.165, blue: 0.247))

                Text(text)
                    .font(SBFont.code(12.5))
                    .foregroundStyle(Color(red: 0.886, green: 0.910, blue: 0.957))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(red: 0.102, green: 0.133, blue: 0.208))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .callout(let title, let text):
            SBCard {
                VStack(alignment: .leading, spacing: 6) {
                    if let title {
                        Text(title)
                            .font(SBFont.title(16))
                            .foregroundStyle(SBColor.textPrimary)
                    }
                    Text(text)
                        .font(SBFont.body(14))
                        .foregroundStyle(SBColor.textSecondary)
                }
            }
        }
    }
}
