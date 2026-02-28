import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem
import SkillBitsGamification

@Observable
public final class ProfileViewModel {
    public var userName: String
    public var userEmail: String
    public var progress = UserProgress(xp: 0, streakDays: 0, dailyGoal: .minutes15, studiedMinutesToday: 0, badges: [])
    public var isLoading = false
    public var loadError = false
    public var onboardingReason: String?
    private var hasLoadedOnce = false
    private var lastLoadedAt: Date?
    private let refreshInterval: TimeInterval = 300
    private let repo: ProgressRepository

    public init(repo: ProgressRepository, userName: String = "Estudante", userEmail: String = "usuario@skillbits.app", onboardingReason: String? = nil) {
        self.repo = repo
        self.userName = userName
        self.userEmail = userEmail
        self.onboardingReason = onboardingReason
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

    public var avatarInitial: String {
        String(userName.prefix(1)).uppercased()
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
                await MainActor.run {
                    self.progress = value
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

public struct ProfileScreenView: View {
    @Bindable var viewModel: ProfileViewModel
    public let onLogout: () -> Void
    @State private var animateIn = false
    @State private var path: [ProfileDestination] = []

    public init(viewModel: ProfileViewModel, onLogout: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onLogout = onLogout
    }

    public var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                SBColor.background.ignoresSafeArea()
                if viewModel.shouldShowBlockingError {
                    SBErrorState(message: "Nao foi possivel carregar seu perfil.") {
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
                                        Text("Falha ao atualizar o perfil. Exibindo os dados anteriores.")
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

                            if viewModel.isInitialLoad {
                                profileHeaderSkeleton
                                if viewModel.onboardingReason != nil {
                                    objectiveSkeleton
                                }
                                miniStatsSkeleton
                            } else {
                                SBCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Circle()
                                                .fill(LinearGradient.skillBits)
                                                .frame(width: 66, height: 66)
                                                .overlay(Text(viewModel.avatarInitial).font(SBFont.stat(26)).foregroundStyle(.white))
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(viewModel.userName)
                                                    .font(SBFont.title(18))
                                                Text(viewModel.userEmail)
                                                    .font(SBFont.body(13))
                                                    .foregroundStyle(SBColor.textTertiary)
                                            }
                                            Spacer()
                                            SBBadge("Premium", kind: .premium)
                                        }
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text("Nivel \(LevelService.level(for: viewModel.progress.xp))")
                                                    .font(SBFont.label(14))
                                                Spacer()
                                                SBAnimatedCounter(target: viewModel.progress.xp, font: SBFont.stat(18), color: SBColor.accent)
                                            }
                                            SBProgressBar(value: Double(viewModel.progress.xp % 250) / 250.0)
                                            Text("\(250 - (viewModel.progress.xp % 250)) XP para o proximo nivel")
                                                .font(SBFont.body(12))
                                                .foregroundStyle(SBColor.textTertiary)
                                        }
                                    }
                                }

                                if let reason = viewModel.onboardingReason {
                                    objectiveCard(reason: reason)
                                }

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    miniStat("🔥", "\(viewModel.progress.streakDays)", "streak")
                                    miniStat("📘", "\(viewModel.progress.studiedMinutesToday)", "min hoje")
                                    miniStat("🏅", "\(viewModel.progress.badges.filter { $0.unlocked }.count)", "badges")
                                }
                            }

                            SBSectionHeader("Conta")
                            SBCard {
                                VStack(spacing: 2) {
                                    settingsRow(icon: "person.crop.circle", title: "Dados pessoais", subtitle: "Nome, email e senha", destination: .personalData)
                                    settingsRow(icon: "creditcard.fill", title: "Assinatura", subtitle: "Plano e cobranca", destination: .subscription)
                                }
                            }

                            SBSectionHeader("Preferencias")
                            SBCard {
                                VStack(spacing: 2) {
                                    settingsRow(icon: "bell.fill", title: "Notificacoes", subtitle: "Lembretes e novidades", destination: .notifications)
                                    settingsRow(icon: "target", title: "Meta de estudo", subtitle: "Ajuste objetivo diario", destination: .studyGoal)
                                }
                            }

                            SBSectionHeader("Suporte e legal")
                            SBCard {
                                VStack(spacing: 2) {
                                    settingsRow(icon: "questionmark.circle.fill", title: "Central de ajuda", subtitle: "FAQ e suporte", destination: .help)
                                    settingsRow(icon: "lock.shield.fill", title: "Privacidade e termos", subtitle: "Politicas e condicoes", destination: .privacy)
                                }
                            }

                            SBDangerButton { onLogout() }
                            Text("versao 1.0.0")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textTertiary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 14)
                        .animation(SBMotion.medium, value: animateIn)
                    }
                }
            }
            .animation(SBMotion.medium, value: viewModel.isInitialLoad)
            .animation(SBMotion.medium, value: viewModel.isRefreshing)
            .animation(SBMotion.medium, value: viewModel.shouldShowInlineError)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ProfileDestination.self) { destination in
                destinationView(destination)
            }
        }
        .onAppear {
            viewModel.load()
            animateIn = true
        }
    }

    private var profileHeaderSkeleton: some View {
        SBCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SBSkeletonBlock(width: 66, height: 66, cornerRadius: 33)
                    VStack(alignment: .leading, spacing: 6) {
                        SBSkeletonBlock(width: 120, height: 16, cornerRadius: 8)
                        SBSkeletonBlock(width: 150, height: 12, cornerRadius: 6)
                    }
                    Spacer()
                    SBSkeletonBlock(width: 70, height: 24, cornerRadius: 12)
                }
                HStack {
                    SBSkeletonBlock(width: 110, height: 14, cornerRadius: 7)
                    Spacer()
                    SBSkeletonBlock(width: 52, height: 18, cornerRadius: 9)
                }
                SBSkeletonBlock(height: 8, cornerRadius: 4)
                SBSkeletonBlock(width: 160, height: 12, cornerRadius: 6)
            }
        }
    }

    private var objectiveSkeleton: some View {
        SBCard {
            HStack(spacing: 12) {
                SBSkeletonBlock(width: 44, height: 44, cornerRadius: 12)
                VStack(alignment: .leading, spacing: 5) {
                    SBSkeletonBlock(width: 140, height: 14, cornerRadius: 7)
                    SBSkeletonBlock(width: 110, height: 12, cornerRadius: 6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    SBSkeletonBlock(width: 46, height: 16, cornerRadius: 8)
                    SBSkeletonBlock(width: 50, height: 10, cornerRadius: 5)
                }
            }
        }
    }

    private var miniStatsSkeleton: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in
                SBCard {
                    VStack(spacing: 6) {
                        SBSkeletonBlock(width: 22, height: 22, cornerRadius: 11)
                        SBSkeletonBlock(width: 38, height: 18, cornerRadius: 9)
                        SBSkeletonBlock(width: 46, height: 11, cornerRadius: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func objectiveCard(reason: String) -> some View {
        let (icon, title) = objectiveDisplay(for: reason)
        let goalText = "Meta: \(viewModel.progress.dailyGoal.rawValue) min/dia"

        return SBCard {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient.skillBits)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(icon)
                            .font(.system(size: 20))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(SBFont.label(14))
                        .foregroundStyle(SBColor.textPrimary)
                    Text(goalText)
                        .font(SBFont.body(12))
                        .foregroundStyle(SBColor.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.progress.xp)")
                        .font(SBFont.stat(18))
                        .foregroundStyle(SBColor.accent)
                    Text("XP total")
                        .font(SBFont.body(10))
                        .foregroundStyle(SBColor.textTertiary)
                }
            }
        }
    }

    private func objectiveDisplay(for reason: String) -> (icon: String, title: String) {
        switch reason {
        case "carreira":
            return ("💼", "Migrar de carreira")
        case "universidade":
            return ("🎓", "Complementar a faculdade")
        case "curiosidade":
            return ("🔍", "Explorar a area de TI")
        case "evolucao":
            return ("🚀", "Evoluir na area")
        default:
            return ("🎯", "Aprender tecnologia")
        }
    }

    private func miniStat(_ emoji: String, _ value: String, _ title: String) -> some View {
        SBCard {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 20))
                Text(value).font(SBFont.stat(18))
                Text(title).font(SBFont.body(11)).foregroundStyle(SBColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, destination: ProfileDestination) -> some View {
        SBSettingsRow(icon: icon, title: title, subtitle: subtitle) {
            path.append(destination)
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: ProfileDestination) -> some View {
        switch destination {
        case .personalData:
            PersonalDataView(name: viewModel.userName, email: viewModel.userEmail)
        case .subscription:
            SubscriptionView()
        case .notifications:
            NotificationSettingsView()
        case .studyGoal:
            StudyGoalView()
        case .help:
            HelpCenterView()
        case .privacy:
            PrivacyTermsView()
        }
    }
}

private enum ProfileDestination: Hashable {
    case personalData
    case subscription
    case notifications
    case studyGoal
    case help
    case privacy
}

public struct PersonalDataView: View {
    @State private var name: String
    @State private var email: String
    @State private var password = ""

    public init(name: String = "Estudante", email: String = "usuario@skillbits.app") {
        self._name = State(initialValue: name)
        self._email = State(initialValue: email)
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    SBTextField("Nome completo", icon: "person.fill", text: $name)
                    SBTextField("Email", icon: "envelope.fill", text: $email)
                    SBTextField("Nova senha", icon: "lock.fill", text: $password, secure: true)
                    SBPrimaryButton("Salvar alteracoes", size: .lg) { SBHaptics.success() }
                }
                .padding(20)
            }
        }
        .navigationTitle("Dados pessoais")
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct SubscriptionView: View {
    public init() {}

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    SBGradientBanner {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plano Premium ativo")
                                .font(SBFont.title(18))
                            Text("Proxima cobranca: 10 Mar 2026")
                                .font(SBFont.body(13))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    SBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Beneficios inclusos")
                                .font(SBFont.label(14))
                            Text("• Trilhas premium liberadas\n• Questionarios ilimitados\n• Certificados avancados")
                                .font(SBFont.body(13))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    }
                    SBOutlineButton("Cancelar assinatura") {}
                }
                .padding(20)
            }
        }
        .navigationTitle("Assinatura")
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct NotificationSettingsView: View {
    @State private var dailyReminder = true
    @State private var studyGoalUpdates = true
    @State private var newCourseAlerts = false

    public init() {}

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                SBCard {
                    VStack(spacing: 8) {
                        toggleRow("Lembrete diario", isOn: $dailyReminder)
                        toggleRow("Meta de estudo", isOn: $studyGoalUpdates)
                        toggleRow("Novos cursos", isOn: $newCourseAlerts)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Notificacoes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(SBFont.label(14))
                .foregroundStyle(SBColor.textPrimary)
        }
        .tint(SBColor.accent)
    }
}

