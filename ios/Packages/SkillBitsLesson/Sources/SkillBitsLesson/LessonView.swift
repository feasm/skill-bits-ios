import SwiftUI
import AVFoundation
import SkillBitsCore
import SkillBitsDesignSystem

public final class LessonViewModel: ObservableObject {
    @Published public var lessonContent: LessonContent?
    private let repo: LessonRepository

    public init(repo: LessonRepository) { self.repo = repo }

    public func load(courseId: String, moduleId: String, lessonId: String) {
        Task {
            let content = try? await repo.fetchLessonContent(courseId: courseId, moduleId: moduleId, lessonId: lessonId)
            await MainActor.run { self.lessonContent = content }
        }
    }

    public func completeLesson(courseId: String, moduleId: String, lessonId: String) {
        Task {
            try? await repo.completeLesson(courseId: courseId, moduleId: moduleId, lessonId: lessonId)
        }
    }
}

public struct LessonReaderView: View {
    @StateObject private var viewModel: LessonViewModel
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    public let courseId: String
    public let moduleId: String
    public let lesson: Lesson
    public let onComplete: () -> Void
    public let onStartQuiz: () -> Void
    public let onClose: (() -> Void)?
    @State private var showAudioSheet = false
    @State private var showFontSheet = false
    @State private var fontSize: CGFloat = 16
    @State private var lineSpacing: CGFloat = 6
    @State private var isSeeking = false
    @State private var seekProgress: Double = 0
    @Environment(\.dismiss) private var dismiss

    public init(repo: LessonRepository, courseId: String, moduleId: String, lesson: Lesson, onClose: (() -> Void)? = nil, onComplete: @escaping () -> Void, onStartQuiz: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: LessonViewModel(repo: repo))
        self.courseId = courseId
        self.moduleId = moduleId
        self.lesson = lesson
        self.onClose = onClose
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
                        if let onClose {
                            SBIconButton(icon: "xmark") {
                                onClose()
                            }
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
                    SBPrimaryButton(audioPlayer.isPlaying ? "Parar audio" : "Ouvir texto", icon: "speaker.wave.2.fill") {
                        configureAudioIfNeeded()
                        showAudioSheet = true
                        audioPlayer.togglePlayPause()
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
        .onDisappear { audioPlayer.stop() }
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
            audioSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Audio sheet

    private var audioSheet: some View {
        SBBottomSheet(title: "Audio da aula") {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient.skillBits)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Group {
                            if audioPlayer.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(.white)
                            }
                        }
                    )

                if audioPlayer.usesStreaming {
                    streamingControls
                } else {
                    ttsControls
                }

                speedPicker
            }
        }
    }

    private var streamingControls: some View {
        VStack(spacing: 12) {
            SBProgressBar(value: isSeeking ? seekProgress : audioPlayer.progress, height: 6)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isSeeking = true
                            seekProgress = max(0, min(1, Double(value.location.x / UIScreen.main.bounds.width)))
                        }
                        .onEnded { _ in
                            audioPlayer.seek(to: seekProgress)
                            isSeeking = false
                        }
                )

            HStack {
                Text(audioPlayer.currentTimeText)
                    .font(SBFont.label(12))
                    .foregroundStyle(SBColor.textTertiary)
                    .monospacedDigit()
                Spacer()
                Text(audioPlayer.durationText)
                    .font(SBFont.label(12))
                    .foregroundStyle(SBColor.textTertiary)
                    .monospacedDigit()
            }

            HStack(spacing: 24) {
                Button { audioPlayer.skip(seconds: -15) } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 22))
                        .foregroundStyle(SBColor.textSecondary)
                }

                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(LinearGradient.skillBits)
                }

                Button { audioPlayer.skip(seconds: 15) } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 22))
                        .foregroundStyle(SBColor.textSecondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var ttsControls: some View {
        VStack(spacing: 12) {
            Text("Usando voz do sistema")
                .font(SBFont.label(12))
                .foregroundStyle(SBColor.textTertiary)

            Button {
                audioPlayer.togglePlayPause()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    Text(audioPlayer.isPlaying ? "Pausar" : "Reproduzir")
                        .font(SBFont.label(15))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(LinearGradient.skillBits)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(SBPressableButtonStyle())
        }
    }

    private var speedPicker: some View {
        HStack(spacing: 10) {
            ForEach([Float(1.0), 1.25, 1.5, 2.0], id: \.self) { spd in
                Button {
                    audioPlayer.setSpeed(spd)
                } label: {
                    Text(spd == 1.0 ? "1x" : String(format: "%.2gx", spd))
                        .font(SBFont.label(15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(audioPlayer.speed == spd ? AnyShapeStyle(LinearGradient.skillBits) : AnyShapeStyle(SBColor.surface))
                        .foregroundStyle(audioPlayer.speed == spd ? .white : SBColor.textSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(audioPlayer.speed == spd ? Color.clear : SBColor.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Audio config

    private func configureAudioIfNeeded() {
        guard !audioPlayer.isPlaying, audioPlayer.duration == 0 else { return }
        guard let content = viewModel.lessonContent else { return }

        let text = content.content.map { block -> String in
            switch block {
            case .heading(let value), .heading2(let value), .paragraph(let value): return value
            case .list(let items): return items.joined(separator: ". ")
            case .code: return ""
            case .callout(_, let text): return text
            }
        }.joined(separator: " ")

        audioPlayer.configure(audioUrl: content.audioUrl, lessonText: text)
    }

    // MARK: - Block rendering

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
