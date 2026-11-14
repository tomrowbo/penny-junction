import SwiftUI

struct PennyCoachView: View {
    @Environment(AppStore.self) private var store
    @State private var path: [PennyChatThread] = []
    @State private var draft = ""

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                PennyAtmosphere()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PennyRootHeader(title: "Ask Penny")
                        prompt
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
                    .id(thread.id)
            }
            .onAppear { openPendingContext() }
            .onChange(of: store.pendingPennyChatContext) { _, _ in openPendingContext() }
        }
    }

    private var prompt: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                PennyMark(size: 48)
                Text("What’s on your mind?")
                    .font(.title2.weight(.bold))
            }
            PennyChatComposer(draft: $draft, isSending: false, onSubmit: openDraft)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Can I afford it?", "Review my spending", "Help me save"], id: \.self) { prompt in
                        PennyPromptChip(prompt: prompt) {
                            path = [.conversation(initialDraft: prompt)]
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(PennyTheme.textPrimary)
    }

    private var conversations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent conversations")
                .font(.title2.weight(.bold))
                .foregroundStyle(PennyTheme.textPrimary)
            if store.chatHistory.isEmpty {
                HStack(spacing: 12) {
                    PennyMark(size: 34, inverse: true)
                    Text("Your chats with Penny will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(PennyTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .pennyGlassSurface(cornerRadius: 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(store.chatHistory) { chat in
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
                                Text(relativeTime(chat.updatedAt)).font(.caption2).foregroundStyle(PennyTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(PennyTheme.textSecondary.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 70)
                    }
                    .buttonStyle(.plain)
                    if chat.id != store.chatHistory.last?.id {
                        Divider().overlay(Color.black.opacity(0.08)).padding(.leading, 70)
                    }
                }
                }
                .pennyGlassSurface(cornerRadius: 22)
            }
        }
    }

    private func openDraft() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        path = [.conversation(initialDraft: String(text.prefix(4_000)))]
        draft = ""
    }

    private func openPendingContext() {
        guard let context = store.pendingPennyChatContext else { return }
        store.pendingPennyChatContext = nil
        path = [.conversation(context: context)]
    }

    private func relativeTime(_ date: Date) -> String {
        date.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
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

private struct PennyChatComposer: View {
    @Binding var draft: String
    let isSending: Bool
    let onSubmit: () -> Void

    private var canSubmit: Bool {
        !isSending && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Ask Penny anything…", text: $draft, axis: .vertical)
                .font(.body)
                .foregroundStyle(PennyTheme.textPrimary)
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .pennyGlassSurface(cornerRadius: 24)
                .submitLabel(.send)
                .onSubmit { if canSubmit { onSubmit() } }
            Button { if canSubmit { onSubmit() } } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.white.opacity(canSubmit ? 1 : 0.6))
                    .frame(width: 46, height: 46)
                    .background(PennyTheme.forest, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send message")
            .accessibilityValue(canSubmit ? "Ready to send" : "Enter a message")
            .allowsHitTesting(canSubmit)
        }
    }
}

private struct PennyPromptChip: View {
    let prompt: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(prompt)
                .font(.caption.weight(.semibold))
                .foregroundStyle(PennyTheme.forest)
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.8), in: Capsule())
                .overlay { Capsule().strokeBorder(Color.black.opacity(0.08)) }
        }
        .buttonStyle(.plain)
    }
}

struct PennyChatContextCard: View {
    let context: PennyChatContext

