//
//  BerryFetcher.swift
//  LuminaDex
//
//  Fetches berry data from PokeAPI
//

import Foundation

class BerryFetcher {
    private let baseURL = "https://pokeapi.co/api/v2/berry"
    private let session = URLSession.shared
    private var cache: [Int: Berry] = [:]
    
    // MARK: - Fetch All Berries
    func fetchAllBerries() async throws -> [Berry] {
        // First, get the list of all berries
        let listURL = URL(string: baseURL + "?limit=100")!
        let (data, _) = try await session.data(from: listURL)
        let response = try JSONDecoder().decode(BerryListResponse.self, from: data)
        
        // Fetch each berry in parallel
        return try await withThrowingTaskGroup(of: Berry?.self) { group in
            for berryRef in response.results {
                group.addTask {
                    // Extract ID from URL
                    guard let id = self.extractID(from: berryRef.url) else { return nil }
                    return try await self.fetchBerry(id: id)
                }
            }
            
            var berries: [Berry] = []
            for try await berry in group {
                if let berry = berry {
                    berries.append(berry)
                }
            }
            
            return berries.sorted { $0.id < $1.id }
        }
    }
    
    // MARK: - Fetch Single Berry
    func fetchBerry(id: Int) async throws -> Berry {
        // Check cache first
        if let cached = cache[id] {
            return cached
        }
        
        let url = URL(string: "\(baseURL)/\(id)")!
        let (data, _) = try await session.data(from: url)
        let apiResponse = try JSONDecoder().decode(ApiBerryResponse.self, from: data)
        
        // Fetch item details for effect
        let itemData = try await fetchBerryItem(url: apiResponse.item.url)
        
        // Convert API response to our Berry model
        let berry = Berry(
            id: apiResponse.id,
            name: apiResponse.name,
            growthTime: apiResponse.growthTime,
            maxHarvest: apiResponse.maxHarvest,
            naturalGiftPower: apiResponse.naturalGiftPower,
            naturalGiftType: mapTypeFromName(apiResponse.naturalGiftType?.name),
            size: apiResponse.size,
            smoothness: apiResponse.smoothness,
            soilDryness: apiResponse.soilDryness,
            firmness: apiResponse.firmness.name,
            flavors: BerryFlavors(
                spicy: apiResponse.flavors.first { $0.flavor.name == "spicy" }?.potency ?? 0,
                dry: apiResponse.flavors.first { $0.flavor.name == "dry" }?.potency ?? 0,
                sweet: apiResponse.flavors.first { $0.flavor.name == "sweet" }?.potency ?? 0,
                bitter: apiResponse.flavors.first { $0.flavor.name == "bitter" }?.potency ?? 0,
                sour: apiResponse.flavors.first { $0.flavor.name == "sour" }?.potency ?? 0
            ),
            item: BerryItem(
                name: itemData.name,
                effect: itemData.effectEntries.first { $0.language.name == "en" }?.effect ?? "Unknown effect",
                shortEffect: itemData.effectEntries.first { $0.language.name == "en" }?.shortEffect ?? "Unknown",
                cost: itemData.cost,
                attributes: itemData.attributes.map { $0.name }
            )
        )
        
        cache[id] = berry
        return berry
    }
    
    // MARK: - Fetch Berry Item
    private func fetchBerryItem(url: String) async throws -> ApiBerryItemResponse {
        let itemURL = URL(string: url)!
        let (data, _) = try await session.data(from: itemURL)
        return try JSONDecoder().decode(ApiBerryItemResponse.self, from: data)
    }
    
    // MARK: - Helper Methods
    private func extractID(from url: String) -> Int? {
        let components = url.split(separator: "/")
        guard let idString = components.last else { return nil }
        return Int(idString)
    }
    
    private func mapTypeFromName(_ name: String?) -> PokemonType? {
        guard let name = name else { return nil }
        switch name {
        case "normal": return .normal
        case "fighting": return .fighting
        case "flying": return .flying
        case "poison": return .poison
        case "ground": return .ground
        case "rock": return .rock
        case "bug": return .bug
        case "ghost": return .ghost
        case "steel": return .steel
        case "fire": return .fire
        case "water": return .water
        case "grass": return .grass
        case "electric": return .electric
        case "psychic": return .psychic
        case "ice": return .ice
        case "dragon": return .dragon
        case "dark": return .dark
        case "fairy": return .fairy
        default: return nil
        }
    }
}

// MARK: - API Response Models
struct BerryListResponse: Codable {
    let count: Int
    let results: [BerryReference]
    
    struct BerryReference: Codable {
        let name: String
        let url: String
    }
}

struct ApiBerryResponse: Codable {
    let id: Int
    let name: String
    let growthTime: Int
    let maxHarvest: Int
    let naturalGiftPower: Int
    let naturalGiftType: TypeReference?
    let size: Int
    let smoothness: Int
    let soilDryness: Int
    let firmness: FirmnessReference
    let flavors: [FlavorReference]
    let item: ItemReference
    
    private enum CodingKeys: String, CodingKey {
        case id, name, size, smoothness, flavors, item, firmness
        case growthTime = "growth_time"
        case maxHarvest = "max_harvest"
        case naturalGiftPower = "natural_gift_power"
        case naturalGiftType = "natural_gift_type"
        case soilDryness = "soil_dryness"
    }
    
    struct TypeReference: Codable {
        let name: String
        let url: String
    }
    
    struct FirmnessReference: Codable {
        let name: String
        let url: String
    }
    
    struct FlavorReference: Codable {
        let potency: Int
        let flavor: FlavorName
        
        struct FlavorName: Codable {
            let name: String
            let url: String
        }
    }
    
    struct ItemReference: Codable {
        let name: String
        let url: String
    }
}

struct ApiBerryItemResponse: Codable {
    let id: Int
    let name: String
    let cost: Int
    let attributes: [AttributeReference]
    let effectEntries: [EffectEntry]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, cost, attributes
        case effectEntries = "effect_entries"
    }
    
    struct AttributeReference: Codable {
        let name: String
        let url: String
    }
    
    struct EffectEntry: Codable {
        let effect: String
        let shortEffect: String
        let language: LanguageReference
        
        private enum CodingKeys: String, CodingKey {
            case effect
            case shortEffect = "short_effect"
            case language
        }
        
        struct LanguageReference: Codable {
            let name: String
            let url: String
        }
    }
}