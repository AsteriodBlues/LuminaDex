import Foundation
import SwiftUI
import Nuke
import NukeUI

// MARK: - Image Manager
@MainActor
class ImageManager: ObservableObject {
    static let shared = ImageManager()
    
    // Image pipelines for different sizes
    private let thumbnailPipeline: ImagePipeline
    private let cardPipeline: ImagePipeline
    private let fullPipeline: ImagePipeline
    
    // Placeholder images by type
    private let typePlaceholders: [String: UIImage] = [:]
    
    private init() {
        // Configure thumbnail pipeline (96x96)
        thumbnailPipeline = ImagePipeline {
            $0.imageCache = ImageCache(costLimit: 50 * 1024 * 1024) // 50MB
            $0.dataCache = try? DataCache(name: "LuminaDex.Thumbnails")
        }
        
        // Configure card pipeline (256x256)
        cardPipeline = ImagePipeline {
            $0.imageCache = ImageCache(costLimit: 100 * 1024 * 1024) // 100MB
            $0.dataCache = try? DataCache(name: "LuminaDex.Cards")
            $0.isProgressiveDecodingEnabled = true
        }
        
        // Configure full-size pipeline (512x512)
        fullPipeline = ImagePipeline {
            $0.imageCache = ImageCache(costLimit: 200 * 1024 * 1024) // 200MB
            $0.dataCache = try? DataCache(name: "LuminaDex.Full")
            $0.isProgressiveDecodingEnabled = true
        }
        
        // Set up default configurations
        setupDefaultConfigurations()
    }
    
    private func setupDefaultConfigurations() {
        // Configure global image loading settings
        DataLoader.sharedUrlCache.memoryCapacity = 50 * 1024 * 1024 // 50MB
        DataLoader.sharedUrlCache.diskCapacity = 500 * 1024 * 1024 // 500MB
    }
    
    // MARK: - Image Loading Methods
    
