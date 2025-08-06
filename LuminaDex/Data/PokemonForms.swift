//
//  PokemonForms.swift
//  LuminaDex
//
//  Day 25: Pokemon Forms Data Structures
//

import Foundation
import SwiftUI

// MARK: - API Response Models
struct PokemonSpeciesResponse: Codable {
    let varieties: [PokemonVariety]
}

struct PokemonVariety: Codable {
    let isDefault: Bool
    let pokemon: NamedResource
    
    private enum CodingKeys: String, CodingKey {
        case isDefault = "is_default"
        case pokemon
    }
}

struct PokemonResponse: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: PokemonSpritesResponse
    let types: [PokemonTypeSlotResponse]
    let abilities: [PokemonAbilitySlotResponse]
    let stats: [PokemonStatResponse]
    let order: Int
    let isDefault: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, height, weight, sprites, types, abilities, stats, order
        case isDefault = "is_default"
    }
}

struct PokemonSpritesResponse: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let backDefault: String?
    let backShiny: String?
    let other: OtherSprites?
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case backDefault = "back_default"
        case backShiny = "back_shiny"
        case other
    }
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork?
    
    private enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonTypeSlotResponse: Codable {
    let slot: Int
    let type: NamedResource
}

struct PokemonAbilitySlotResponse: Codable {
    let isHidden: Bool
    let slot: Int
    let ability: NamedResource
    
    private enum CodingKeys: String, CodingKey {
        case isHidden = "is_hidden"
        case slot, ability
    }
}

struct PokemonStatResponse: Codable {
    let baseStat: Int
    let effort: Int
    let stat: NamedResource
    
    private enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

// MARK: - Pokemon Form Types
enum PokemonFormType: String, CaseIterable, Codable {
    case normal = "Normal"
    case mega = "Mega"
    case megaX = "Mega X"
    case megaY = "Mega Y"
    case alola = "Alolan"
    case galar = "Galarian"
    case hisui = "Hisuian"
    case paldea = "Paldean"
    case gigantamax = "Gigantamax"
    case primal = "Primal"
    case origin = "Origin"
    case therian = "Therian"
    case zenMode = "Zen Mode"
    case crowned = "Crowned"
    case eternamax = "Eternamax"
    case male = "Male"
    case female = "Female"
    
    var icon: String {
        switch self {
        case .normal: return "circle"
        case .mega, .megaX, .megaY: return "bolt.circle.fill"
        case .alola, .galar, .hisui, .paldea: return "globe.americas.fill"
        case .gigantamax, .eternamax: return "arrow.up.circle.fill"
        case .primal: return "flame.fill"
        case .origin: return "sparkles"
        case .therian: return "cloud.bolt.fill"
        case .zenMode: return "yin.yang"
        case .crowned: return "crown.fill"
        case .male: return "mustache.fill"
        case .female: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .normal: return .gray
        case .mega, .megaX, .megaY: return .purple
        case .alola: return .orange
        case .galar: return .indigo
        case .hisui: return .brown
        case .paldea: return .teal
        case .gigantamax, .eternamax: return .red
        case .primal: return .orange
        case .origin: return .cyan
        case .therian: return .green
        case .zenMode: return .yellow
        case .crowned: return .yellow
        case .male: return .blue
        case .female: return .pink
        }
    }
}

// MARK: - Pokemon Form Data
struct PokemonForm: Identifiable, Codable {
    let id: String
    let pokemonId: Int
    let name: String
    let formType: PokemonFormType
    let sprites: FormSprites
    let stats: [PokemonStat]?
    let types: [PokemonTypeSlot]?
    let abilities: [PokemonAbilitySlot]?
    let height: Int?
    let weight: Int?
    let isDefault: Bool
    let isBattleOnly: Bool
    let formOrder: Int
    
    var displayName: String {
        if formType == .normal {
            return name.capitalized
        }
        return "\(formType.rawValue) \(name.capitalized)"
    }
    