public struct StudyGoalView: View {
    @State private var selected = 1
    private let options = ["15 min", "30 min", "45 min", "60 min"]

    public init() {}

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Text("Escolha sua meta diaria")
                        .font(SBFont.title(18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 10) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button {
                                selected = index
                            } label: {
                                VStack(spacing: 4) {
                                    Text(option)
                                        .font(SBFont.stat(18))
                                    Text("por dia")
                                        .font(SBFont.body(11))
                                }
                                .foregroundStyle(selected == index ? .white : SBColor.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(selected == index ? AnyShapeStyle(LinearGradient.skillBits) : AnyShapeStyle(SBColor.surface))
                                .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
                            }
                            .buttonStyle(SBPressableButtonStyle())
                        }
                    }
                    SBCard {
                        Text("Com \(options[selected]), voce pode finalizar 1 modulo por semana mantendo consistencia.")
                            .font(SBFont.body(13))
                            .foregroundStyle(SBColor.textSecondary)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Meta de estudo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct HelpCenterView: View {
    @State private var expanded: Set<Int> = []
    private let faqs: [(String, String)] = [
        ("Como recuperar senha?", "Acesse Dados pessoais e use a opcao de redefinir senha."),
        ("Como funciona o premium?", "Premium libera cursos avancados, quizzes e certificados extras."),
        ("Posso baixar aulas offline?", "No MVP atual, nao. Esse recurso esta no roadmap.")
    ]

    public init() {}

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(faqs.enumerated()), id: \.offset) { index, item in
                        SBCard(padded: false) {
                            VStack(spacing: 0) {
                                Button {
                                    withAnimation(SBMotion.springSmooth) {
                                        if expanded.contains(index) { expanded.remove(index) } else { expanded.insert(index) }
                                    }
                                } label: {
                                    HStack {
                                        Text(item.0)
                                            .font(SBFont.label(14))
                                            .foregroundStyle(SBColor.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .rotationEffect(.degrees(expanded.contains(index) ? 180 : 0))
                                            .foregroundStyle(SBColor.textTertiary)
                                    }
                                    .padding(14)
                                }
                                .buttonStyle(.plain)
                                if expanded.contains(index) {
                                    Divider().overlay(SBColor.border)
                                    Text(item.1)
                                        .font(SBFont.body(13))
                                        .foregroundStyle(SBColor.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(14)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Central de ajuda")
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct PrivacyTermsView: View {
    public init() {}

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                SBCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacidade")
                            .font(SBFont.title(18))
                        Text("Coletamos dados de uso para melhorar recomendacoes e experiencia do app. Informacoes pessoais sao tratadas conforme legislacao aplicavel.")
                            .font(SBFont.body(14))
                            .foregroundStyle(SBColor.textSecondary)
                        Text("Termos de uso")
                            .font(SBFont.title(18))
                        Text("Ao utilizar o SkillBits, voce concorda com as politicas de conteudo, licenciamento e uso responsavel da plataforma.")
                            .font(SBFont.body(14))
                            .foregroundStyle(SBColor.textSecondary)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Privacidade e termos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