    /// Load thumbnail image (96x96)
    func loadThumbnail(url: String?) -> AnyView {
        if let urlString = url, let imageURL = URL(string: urlString) {
            return AnyView(
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 96, height: 96)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(width: 96, height: 96)
                    } else {
                        ProgressView()
                            .frame(width: 96, height: 96)
                    }
                }
                .pipeline(thumbnailPipeline)
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 96, height: 96)
            )
        }
    }
    
    /// Load card image (256x256)
    func loadCard(url: String?) -> AnyView {
        if let urlString = url, let imageURL = URL(string: urlString) {
            return AnyView(
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 256, height: 256)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(width: 256, height: 256)
                    } else {
                        ProgressView()
                            .frame(width: 256, height: 256)
                    }
                }
                .pipeline(cardPipeline)
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 256, height: 256)
            )
        }
    }
    
    /// Load full-size image (512x512)
    func loadFull(url: String?) -> AnyView {
        if let urlString = url, let imageURL = URL(string: urlString) {
            return AnyView(
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 512, maxHeight: 512)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(width: 512, height: 512)
                    } else {
                        ProgressView()
                            .frame(width: 512, height: 512)
                    }
                }
                .pipeline(fullPipeline)
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 512, height: 512)
            )
        }
    }
    
    // MARK: - Pokemon-specific Image Loading
    
    /// Load Pokemon sprite with fallbacks
    func loadPokemonSprite(sprites: PokemonSpriteRecord?, size: ImageSize = .card, shiny: Bool = false, female: Bool = false) -> some View {
        let spriteURL = getPokemonSpriteURL(sprites: sprites, shiny: shiny, female: female)
        
        switch size {
        case .thumbnail:
            return AnyView(loadThumbnail(url: spriteURL))
        case .card:
            return AnyView(loadCard(url: spriteURL))
        case .full:
            return AnyView(loadFull(url: spriteURL))
        }
    }
    
    /// Load Pokemon official artwork
    func loadPokemonArtwork(sprites: PokemonSpriteRecord?, size: ImageSize = .full, shiny: Bool = false) -> some View {
        let artworkURL = shiny ? sprites?.officialArtworkShiny : sprites?.officialArtworkDefault
        let fallbackURL = getPokemonSpriteURL(sprites: sprites, shiny: shiny, female: false)
        
        let finalURL = artworkURL ?? fallbackURL
        
        switch size {
        case .thumbnail:
            return AnyView(loadThumbnail(url: finalURL))
        case .card:
            return AnyView(loadCard(url: finalURL))
        case .full:
            return AnyView(loadFull(url: finalURL))
        }
    }
    
    private func getPokemonSpriteURL(sprites: PokemonSpriteRecord?, shiny: Bool, female: Bool) -> String? {
        guard let sprites = sprites else { return nil }
        
        // Priority order for sprite selection
        if shiny && female {
            return sprites.frontShinyFemale ?? sprites.frontShiny ?? sprites.frontFemale ?? sprites.frontDefault
        } else if shiny {
            return sprites.frontShiny ?? sprites.frontDefault
        } else if female {
            return sprites.frontFemale ?? sprites.frontDefault
        } else {
            return sprites.frontDefault
        }
    }
    
    // MARK: - Cache Management
    
    func clearAllCaches() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                self?.thumbnailPipeline.cache.removeAll()
            }
            
            group.addTask { [weak self] in
                self?.cardPipeline.cache.removeAll()
            }
            
            group.addTask { [weak self] in
                self?.fullPipeline.cache.removeAll()
            }
        }
        
        print("✅ All image caches cleared")
    }
    
    func getCacheInfo() -> ImageCacheInfo {
        let thumbnailSize = 0 // Cache info not available in current Nuke version
        let cardSize = 0
        let fullSize = 0
        
        return ImageCacheInfo(
            thumbnailCacheSize: thumbnailSize,
            cardCacheSize: cardSize,
            fullCacheSize: fullSize,
            totalCacheSize: thumbnailSize + cardSize + fullSize
        )
    }
    
    // MARK: - Preloading
    
    func preloadPokemonImages(pokemon: [PokemonRecord], sprites: [PokemonSpriteRecord]) async {
        let urls = sprites.compactMap { $0.frontDefault }.compactMap { URL(string: $0) }
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask { [weak self] in
                    let request = ImageRequest(url: url)
                    try? await self?.thumbnailPipeline.image(for: request)
                }
            }
        }
        
        print("✅ Preloaded \(urls.count) Pokemon images")
    }
    
    // MARK: - Type Placeholders
    
    func getTypePlaceholder(typeName: String) -> UIImage? {
        return typePlaceholders[typeName]
    }
    
    func generateTypeBlurHash(typeName: String, color: String) -> String {
        // Generate blur hash based on type color
        // This is a simplified implementation
        return "L6Pj0^jE.AyE_3t7t7R**0o#DgR4"
    }
}


// MARK: - Supporting Types

enum ImageSize {
    case thumbnail // 96x96
    case card      // 256x256
    case full      // 512x512
}

struct ImageCacheInfo {
    let thumbnailCacheSize: Int
    let cardCacheSize: Int
    let fullCacheSize: Int
    let totalCacheSize: Int
    
    var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalCacheSize))
    }
}

// MARK: - SwiftUI Extensions

extension View {
    func pokemonSprite(sprites: PokemonSpriteRecord?, size: ImageSize = .card, shiny: Bool = false, female: Bool = false) -> some View {
        ImageManager.shared.loadPokemonSprite(sprites: sprites, size: size, shiny: shiny, female: female)
    }
    
    func pokemonArtwork(sprites: PokemonSpriteRecord?, size: ImageSize = .full, shiny: Bool = false) -> some View {
        ImageManager.shared.loadPokemonArtwork(sprites: sprites, size: size, shiny: shiny)
    }
}