    var formattedHeight: String? {
        guard let height = height else { return nil }
        let meters = Double(height) / 10.0
        return String(format: "%.1f m", meters)
    }
    
    var formattedWeight: String? {
        guard let weight = weight else { return nil }
        let kg = Double(weight) / 10.0
        return String(format: "%.1f kg", kg)
    }
}

// MARK: - Form Sprites
struct FormSprites: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let backDefault: String?
    let backShiny: String?
    let officialArtwork: String?
    
    var primarySprite: String {
        officialArtwork ?? frontDefault ?? ""
    }
}

// MARK: - Pokemon Evolution Chain
struct EvolutionChain: Codable {
    let id: Int
    let chain: EvolutionLink
}

struct EvolutionLink: Codable {
    let species: EvolutionSpecies
    let evolvesTo: [EvolutionLink]
    let evolutionDetails: [EvolutionDetail]?
    let isBaby: Bool
    
    private enum CodingKeys: String, CodingKey {
        case species
        case evolvesTo = "evolves_to"
        case evolutionDetails = "evolution_details"
        case isBaby = "is_baby"
    }
}

struct EvolutionSpecies: Codable {
    let name: String
    let url: String
    
    var pokemonId: Int? {
        // Extract ID from URL
        guard let idString = url.split(separator: "/").last else { return nil }
        return Int(String(idString))
    }
}

struct EvolutionDetail: Codable {
    let minLevel: Int?
    let trigger: EvolutionTrigger?
    let item: NamedResource?
    let heldItem: NamedResource?
    let knownMove: NamedResource?
    let knownMoveType: NamedResource?
    let location: NamedResource?
    let minHappiness: Int?
    let minBeauty: Int?
    let minAffection: Int?
    let needsOverworldRain: Bool?
    let partySpecies: NamedResource?
    let partyType: NamedResource?
    let relativePhysicalStats: Int?
    let timeOfDay: String?
    let tradeSpecies: NamedResource?
    let turnUpsideDown: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case minLevel = "min_level"
        case trigger
        case item
        case heldItem = "held_item"
        case knownMove = "known_move"
        case knownMoveType = "known_move_type"
        case location
        case minHappiness = "min_happiness"
        case minBeauty = "min_beauty"
        case minAffection = "min_affection"
        case needsOverworldRain = "needs_overworld_rain"
        case partySpecies = "party_species"
        case partyType = "party_type"
        case relativePhysicalStats = "relative_physical_stats"
        case timeOfDay = "time_of_day"
        case tradeSpecies = "trade_species"
        case turnUpsideDown = "turn_upside_down"
    }
    
    var evolutionDescription: String {
        var description = ""
        
        if let trigger = trigger {
            switch trigger.name {
            case "level-up":
                if let level = minLevel {
                    description = "Level \(level)"
                } else if let happiness = minHappiness {
                    description = "High Friendship (\(happiness))"
                } else if let timeOfDay = timeOfDay {
                    description = "Level up during \(timeOfDay)"
                } else {
                    description = "Level up"
                }
            case "trade":
                if let item = heldItem {
                    description = "Trade holding \(item.name.capitalized)"
                } else {
                    description = "Trade"
                }
            case "use-item":
                if let item = item {
                    description = "Use \(item.name.capitalized)"
                }
            default:
                description = trigger.name.capitalized
            }
        }
        
        return description
    }
}

struct EvolutionTrigger: Codable {
    let name: String
    let url: String
}

struct NamedResource: Codable {
    let name: String
    let url: String
}

// MARK: - Mega Evolution Data
struct MegaEvolution {
    let pokemonId: Int
    let megaStone: String
    let forms: [MegaForm]
    
    struct MegaForm {
        let formType: PokemonFormType
        let spriteUrl: String
        let statsBoost: [String: Int]
        let typeChanges: [PokemonType]?
        let abilityChange: String?
    }
}

// MARK: - Gigantamax Data
struct GigantamaxForm {
    let pokemonId: Int
    let gMaxMove: String
    let spriteUrl: String
    let heightMultiplier: Double
    let signature: String
}

