import SwiftUI

struct PennyCoachView: View {
    private let chats = PennyChatThread.samples

    var body: some View {
        NavigationStack {
            ZStack {
                PennyAtmosphere()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PennyRootHeader(title: "Ask Penny", subtitle: "Explore your money in plain language.")
                        prompt
                        newChatButton
                        conversations
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: PennyChatThread.self) { thread in
                PennyChatView(thread: thread)
            }
        }
    }

    private var prompt: some View {
        HStack(alignment: .top, spacing: 16) {
            PennyMark(size: 54, inverse: true)
            VStack(alignment: .leading, spacing: 7) {
                Text("What’s on your mind?")
                    .font(.title2.weight(.bold))
                Text("Ask about spending, try a what-if, or work through a decision. Penny uses your connected financial picture and shows the evidence behind the answer.")
                    .font(.subheadline)
                    .foregroundStyle(PennyTheme.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(PennyTheme.textPrimary)
        .pennyGlassSurface(cornerRadius: 24)
    }

    private var conversations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent conversations")
                .font(.title2.weight(.bold))
                .foregroundStyle(PennyTheme.textPrimary)
            VStack(spacing: 0) {
                ForEach(chats) { chat in
                    NavigationLink(value: chat) {
                        HStack(spacing: 12) {
                            chatIcon(chat)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chat.title)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(PennyTheme.textPrimary)
                                    .lineLimit(1)
                                Text(chat.preview)
                                    .font(.caption)
                                    .foregroundStyle(PennyTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 7) {
                                Text(chat.time).font(.caption2).foregroundStyle(PennyTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(PennyTheme.textSecondary.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 70)
                    }
                    .buttonStyle(.plain)
                    if chat.id != chats.last?.id {
                        Divider().overlay(Color.black.opacity(0.08)).padding(.leading, 70)
                    }
                }
            }
            .pennyGlassSurface(cornerRadius: 22)
        }
    }

    private var newChatButton: some View {
        NavigationLink(value: PennyChatThread.newChat) {
            HStack {
                Text("Start a conversation")
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.headline)
            .foregroundStyle(PennyTheme.obsidian)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(PennyTheme.emeraldBright, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func chatIcon(_ chat: PennyChatThread) -> some View {
        if chat.symbol == PennyBrand.markAssetName {
            PennyMark(size: 42, inverse: true)
        } else {
            Image(systemName: chat.symbol)
                .font(.headline)
                .foregroundStyle(PennyTheme.emeraldBright)
                .frame(width: 42, height: 42)
                .background(Color.black.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PennyChatThread: Identifiable, Hashable {
    let id: String
    let title: String
    let preview: String
    let time: String
    let symbol: String
    let initialMessages: [PennyChatMessage]

    static let samples: [PennyChatThread] = [
        PennyChatThread(
            id: "car",
            title: "Buy a new car",
            preview: "Based on your current spending and commitments…",
            time: "Today",
            symbol: "car",
            initialMessages: [
                PennyChatMessage(role: .user, text: "I would like to buy a new car, but I’m not sure I can afford it. What do you think?"),
                PennyChatMessage(role: .penny, text: "I can help with that. I can see your S-Bank spending, but before estimating affordability you should connect the bank holding your mortgage so I include every regular commitment.", source: "example")
            ]
        ),
        PennyChatThread(
            id: "weekly",
            title: "Stay within my weekly budget",
            preview: "Ask Penny to calculate a safe weekly amount.",
            time: "Yesterday",
            symbol: "calendar",
            initialMessages: [
                PennyChatMessage(role: .user, text: "What is safe to spend this week?"),
                PennyChatMessage(role: .penny, text: "Ask me for a fresh calculation and I’ll use your current connected data, essential costs and irregular-cost reserve.", source: "example")
            ]
        ),
        PennyChatThread(
            id: "groceries",
            title: "Understand my grocery spending",
            preview: "Explore how grocery spending has changed.",
            time: "Mon",
            symbol: "basket",
            initialMessages: [
                PennyChatMessage(role: .user, text: "Why was my grocery spending so high?"),
                PennyChatMessage(role: .penny, text: "Ask me to compare a period and I’ll calculate the change from your transaction history.", source: "example")
            ]
        )
    ]

    static let newChat = PennyChatThread(
        id: "new",
        title: "New goal",
        preview: "Describe what you want to achieve",
        time: "",
        symbol: PennyBrand.markAssetName,
        initialMessages: [
            PennyChatMessage(role: .penny, text: "What would you like to achieve? Tell me about the goal, and we’ll work through it together.")
        ]
    )
}

struct PennyChatMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, penny }
    let id = UUID()
    let role: Role
    let text: String
    let evidence: PennyEvidence?
    let visualizations: [PennyVisualization]
    let suggestedPrompts: [String]
    let source: String?

    init(role: Role, text: String, evidence: PennyEvidence? = nil, visualizations: [PennyVisualization] = [], suggestedPrompts: [String] = [], source: String? = nil) {
        self.role = role
        self.text = text
        self.evidence = evidence
        self.visualizations = visualizations
        self.suggestedPrompts = suggestedPrompts
        self.source = source
    }
}

struct PennyChatView: View {
    @Environment(AppStore.self) private var store
    let thread: PennyChatThread
    @State private var messages: [PennyChatMessage]
    @State private var draft = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    init(thread: PennyChatThread) {
        self.thread = thread
        _messages = State(initialValue: thread.initialMessages)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        contextBanner
                        if shouldShowStarters {
                            starterPrompts
                        }
                        ForEach(messages) { message in
                            messageBubble(message).id(message.id)
                        }
                        if isSending {
                            HStack(alignment: .bottom, spacing: 8) {
                                PennyMark(size: 28, inverse: true)
                                ProgressView()
                                    .padding(15)
                                    .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                                Spacer(minLength: 54)
                            }
                        }
                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                }
            }
            composer
        }
        .background(PennyAtmosphere())
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { store.isTabBarHidden = true }
        .onDisappear { store.isTabBarHidden = false }
    }

    private var contextBanner: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lock.fill")
            VStack(alignment: .leading, spacing: 2) {
                Text("Using \(connectedInstitutionNames)")
                    .fontWeight(.bold)
                Text(dataCoverageLabel)
                    .foregroundStyle(PennyTheme.darkGreen.opacity(0.72))
            }
        }
        .font(.caption)
        .foregroundStyle(PennyTheme.emeraldBright)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.black.opacity(0.09)) }
    }

    private var dataCoverageLabel: String {
        switch store.sBankDataStatus {
        case .official(let coverage): "Connected history • \(coverage)"
        case .loading: "Updating your financial history…"
        case .unavailable: "Financial history is temporarily unavailable"
        case .fallback: "\(store.transactions.count) recent transactions"
        }
    }

    private var connectedInstitutionNames: String {
        Array(Set(store.accounts.map(\.institution)))
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.rawValue)
            .joined(separator: " + ")
    }

