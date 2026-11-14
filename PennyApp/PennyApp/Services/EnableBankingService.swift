import AuthenticationServices
import Foundation
import UIKit

enum PennyAPIConfiguration {
    static var baseURL: URL? {
        if let value = ProcessInfo.processInfo.environment["PENNY_API_BASE_URL"],
           let url = URL(string: value), !value.isEmpty {
            return allowed(url)
        }
        guard let value = Bundle.main.object(forInfoDictionaryKey: "PennyAPIBaseURL") as? String,
              !value.isEmpty else { return nil }
        guard let url = URL(string: value) else { return nil }
        return allowed(url)
    }

    private static func allowed(_ url: URL) -> URL? {
#if DEBUG
        guard url.scheme == "https" || (url.scheme == "http" && url.host?.hasSuffix(".local") == true) else {
            return nil
        }
#else
        guard url.scheme == "https" else { return nil }
#endif
        return url
    }
}

/// Mobile client for the Next.js API. Banking and model secrets always stay server-side.
struct EnableBankingService: OpenBankingService, Sendable {
    let baseURL: URL

    func availableBanks() async throws -> [AvailableBank] {
        let data = try await send(URLRequest(url: endpoint("api/open-banking/banks")))
        let banks = try JSONDecoder().decode([BankDTO].self, from: data)
        return banks.compactMap { dto in
            guard let institution = Institution(rawValue: dto.name) else { return nil }
            return AvailableBank(institution: institution, name: dto.name, description: dto.description)
        }
    }

    func connect(_ bank: AvailableBank) async throws -> BankConnection {
        var request = URLRequest(url: endpoint("api/open-banking/connect"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ConnectRequest(name: bank.name, country: "FI"))
        let response = try JSONDecoder().decode(ConnectionStart.self, from: await send(request))

        let sessionID: String
        switch response.mode {
        case "complete":
            guard let value = response.sessionId else { throw OpenBankingError.invalidResponse }
            sessionID = value
        case "redirect":
            guard let authorizationURL = response.url else { throw OpenBankingError.invalidResponse }
            let callbackURL = try await WebAuthenticationSessionRunner.shared.authenticate(url: authorizationURL)
            let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
            guard components?.scheme == "penny", components?.host == "open-banking", components?.path.isEmpty != false else {
                throw OpenBankingError.invalidResponse
            }
            let queryItems = components?.queryItems ?? []
            let errorItems = queryItems.filter { $0.name == "error" }
            let sessionItems = queryItems.filter { $0.name == "session_id" }
            if errorItems.count == 1,
               sessionItems.isEmpty,
               let message = errorItems[0].value,
               !message.isEmpty {
                throw OpenBankingError.providerMessage(message)
            }
            guard errorItems.isEmpty,
                  sessionItems.count == 1,
                  let value = sessionItems[0].value,
                  !value.isEmpty,
                  UUID(uuidString: value) != nil else {
                throw OpenBankingError.invalidResponse
            }
            sessionID = value
        default:
            throw OpenBankingError.invalidResponse
        }

        return try await connection(sessionID: sessionID)
    }

    func connection(sessionID: String) async throws -> BankConnection {
        let data = try await send(URLRequest(url: endpoint("api/open-banking/sessions/\(sessionID)")))
        let dto = try apiDecoder.decode(ConnectionDTO.self, from: data)
        return try dto.domainValue(sessionID: sessionID)
    }

    private var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func endpoint(_ path: String) -> URL {
        path.split(separator: "/").reduce(baseURL) { url, component in
            url.appending(path: String(component))
        }
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw OpenBankingError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let apiError = try? JSONDecoder().decode(APIError.self, from: data)
            throw OpenBankingError.providerMessage(apiError?.error ?? "The Penny API returned \(http.statusCode).")
        }
        return data
    }

    private struct BankDTO: Codable {
        let name: String
        let country: String
        let description: String
    }

    private struct ConnectRequest: Encodable {
        let name: String
        let country: String
    }

    private struct ConnectionStart: Decodable {
        let mode: String
        let url: URL?
        let sessionId: String?
    }

    private struct APIError: Decodable { let error: String }

    private struct ConnectionDTO: Decodable {
        let institution: String
        let accounts: [AccountDTO]
        let transactions: [TransactionDTO]

        func domainValue(sessionID: String) throws -> BankConnection {
            guard let institution = Institution(rawValue: institution) else {
                throw OpenBankingError.invalidResponse
            }
            return BankConnection(
                institution: institution,
                accounts: try accounts.map { try $0.domainValue(institution: institution) },
                transactions: transactions.map { $0.domainValue(institution: institution) },
                sessionID: sessionID
            )
        }
    }

    private struct AccountDTO: Decodable {
        let id: String
        let name: String
        let kind: String
        let balance: Decimal
        let maskedNumber: String

        func domainValue(institution: Institution) throws -> BankAccount {
            let accountKind: AccountKind
            switch kind {
            case "current": accountKind = .current
            case "savings": accountKind = .savings
            case "mortgage": accountKind = .mortgage
            default: throw OpenBankingError.invalidResponse
            }
            return BankAccount(id: id, institution: institution, name: name, kind: accountKind, balance: balance, maskedNumber: maskedNumber)
        }
    }

    private struct TransactionDTO: Decodable {
        let id: String
        let accountID: String
        let merchant: String
        let amount: Decimal
        let date: Date
        let category: String

        func domainValue(institution: Institution) -> BankTransaction {
            BankTransaction(id: id, accountID: accountID, institution: institution, merchant: merchant, amount: amount, date: date, category: category)
        }
    }
}

@MainActor
private final class WebAuthenticationSessionRunner: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthenticationSessionRunner()
    private var session: ASWebAuthenticationSession?

    func authenticate(url: URL) async throws -> URL {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                session?.cancel()
                let authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "penny") { [weak self] callbackURL, error in
                    self?.session = nil
                    if let callbackURL {
                        continuation.resume(returning: callbackURL)
                    } else {
                        continuation.resume(throwing: error ?? OpenBankingError.invalidResponse)
                    }
                }
                authSession.presentationContextProvider = self
                authSession.prefersEphemeralWebBrowserSession = true
                session = authSession
                guard authSession.start() else {
                    session = nil
                    continuation.resume(throwing: OpenBankingError.invalidResponse)
                    return
                }
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.session?.cancel()
                self?.session = nil
            }
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}
