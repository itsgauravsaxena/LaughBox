import Foundation

// MARK: - Language

enum AppLanguage: String, CaseIterable {
    case english   = "EN"
    case danish    = "DA"
    case swedish   = "SV"
    case norwegian = "NO"
    case finnish   = "FI"
    case german    = "DE"
    case spanish   = "ES"
    case french    = "FR"

    var flag: String {
        switch self {
        case .english:   return "🇬🇧"
        case .danish:    return "🇩🇰"
        case .swedish:   return "🇸🇪"
        case .norwegian: return "🇳🇴"
        case .finnish:   return "🇫🇮"
        case .german:    return "🇩🇪"
        case .spanish:   return "🇪🇸"
        case .french:    return "🇫🇷"
        }
    }

    var displayName: String {
        switch self {
        case .english:   return "English"
        case .danish:    return "Dansk"
        case .swedish:   return "Svenska"
        case .norwegian: return "Norsk"
        case .finnish:   return "Suomi"
        case .german:    return "Deutsch"
        case .spanish:   return "Español"
        case .french:    return "Français"
        }
    }

    var jokesLabel: String {
        switch self {
        case .english:   return "Jokes"
        case .danish:    return "Vittigheder"
        case .swedish:   return "Skämt"
        case .norwegian: return "Vitser"
        case .finnish:   return "Vitsit"
        case .german:    return "Witze"
        case .spanish:   return "Chistes"
        case .french:    return "Blagues"
        }
    }

    var riddlesLabel: String {
        switch self {
        case .english:   return "Riddles"
        case .danish:    return "Gåder"
        case .swedish:   return "Gåtor"
        case .norwegian: return "Gåter"
        case .finnish:   return "Arvoitukset"
        case .german:    return "Rätsel"
        case .spanish:   return "Adivinanzas"
        case .french:    return "Devinettes"
        }
    }

    var tapReveal: String {
        switch self {
        case .english:   return "Tap to reveal the answer! 👇"
        case .danish:    return "Tryk for at se svaret! 👇"
        case .swedish:   return "Tryck för att se svaret! 👇"
        case .norwegian: return "Trykk for å se svaret! 👇"
        case .finnish:   return "Napauta nähdäksesi vastaus! 👇"
        case .german:    return "Tippen für die Antwort! 👇"
        case .spanish:   return "¡Toca para ver la respuesta! 👇"
        case .french:    return "Appuie pour voir la réponse! 👇"
        }
    }

    var nextButton: String {
        switch self {
        case .english:   return "Next →"
        case .danish:    return "Næste →"
        case .swedish:   return "Nästa →"
        case .norwegian: return "Neste →"
        case .finnish:   return "Seuraava →"
        case .german:    return "Weiter →"
        case .spanish:   return "Siguiente →"
        case .french:    return "Suivant →"
        }
    }

    var counter: String {
        switch self {
        case .english:   return "of"
        case .danish:    return "af"
        case .swedish:   return "av"
        case .norwegian: return "av"
        case .finnish:   return "/"
        case .german:    return "von"
        case .spanish:   return "de"
        case .french:    return "sur"
        }
    }
}

// MARK: - Item type

enum ItemType: CaseIterable {
    case joke, riddle

    func label(for lang: AppLanguage) -> String {
        self == .joke ? lang.jokesLabel : lang.riddlesLabel
    }
}

// MARK: - Model

struct JokeItem: Identifiable {
    let id       = UUID()
    let question : String
    let answer   : String
}