    private var symbol: String {
        switch context.type {
        case .transaction: "creditcard"
        case .account: "building.columns"
        case .goal: "target"
        case .upcoming: "calendar"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(PennyTheme.forest, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(context.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PennyTheme.textPrimary)
                Text(context.subtitle.components(separatedBy: " · ").prefix(3).joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(PennyTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .pennyGlassSurface(cornerRadius: 20)
    }
}

struct DiscussWithPennyAction: View {
    var itemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PennyMark(size: 30)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.8), in: Circle())
                .overlay { Circle().strokeBorder(Color.black.opacity(0.08)) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Discuss \(itemName) with Penny")
    }
}

struct PennyChatThread: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let symbol: String
    let initialMessages: [PennyChatMessage]
    var context: PennyChatContext? = nil
    var initialDraft: String = ""
    var updatedAt: Date = .now

    var preview: String {
        initialMessages.last?.text ?? initialDraft
    }

    static func conversation(context: PennyChatContext? = nil, initialDraft: String = "") -> PennyChatThread {
        PennyChatThread(id: UUID().uuidString, title: "Ask Penny",
                        symbol: PennyBrand.markAssetName, initialMessages: [],
                        context: context, initialDraft: initialDraft)
    }

    static let samples: [PennyChatThread] = [
        PennyChatThread(
            id: "car",
            title: "Buy a new car",
            symbol: "car",
            initialMessages: [
                PennyChatMessage(role: .user, text: "I would like to buy a new car, but I’m not sure I can afford it. What do you think?"),
                PennyChatMessage(role: .penny, text: "I can help with that. I can see your S-Bank spending, but before estimating affordability you should connect the bank holding your mortgage so I include every regular commitment.", source: "example")
            ],
            updatedAt: .now
        ),
        PennyChatThread(
            id: "weekly",
            title: "Stay within my weekly budget",
            symbol: "calendar",
            initialMessages: [
                PennyChatMessage(role: .user, text: "What is safe to spend this week?"),
                PennyChatMessage(role: .penny, text: "Ask me for a fresh calculation and I’ll use your current connected data, essential costs and irregular-cost reserve.", source: "example")
            ],
            updatedAt: .now.addingTimeInterval(-86_400)
        ),
        PennyChatThread(
            id: "groceries",
            title: "Understand my grocery spending",
            symbol: "basket",
            initialMessages: [
                PennyChatMessage(role: .user, text: "Why was my grocery spending so high?"),
                PennyChatMessage(role: .penny, text: "Ask me to compare a period and I’ll calculate the change from your transaction history.", source: "example")
            ],
            updatedAt: .now.addingTimeInterval(-172_800)
        )
    ]

    static let newChat = PennyChatThread(
        id: "new",
        title: "Ask Penny",
        symbol: PennyBrand.markAssetName,
        initialMessages: []
    )
}

struct PennyChatMessage: Identifiable, Hashable, Codable {
    enum Role: String, Hashable, Codable { case user, penny }
    let id: UUID
    let role: Role
    let text: String
    let evidence: PennyEvidence?
    let visualizations: [PennyVisualization]
    let suggestedPrompts: [String]
    let source: String?

    init(id: UUID = UUID(), role: Role, text: String, evidence: PennyEvidence? = nil, visualizations: [PennyVisualization] = [], suggestedPrompts: [String] = [], source: String? = nil) {
        self.id = id
        self.role = role
        self.text = text
        self.evidence = evidence
        self.visualizations = visualizations
        self.suggestedPrompts = suggestedPrompts
        self.source = source
    }
}

enum PennyReplyChunker {
    static func chunks(from text: String, maxChunks: Int = 3) -> [String] {
        guard text.contains(where: { !$0.isWhitespace }), maxChunks > 1 else {
            return text.isEmpty ? [] : [text]
        }

        let paragraphBoundaries = boundaries(in: text, separatedBy: "\n\n")
        if !paragraphBoundaries.isEmpty {
            return slices(of: text, at: paragraphBoundaries, maxChunks: maxChunks)
        }

        guard text.count > 180 else { return [text] }
        var sentenceBoundaries: [String.Index] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { _, range, _, _ in
            if range.upperBound < text.endIndex { sentenceBoundaries.append(range.upperBound) }
        }
        return sentenceBoundaries.isEmpty ? [text] : slices(of: text, at: sentenceBoundaries, maxChunks: maxChunks)
    }

    private static func boundaries(in text: String, separatedBy separator: String) -> [String.Index] {
        var result: [String.Index] = []
        var cursor = text.startIndex
        while let range = text.range(of: separator, range: cursor..<text.endIndex) {
            let candidate = range.upperBound
            if text[cursor..<candidate].contains(where: { !$0.isWhitespace }) {
                result.append(candidate)
            }
            cursor = candidate
        }
        return result
    }

