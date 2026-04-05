import Foundation

// MARK: - Replace this URL after pushing jokes.json to GitHub
// Format: https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/jokes.json
private let jokesURL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/jokes.json"

// MARK: - JSON model

private struct RemoteJoke: Decodable {
    let id:       String
    let language: String
    let type:     String
    let question: String
    let answer:   String
}

// MARK: - Service

@MainActor
class JokeService: ObservableObject {
    @Published var jokes:        [JokeItem] = []
    @Published var isLoading:    Bool       = false
    @Published var errorMessage: String?    = nil

    private var allRemote: [RemoteJoke] = []   // full list fetched once

    func fetch(language: AppLanguage, type: ItemType) async {
        errorMessage = nil

        // Fetch the full list once per app session
        if allRemote.isEmpty {
            isLoading = true
            guard let fetched = await fetchAll() else {
                isLoading = false
                return
            }
            allRemote = fetched
            isLoading = false
        }

        // Filter and shuffle locally — instant
        let langCode = language.rawValue.lowercased()
        let typeCode = type == .joke ? "joke" : "riddle"

        jokes = allRemote
            .filter { $0.language == langCode && $0.type == typeCode }
            .map    { JokeItem(question: $0.question, answer: $0.answer) }
            .shuffled()

        if jokes.isEmpty {
            errorMessage = "No \(typeCode)s found for \(language.displayName)."
        }
    }

    private func fetchAll() async -> [RemoteJoke]? {
        guard let url = URL(string: jokesURL) else {
            errorMessage = "Invalid jokes URL."
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([RemoteJoke].self, from: data)
        } catch {
            errorMessage = "Could not load jokes. Check your internet connection."
            return nil
        }
    }
}