    private var shouldShowStarters: Bool {
        thread.id == PennyChatThread.newChat.id && !messages.contains { $0.role == .user } && !isSending
    }

    private var starterPrompts: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explore your money").font(.headline)
            Text("Start with an idea or ask anything below.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(PennyGoalStarter.allCases) { starter in
                Button { send(starter.prompt) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: starter.symbol)
                            .foregroundStyle(PennyTheme.green)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(starter.title).font(.subheadline.weight(.semibold))
                            Text(starter.prompt).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(PennyTheme.green)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.black.opacity(0.08)) }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func messageBubble(_ message: PennyChatMessage) -> some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 7) {
            HStack(alignment: .bottom, spacing: 8) {
                if message.role == .user { Spacer(minLength: 54) }
                if message.role == .penny { PennyMark(size: 28, inverse: true) }
                Text(formattedMessage(message.text))
                    .font(.body)
                    .foregroundStyle(message.role == .user ? PennyTheme.textPrimary : Color.primary)
                    .padding(13)
                    .background(
                        message.role == .user ? PennyTheme.emerald : PennyTheme.glassOpaque,
                        in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                    )
                if message.role == .penny { Spacer(minLength: 54) }
            }
            if let evidence = message.evidence {
                evidenceDisclosure(evidence)
                    .padding(.leading, 36)
                    .padding(.trailing, 54)
            }
            if !message.visualizations.isEmpty {
                VStack(spacing: 10) {
                    ForEach(message.visualizations) { visualization in
                        PennyEvidenceVisualization(visualization: visualization)
                    }
                }
                .padding(.leading, 36)
                .padding(.trailing, 12)
            }
            if !message.suggestedPrompts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(message.suggestedPrompts, id: \.self) { prompt in
                            Button(prompt) { send(prompt) }
                                .font(.caption.weight(.semibold))
                                .buttonStyle(.bordered)
                                .tint(PennyTheme.green)
                                .disabled(isSending)
                        }
                    }
                }
                .padding(.leading, 36)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func evidenceDisclosure(_ evidence: PennyEvidence) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 7) {
                Label(evidence.coverage, systemImage: "calendar")
                Label("\(evidence.transactionCount) transactions • \(evidence.institutions.joined(separator: " + "))", systemImage: "building.columns")
                Label("\(evidence.confidence.capitalized) confidence", systemImage: "checkmark.shield")
                ForEach(evidence.baskets, id: \.id) { basket in
                    HStack {
                        Text(basket.label)
                        Spacer()
                        Text(basket.amount.euroCurrency).fontWeight(.semibold)
                    }
                }
                ForEach(evidence.assumptions, id: \.self) { assumption in
                    Text("• \(assumption)").foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        } label: {
            Label("How this was calculated", systemImage: "info.circle")
                .fontWeight(.semibold)
        }
        .font(.caption)
        .foregroundStyle(PennyTheme.emeraldBright)
        .padding(11)
        .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.black.opacity(0.09)) }
    }

    private func formattedMessage(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Discuss this goal…", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 18))
            Button { send() } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(PennyTheme.emerald, in: Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .disabled(isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? 0.45 : 1)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func send(_ suggestedText: String? = nil) {
        guard !isSending else { return }
        let source = suggestedText ?? draft
        let text = String(source.trimmingCharacters(in: .whitespacesAndNewlines).prefix(4_000))
        guard !text.isEmpty else { return }
        messages.append(PennyChatMessage(role: .user, text: text))
        draft = ""
        errorMessage = nil
        isSending = true
        let conversation = messages
        Task { @MainActor in
            defer { isSending = false }
            guard let baseURL = PennyAPIConfiguration.baseURL else {
                errorMessage = "The Penny API has not been configured."
                return
            }
            do {
                let reply = try await PennyChatService(baseURL: baseURL).reply(
                    goal: thread.title,
                    messages: conversation,
                    accounts: store.accounts,
                    transactions: store.transactions
                )
                messages.append(PennyChatMessage(role: .penny, text: reply.message, evidence: reply.evidence, visualizations: reply.visualizations, suggestedPrompts: reply.suggestedPrompts, source: reply.source))
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