    private static func slices(of text: String, at boundaries: [String.Index], maxChunks: Int) -> [String] {
        let selected = boundaries.prefix(maxChunks - 1)
        var start = text.startIndex
        var result: [String] = []
        for end in selected where end > start {
            result.append(String(text[start..<end]))
            start = end
        }
        if start < text.endIndex { result.append(String(text[start..<text.endIndex])) }
        return result
    }
}

private struct PennyThinkingBubble: View {
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            PennyMark(size: 28, inverse: true)
            Text("Thinking…")
                .font(.body.weight(.medium))
                .foregroundStyle(PennyTheme.textSecondary)
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                .background(PennyTheme.glassOpaque, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay {
                    GeometryReader { proxy in
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.75), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: proxy.size.width * 0.55)
                        .offset(x: shimmerOffset * proxy.size.width * 1.7)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                }
            Spacer(minLength: 54)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.25).repeatForever(autoreverses: false)) {
                shimmerOffset = 1
            }
        }
        .accessibilityLabel("Penny is thinking")
    }
}

struct PennyChatView: View {
    @Environment(AppStore.self) private var store
    let thread: PennyChatThread
    @State private var messages: [PennyChatMessage]
    @State private var draft = ""
    @State private var pendingInitialSubmission: String?
    @State private var isSending = false
    @State private var showsThinking = false
    @State private var errorMessage: String?

    init(thread: PennyChatThread) {
        self.thread = thread
        _messages = State(initialValue: thread.initialMessages)
        _draft = State(initialValue: "")
        _pendingInitialSubmission = State(initialValue: thread.initialDraft.isEmpty ? nil : thread.initialDraft)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if let context = thread.context {
                            PennyChatContextCard(context: context)
                        }
                        if shouldShowStarters {
                            starterPrompts
                        }
                        ForEach(messages) { message in
                            messageBubble(message).id(message.id)
                        }
                        if showsThinking {
                            PennyThinkingBubble()
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
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            store.isTabBarHidden = true
            if let initialSubmission = pendingInitialSubmission {
                pendingInitialSubmission = nil
                send(initialSubmission)
            }
        }
        .onDisappear { store.isTabBarHidden = false }
    }

    private var shouldShowStarters: Bool {
        messages.isEmpty && !isSending
    }

    private var starterPrompts: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array((thread.context?.suggestedPrompts ?? ["What can I spend?", "Help me save"]).prefix(2)), id: \.self) { prompt in
                PennyPromptChip(prompt: prompt) { draft = prompt }
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
                    .foregroundStyle(message.role == .user ? Color.white : PennyTheme.textPrimary)
                    .padding(13)
                    .background(
                        message.role == .user ? PennyTheme.forest : PennyTheme.glassOpaque,
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
        PennyChatComposer(draft: $draft, isSending: isSending) { send() }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func send(_ suggestedText: String? = nil) {
        guard !isSending else { return }
        let source = suggestedText ?? draft
        let text = String(source.trimmingCharacters(in: .whitespacesAndNewlines).prefix(4_000))
        guard !text.isEmpty else { return }
        messages.append(PennyChatMessage(role: .user, text: text))
        store.saveConversation(thread: thread, messages: messages)
        draft = ""
        errorMessage = nil
        isSending = true
        showsThinking = true
        let conversation = messages
        Task { @MainActor in
            defer {
                isSending = false
                showsThinking = false
            }
            guard let baseURL = PennyAPIConfiguration.baseURL else {
                errorMessage = "The Penny API has not been configured."
                return
            }
            do {
                let reply = try await PennyChatService(baseURL: baseURL).reply(
                    goal: thread.title,
                    messages: conversation,
                    accounts: store.accounts,
                    transactions: store.transactions,
                    context: thread.context
                )
                showsThinking = false
                let chunks = PennyReplyChunker.chunks(from: reply.message)
                for (index, chunk) in chunks.enumerated() {
                    if index > 0 { try? await Task.sleep(for: .milliseconds(240)) }
                    let isLast = index == chunks.count - 1
                    messages.append(PennyChatMessage(
                        role: .penny,
                        text: chunk,
                        evidence: isLast ? reply.evidence : nil,
                        visualizations: isLast ? reply.visualizations : [],
                        suggestedPrompts: isLast ? reply.suggestedPrompts : [],
                        source: isLast ? reply.source : nil
                    ))
                    store.saveConversation(thread: thread, messages: messages)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