// MARK: - Regional Variant Data
struct RegionalVariant {
    let pokemonId: Int
    let region: String
    let formType: PokemonFormType
    let typeChanges: [PokemonType]
    let spriteUrl: String
    let evolutionChanges: Bool
}

// MARK: - Form Manager
class PokemonFormManager: ObservableObject {
    @Published var availableForms: [PokemonForm] = []
    @Published var currentForm: PokemonForm?
    @Published var isLoadingForms = false
    
    // Fallback hardcoded data (only used if API fails)
    private let megaEvolutions: [Int: [PokemonFormType]] = [
        3: [.mega],        // Venusaur
        6: [.megaX, .megaY], // Charizard
        9: [.mega],        // Blastoise
        15: [.mega],       // Beedrill
        18: [.mega],       // Pidgeot
        65: [.mega],       // Alakazam
        80: [.mega],       // Slowbro
        94: [.mega],       // Gengar
        115: [.mega],      // Kangaskhan
        127: [.mega],      // Pinsir
        130: [.mega],      // Gyarados
        142: [.mega],      // Aerodactyl
        150: [.megaX, .megaY], // Mewtwo
        181: [.mega],      // Ampharos
        212: [.mega],      // Scizor
        214: [.mega],      // Heracross
        229: [.mega],      // Houndoom
        248: [.mega],      // Tyranitar
        254: [.mega],      // Sceptile
        257: [.mega],      // Blaziken
        260: [.mega],      // Swampert
        282: [.mega],      // Gardevoir
        302: [.mega],      // Sableye
        303: [.mega],      // Mawile
        306: [.mega],      // Aggron
        308: [.mega],      // Medicham
        310: [.mega],      // Manectric
        319: [.mega],      // Sharpedo
        323: [.mega],      // Camerupt
        334: [.mega],      // Altaria
        354: [.mega],      // Banette
        359: [.mega],      // Absol
        362: [.mega],      // Glalie
        373: [.mega],      // Salamence
        376: [.mega],      // Metagross
        380: [.mega],      // Latias
        381: [.mega],      // Latios
        382: [.primal],    // Kyogre
        383: [.primal],    // Groudon
        384: [.mega],      // Rayquaza
        428: [.mega],      // Lopunny
        445: [.mega],      // Garchomp
        448: [.mega],      // Lucario
        460: [.mega],      // Abomasnow
        475: [.mega],      // Gallade
        531: [.mega],      // Audino
        719: [.mega],      // Diancie
    ]
    
    private let gigantamaxForms: Set<Int> = [
        3, 6, 9, 12, 25, 52, 68, 94, 99, 131, 143, 569, 823, 834, 839, 841, 842, 844, 849, 851, 858, 861, 869, 879, 884
    ]
    
    private let regionalVariants: [Int: [PokemonFormType]] = [
        19: [.alola],      // Rattata
        20: [.alola],      // Raticate
        26: [.alola],      // Raichu
        27: [.alola],      // Sandshrew
        28: [.alola],      // Sandslash
        37: [.alola],      // Vulpix
        38: [.alola],      // Ninetales
        50: [.alola],      // Diglett
        51: [.alola],      // Dugtrio
        52: [.alola, .galar], // Meowth
        53: [.alola],      // Persian
        74: [.alola],      // Geodude
        75: [.alola],      // Graveler
        76: [.alola],      // Golem
        77: [.galar],      // Ponyta
        78: [.galar],      // Rapidash
        79: [.galar],      // Slowpoke
        80: [.galar],      // Slowbro
        83: [.galar],      // Farfetch'd
        88: [.alola],      // Grimer
        89: [.alola],      // Muk
        103: [.alola],     // Exeggutor
        105: [.alola],     // Marowak
        110: [.galar],     // Weezing
        122: [.galar],     // Mr. Mime
        144: [.galar],     // Articuno
        145: [.galar],     // Zapdos
        146: [.galar],     // Moltres
        199: [.galar],     // Slowking
        222: [.galar],     // Corsola
        263: [.galar],     // Zigzagoon
        264: [.galar],     // Linoone
        554: [.galar],     // Darumaka
        555: [.galar],     // Darmanitan
        562: [.galar],     // Yamask
        618: [.galar],     // Stunfisk
    ]
    
