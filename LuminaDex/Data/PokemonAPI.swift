import Foundation
import Combine

// MARK: - Pokemon API Client
@MainActor
class PokemonAPI: ObservableObject {
    static let shared = PokemonAPI()
    
    private let baseURL = "https://pokeapi.co/api/v2"
    private let session: URLSession
    private let cache: URLCache
    
    // Rate limiting
    private let minimumRequestInterval: TimeInterval = 0.1 // 100ms between requests
    private let rateLimiter = RateLimiter(minimumInterval: 0.1)
    
    private init() {
        // Configure cache
        let cacheSize = 50 * 1024 * 1024 // 50MB cache
        self.cache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
        
        // Configure session
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Main API Methods
    
    /// Fetch a Pokemon by ID or name
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let endpoint = "\(baseURL)/pokemon/\(id)"
        return try await performRequest(url: endpoint, type: Pokemon.self)
    }
    
    func fetchPokemon(name: String) async throws -> Pokemon {
        let endpoint = "\(baseURL)/pokemon/\(name.lowercased())"
        return try await performRequest(url: endpoint, type: Pokemon.self)
    }
    
    /// Fetch multiple Pokemon (for lists)
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        let endpoint = "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        return try await performRequest(url: endpoint, type: PokemonListResponse.self)
    }
    
    /// Fetch Pokemon by generation
    func fetchGeneration(id: Int) async throws -> Generation {
        let endpoint = "\(baseURL)/generation/\(id)"
        return try await performRequest(url: endpoint, type: Generation.self)
    }
    
    /// Fetch region data
    func fetchRegion(name: String) async throws -> Region {
        let endpoint = "\(baseURL)/region/\(name.lowercased())"
        return try await performRequest(url: endpoint, type: Region.self)
    }
    
    /// Fetch all regions
    func fetchAllRegions() async throws -> RegionListResponse {
        let endpoint = "\(baseURL)/region"
        return try await performRequest(url: endpoint, type: RegionListResponse.self)
    }
    
    /// Search Pokemon by type
    func fetchPokemonByType(_ type: PokemonType) async throws -> TypeResponse {
        let endpoint = "\(baseURL)/type/\(type.rawValue)"
        return try await performRequest(url: endpoint, type: TypeResponse.self)
    }
    
    // MARK: - Core Request Method
    
    private func performRequest<T: Codable>(url: String, type: T.Type) async throws -> T {
        // Rate limiting
        await rateLimiter.waitForNextRequest()
        
        guard let requestURL = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("LuminaDx/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("❌ Decoding error for \(url): \(error)")
                    throw APIError.decodingError(error)
                }
            case 404:
                throw APIError.notFound
            case 429:
                throw APIError.rateLimited
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.httpError(httpResponse.statusCode)
            }
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        cache.removeAllCachedResponses()
    }
    
    func getCacheSize() -> Int {
        return cache.currentDiskUsage
    }
}

// MARK: - Rate Limiter Actor
actor RateLimiter {
    private var lastRequestTime: Date = Date.distantPast
    private let minimumInterval: TimeInterval
    
    init(minimumInterval: TimeInterval) {
        self.minimumInterval = minimumInterval
    }
    
    func waitForNextRequest() async {
        let now = Date()
        let timeSinceLastRequest = now.timeIntervalSince(lastRequestTime)
        
        if timeSinceLastRequest < minimumInterval {
            let delay = minimumInterval - timeSinceLastRequest
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        lastRequestTime = Date()
    }
}

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case rateLimited
    case serverError
    case networkError(Error)
    case decodingError(Error)
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Pokemon not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Check the Pokemon name or ID and try again."
        case .rateLimited:
            return "Wait a moment before making another request."
        case .networkError:
            return "Check your internet connection and try again."
        case .serverError:
            return "The Pokemon API may be experiencing issues."
        default:
            return "Please try again."
        }
    }
}

// MARK: - Response Models

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: Int {
        // Extract ID from URL like "https://pokeapi.co/api/v2/pokemon/1/"
        let components = url.components(separatedBy: "/")
        return Int(components[components.count - 2]) ?? 0
    }
    
    var displayName: String {
        name.capitalized
    }
}

struct RegionListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RegionListItem]
}

struct RegionListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: Int {
        let components = url.components(separatedBy: "/")
        return Int(components[components.count - 2]) ?? 0
    }
    
    var displayName: String {
        name.capitalized
    }
}

struct Generation: Codable {
    let id: Int
    let name: String
    let abilities: [GenerationAbility]
    let names: [GenerationName]
    let mainRegion: GenerationRegion
    let moves: [GenerationMove]
    let pokemonSpecies: [GenerationPokemonSpecies]
    let types: [GenerationType]
    let versionGroups: [GenerationVersionGroup]
}

struct GenerationAbility: Codable {
    let name: String
    let url: String
}

struct GenerationName: Codable {
    let name: String
    let language: GenerationLanguage
}

struct GenerationLanguage: Codable {
    let name: String
    let url: String
}

struct GenerationRegion: Codable {
    let name: String
    let url: String
}

struct GenerationMove: Codable {
    let name: String
    let url: String
}

struct GenerationPokemonSpecies: Codable {
    let name: String
    let url: String
}

struct GenerationType: Codable {
    let name: String
    let url: String
}

struct GenerationVersionGroup: Codable {
    let name: String
    let url: String
}

struct TypeResponse: Codable {
    let id: Int
    let name: String
    let damageRelations: TypeDamageRelations
    let gameIndices: [TypeGameIndex]
    let generation: TypeGeneration
    let moveDamageClass: TypeMoveDamageClass?
    let names: [TypeName]
    let pokemon: [TypePokemon]
    let moves: [TypeMove]
}

struct TypeDamageRelations: Codable {
    let noDamageTo: [TypeRelation]
    let halfDamageTo: [TypeRelation]
    let doubleDamageTo: [TypeRelation]
    let noDamageFrom: [TypeRelation]
    let halfDamageFrom: [TypeRelation]
    let doubleDamageFrom: [TypeRelation]
}

struct TypeRelation: Codable {
    let name: String
    let url: String
}

struct TypeGameIndex: Codable {
    let gameIndex: Int
    let generation: TypeGeneration
}

struct TypeGeneration: Codable {
    let name: String
    let url: String
}

struct TypeMoveDamageClass: Codable {
    let name: String
    let url: String
}

struct TypeName: Codable {
    let name: String
    let language: TypeLanguage
}

struct TypeLanguage: Codable {
    let name: String
    let url: String
}

struct TypePokemon: Codable {
    let slot: Int
    let pokemon: TypePokemonDetail
}

struct TypePokemonDetail: Codable {
    let name: String
    let url: String
}

struct TypeMove: Codable {
    let name: String
    let url: String
}
