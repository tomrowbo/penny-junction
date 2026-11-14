import Foundation

@MainActor
protocol PennyConversationStore {
    func load() throws -> [PennyChatThread]
    func save(_ conversations: [PennyChatThread]) throws
}

@MainActor
final class UserDefaultsPennyConversationStore: PennyConversationStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "penny.conversations.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() throws -> [PennyChatThread] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([PennyChatThread].self, from: data)
    }

    func save(_ conversations: [PennyChatThread]) throws {
        let data = try JSONEncoder().encode(conversations)
        defaults.set(data, forKey: key)
    }
}