    func loadForms(for pokemonId: Int) {
        Task {
            await loadFormsFromAPI(pokemonId: pokemonId)
        }
    }
    
    @MainActor
    private func loadFormsFromAPI(pokemonId: Int) async {
        isLoadingForms = true
        availableForms = []
        
        do {
            // First, try to load from API
            let forms = try await fetchPokemonForms(pokemonId: pokemonId)
            
            if !forms.isEmpty {
                availableForms = forms
                currentForm = forms.first { $0.isDefault } ?? forms.first
            } else {
                // Fallback to hardcoded data if API returns empty
                loadHardcodedForms(pokemonId: pokemonId)
            }
        } catch {
            // If API fails, use hardcoded data as fallback
            print("Failed to load forms from API: \(error)")
            loadHardcodedForms(pokemonId: pokemonId)
        }
        
        isLoadingForms = false
    }
    
    private func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        // Fetch Pokemon species data for forms
        let speciesURL = "https://pokeapi.co/api/v2/pokemon-species/\(pokemonId)/"
        guard let url = URL(string: speciesURL) else { return [] }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let speciesData = try JSONDecoder().decode(PokemonSpeciesResponse.self, from: data)
        
        var forms: [PokemonForm] = []
        
        // Fetch each form's data
        for variety in speciesData.varieties {
            if let formData = try? await fetchFormData(from: variety.pokemon.url) {
                forms.append(formData)
            }
        }
        
