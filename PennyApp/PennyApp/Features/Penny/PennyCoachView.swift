import SwiftUI

struct PennyCoachView: View {
    @Environment(AppStore.self) private var store
    @State private var showConnectBank = false
    private let chats = PennyChatThread.samples

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SMobiiliHeader(title: "Penny")
                ScrollView {
                    VStack(spacing: 14) {
                        header
                        dataSources
                        conversations
                        newChatButton
                    }
                    .padding(SMobiiliMetrics.contentInset)
                    .padding(.bottom, SMobiiliMetrics.tabBarHeight)
                }
                .background(SMobiiliPalette.canvas)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: PennyChatThread.self) { thread in
                PennyChatView(thread: thread)
            }
            .sheet(isPresented: $showConnectBank) { ConnectBankView() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                PennyMark(size: 30)
                Spacer()
                Text("YOUR MONEY, IN PLAIN LANGUAGE")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SMobiiliPalette.green)
            }
            Text("What are you working towards?")
                .font(.title2.weight(.bold))
            Text("Create a goal, explore what-if scenarios and keep discussing it with Penny as your finances change.")
                .font(.subheadline)
                .foregroundStyle(SMobiiliPalette.secondaryLabel)
        }
        .foregroundStyle(.primary)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: SMobiiliMetrics.serviceRowRadius, style: .continuous))
    }

    private var dataSources: some View {
        BrandCard {
            HStack {
                Text("Connected data").font(.headline)
                Spacer()
                Text(store.hasConnectedExternalBank ? "2 banks" : "S-Bank only")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            sourceRow(institution: .sBank, title: "S-Bank", detail: "Accounts and transactions")
            Divider()
            if let external = store.accounts.first(where: { $0.institution != .sBank }) {
                sourceRow(institution: external.institution, title: external.institution.rawValue, detail: "Accounts and mortgage")
            } else {
                Button {
                    showConnectBank = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .frame(width: 38, height: 38)
                            .background(PennyTheme.mint, in: RoundedRectangle(cornerRadius: 11))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Connect another bank").font(.body.weight(.semibold))
                            Text("Include mortgages, loans and other accounts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.primary)
                }
            }

        }
    }

    private func sourceRow(institution: Institution, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            InstitutionBadge(institution: institution)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill").foregroundStyle(PennyTheme.green)
        }
    }

    private var conversations: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your goals").font(.headline)
            VStack(spacing: 0) {
                ForEach(chats) { chat in
                    NavigationLink(value: chat) {
                        HStack(spacing: 12) {
                            chatIcon(chat)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chat.title)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(chat.preview)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 7) {
                                Text(chat.time).font(.caption2).foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                    if chat.id != chats.last?.id { Divider().padding(.leading, 70) }
                }
            }
            .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: SMobiiliMetrics.serviceRowRadius, style: .continuous))
        }
    }

    private var newChatButton: some View {
        NavigationLink(value: PennyChatThread.newChat) {
            Label("Create new goal", systemImage: "plus.circle.fill")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    @ViewBuilder
    private func chatIcon(_ chat: PennyChatThread) -> some View {
        if chat.symbol == PennyBrand.markAssetName {
            PennyMark(size: 42)
        } else {
            Image(systemName: chat.symbol)
                .font(.headline)
                .foregroundStyle(PennyTheme.green)
                .frame(width: 42, height: 42)
                .background(PennyTheme.mint, in: RoundedRectangle(cornerRadius: 12))
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
    let suggestedPrompts: [String]
    let source: String?

    init(role: Role, text: String, evidence: PennyEvidence? = nil, suggestedPrompts: [String] = [], source: String? = nil) {
        self.role = role
        self.text = text
        self.evidence = evidence
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
                                PennyMark(size: 28)
                                ProgressView()
                                    .padding(15)
                                    .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
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
        .background(PennyTheme.canvas)
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
        .foregroundStyle(PennyTheme.darkGreen)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PennyTheme.mint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                    .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                if message.role == .penny { PennyMark(size: 28) }
                Text(formattedMessage(message.text))
                    .font(.body)
                    .foregroundStyle(message.role == .user ? Color.white : Color.primary)
                    .padding(13)
                    .background(
                        message.role == .user ? PennyTheme.green : SMobiiliPalette.surface,
                        in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                    )
                if message.role == .penny { Spacer(minLength: 54) }
            }
            if let evidence = message.evidence {
                evidenceDisclosure(evidence)
                    .padding(.leading, 36)
                    .padding(.trailing, 54)
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
        .foregroundStyle(PennyTheme.darkGreen)
        .padding(11)
        .background(PennyTheme.mint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
            Button { send() } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(PennyTheme.green, in: Circle())
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
                messages.append(PennyChatMessage(role: .penny, text: reply.message, evidence: reply.evidence, suggestedPrompts: reply.suggestedPrompts, source: reply.source))
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
