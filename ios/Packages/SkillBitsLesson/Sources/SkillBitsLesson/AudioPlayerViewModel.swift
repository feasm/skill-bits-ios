import AVFoundation
import Observation

@Observable
public final class AudioPlayerViewModel {
    public var isPlaying = false
    public var isLoading = false
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var speed: Float = 1.0
    public private(set) var usesStreaming = false

    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1)
    }

    public var currentTimeText: String { Self.format(currentTime) }
    public var durationText: String { Self.format(duration) }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var durationObservation: NSKeyValueObservation?

    private let synthesizer = AVSpeechSynthesizer()
    private let synthDelegate = SynthDelegate()
    private var ttsText: String?

    public init() {
        synthesizer.delegate = synthDelegate
        synthDelegate.onFinish = { [weak self] in
            Task { @MainActor in self?.handleTTSFinished() }
        }
    }

    // MARK: - Configuration

    public func configure(audioUrl: String?, lessonText: String) {
        stop()
        if let audioUrl, let url = URL(string: audioUrl) {
            usesStreaming = true
            setupPlayer(url: url)
        } else {
            usesStreaming = false
            ttsText = lessonText
        }
    }

    // MARK: - Playback controls

    public func togglePlayPause() {
        if usesStreaming {
            toggleStreamPlayback()
        } else {
            toggleTTS()
        }
    }

    public func seek(to fraction: Double) {
        guard usesStreaming, let player, duration > 0 else { return }
        let target = CMTime(seconds: duration * fraction, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = duration * fraction
    }

    public func skip(seconds: TimeInterval) {
        guard usesStreaming, let player else { return }
        let target = CMTime(seconds: currentTime + seconds, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    public func setSpeed(_ newSpeed: Float) {
        speed = newSpeed
        if usesStreaming, isPlaying {
            player?.rate = newSpeed
        }
    }

    public func stop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        statusObservation?.invalidate()
        durationObservation?.invalidate()
        player?.pause()
        player = nil
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isLoading = false
        currentTime = 0
        duration = 0
    }

    deinit {
        if let observer = timeObserver { player?.removeTimeObserver(observer) }
        statusObservation?.invalidate()
        durationObservation?.invalidate()
        player?.pause()
        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - AVPlayer streaming

    private func setupPlayer(url: URL) {
        configureAudioSession()
        let item = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: item)
        player = avPlayer

        isLoading = true

        statusObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isLoading = false
                    let d = item.asset.duration.seconds
                    if d.isFinite {
                        self.duration = d
                    }
                case .failed:
                    self.isLoading = false
                default:
                    break
                }
            }
        }

        durationObservation = item.observe(\.duration, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                let d = item.duration.seconds
                if d.isFinite { self?.duration = d }
            }
        }

        timeObserver = avPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds

            if let d = avPlayer.currentItem?.duration.seconds, d.isFinite, d > 0 {
                self.duration = d
            }

            if let item = avPlayer.currentItem,
               item.status == .readyToPlay,
               time.seconds >= (item.duration.seconds - 0.3),
               item.duration.seconds > 0 {
                self.isPlaying = false
            }
        }
    }

    private func toggleStreamPlayback() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if let item = player.currentItem,
               item.duration.seconds > 0,
               currentTime >= item.duration.seconds - 0.5 {
                player.seek(to: .zero)
                currentTime = 0
            }
            player.rate = speed
            isPlaying = true
        }
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - TTS fallback

    private func toggleTTS() {
        guard let text = ttsText, !text.isEmpty else { return }
        if synthesizer.isSpeaking {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
                isPlaying = true
            } else {
                synthesizer.pauseSpeaking(at: .word)
                isPlaying = false
            }
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speed * 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        synthesizer.speak(utterance)
        isPlaying = true
    }

    private func handleTTSFinished() {
        isPlaying = false
    }

    // MARK: - Helpers

    private static func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }
}

private final class SynthDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}