        return forms
    }
    
    private func fetchFormData(from urlString: String) async throws -> PokemonForm? {
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let pokemonData = try JSONDecoder().decode(PokemonResponse.self, from: data)
        
        // Convert API response to our PokemonForm model
        return PokemonForm(
            id: "form-\(pokemonData.id)",
            pokemonId: pokemonData.id,
            name: pokemonData.name,
            formType: determineFormType(from: pokemonData.name),
            sprites: FormSprites(
                frontDefault: pokemonData.sprites.frontDefault,
                frontShiny: pokemonData.sprites.frontShiny,
                backDefault: pokemonData.sprites.backDefault,
                backShiny: pokemonData.sprites.backShiny,
                officialArtwork: pokemonData.sprites.other?.officialArtwork?.frontDefault
            ),
            stats: pokemonData.stats.map { stat in
                PokemonStat(
                    baseStat: stat.baseStat,
                    effort: stat.effort,
                    stat: StatType(name: stat.stat.name, url: stat.stat.url)
                )
            },
            types: pokemonData.types.map { typeSlot in
                PokemonTypeSlot(
                    slot: typeSlot.slot,
                    type: PokemonTypeInfo(name: typeSlot.type.name, url: typeSlot.type.url)
                )
            },
            abilities: pokemonData.abilities.map { abilitySlot in
                PokemonAbilitySlot(
                    isHidden: abilitySlot.isHidden,
                    slot: abilitySlot.slot,
                    ability: PokemonAbility(name: abilitySlot.ability.name, url: abilitySlot.ability.url)
                )
            },
            height: pokemonData.height,
            weight: pokemonData.weight,
            isDefault: pokemonData.isDefault ?? false,
            isBattleOnly: pokemonData.name.contains("-mega") || pokemonData.name.contains("-gmax"),
            formOrder: pokemonData.order
        )
    }
    
    private func determineFormType(from name: String) -> PokemonFormType {
        if name.contains("-mega-x") { return .megaX }
        if name.contains("-mega-y") { return .megaY }
        if name.contains("-mega") { return .mega }
        if name.contains("-gmax") { return .gigantamax }
        if name.contains("-alola") { return .alola }
        if name.contains("-galar") { return .galar }
        if name.contains("-hisui") { return .hisui }
        if name.contains("-paldea") { return .paldea }
        if name.contains("-primal") { return .primal }
        if name.contains("-origin") { return .origin }
        if name.contains("-therian") { return .therian }
        return .normal
    }
    
    private func loadHardcodedForms(pokemonId: Int) {
        // Create base form
        let baseForm = createBaseForm(pokemonId: pokemonId)
        availableForms.append(baseForm)
        currentForm = baseForm
        
        // Check for Mega Evolutions
        if let megaTypes = megaEvolutions[pokemonId] {
            for megaType in megaTypes {
                availableForms.append(createMegaForm(pokemonId: pokemonId, formType: megaType))
            }
        }
        
        // Check for Gigantamax
        if gigantamaxForms.contains(pokemonId) {
            availableForms.append(createGigantamaxForm(pokemonId: pokemonId))
        }
        
        // Check for Regional Variants
        if let regionalTypes = regionalVariants[pokemonId] {
            for regionalType in regionalTypes {
                availableForms.append(createRegionalForm(pokemonId: pokemonId, formType: regionalType))
            }
        }
    }
    
    private func createBaseForm(pokemonId: Int) -> PokemonForm {
        PokemonForm(
            id: "base-\(pokemonId)",
            pokemonId: pokemonId,
            name: "Normal",
            formType: .normal,
            sprites: FormSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png",
                frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/\(pokemonId).png",
                backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/\(pokemonId).png",
                backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/\(pokemonId).png",
                officialArtwork: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId).png"
            ),
            stats: nil,
            types: nil,
            abilities: nil,
            height: nil,
            weight: nil,
            isDefault: true,
            isBattleOnly: false,
            formOrder: 0
        )
    }
    
    private func createMegaForm(pokemonId: Int, formType: PokemonFormType) -> PokemonForm {
        let suffix = formType == .megaX ? "-mega-x" : formType == .megaY ? "-mega-y" : "-mega"
        return PokemonForm(
            id: "mega-\(pokemonId)-\(formType.rawValue)",
            pokemonId: pokemonId,
            name: formType.rawValue,
            formType: formType,
            sprites: FormSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId)\(suffix).png",
                frontShiny: nil,
                backDefault: nil,
                backShiny: nil,
                officialArtwork: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId)\(suffix).png"
            ),
            stats: nil,
            types: nil,
            abilities: nil,
            height: nil,
            weight: nil,
            isDefault: false,
            isBattleOnly: true,
            formOrder: 1
        )
    }
    
    private func createGigantamaxForm(pokemonId: Int) -> PokemonForm {
        PokemonForm(
            id: "gmax-\(pokemonId)",
            pokemonId: pokemonId,
            name: "Gigantamax",
            formType: .gigantamax,
            sprites: FormSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId)-gmax.png",
                frontShiny: nil,
                backDefault: nil,
                backShiny: nil,
                officialArtwork: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId)-gmax.png"
            ),
            stats: nil,
            types: nil,
            abilities: nil,
            height: nil,
            weight: nil,
            isDefault: false,
            isBattleOnly: true,
            formOrder: 2
        )
    }
    
    private func createRegionalForm(pokemonId: Int, formType: PokemonFormType) -> PokemonForm {
        let regionSuffix = formType == .alola ? "-alola" : formType == .galar ? "-galar" : formType == .hisui ? "-hisui" : "-paldea"
        return PokemonForm(
            id: "regional-\(pokemonId)-\(formType.rawValue)",
            pokemonId: pokemonId,
            name: formType.rawValue,
            formType: formType,
            sprites: FormSprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId)\(regionSuffix).png",
                frontShiny: nil,
                backDefault: nil,
                backShiny: nil,
                officialArtwork: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId)\(regionSuffix).png"
            ),
            stats: nil,
            types: nil,
            abilities: nil,
            height: nil,
            weight: nil,
            isDefault: false,
            isBattleOnly: false,
            formOrder: 3
        )
    }
    
    func switchToForm(_ form: PokemonForm) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentForm = form
        }
    }
}