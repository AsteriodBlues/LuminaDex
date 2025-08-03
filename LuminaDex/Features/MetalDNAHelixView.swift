//
//  MetalDNAHelixView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//
import SwiftUI
import MetalKit

// MARK: - Metal DNA Helix View

struct MetalDNAHelixView: UIViewRepresentable {
    let pokemon: Pokemon
    let rotationAngle: CGFloat
    let zoomLevel: CGFloat
    let selectedGene: DNAGene?
    let animationPhase: CGFloat
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isOpaque = false
        metalView.framebufferOnly = false
        
        let renderer = DNAHelixRenderer()
        renderer.mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
        metalView.delegate = renderer
        
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        if let renderer = uiView.delegate as? DNAHelixRenderer {
            renderer.updateDNAHelix(
                pokemon: pokemon,
                rotation: rotationAngle,
                zoom: zoomLevel,
                selectedGene: selectedGene,
                animationPhase: animationPhase
            )
        }
    }
}

// MARK: - DNA Helix Renderer

class DNAHelixRenderer: NSObject, MTKViewDelegate {
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    
    private var currentPokemon: Pokemon?
    private var rotation: Float = 0
    private var zoom: Float = 1.0
    private var selectedGene: DNAGene?
    private var animationPhase: Float = 0
    
    override init() {
        super.init()
        setupMetal()
    }
    
    private func setupMetal() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "dna_vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "dna_fragment_shader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }
    
    func updateDNAHelix(pokemon: Pokemon, rotation: CGFloat, zoom: CGFloat, selectedGene: DNAGene?, animationPhase: CGFloat) {
        self.currentPokemon = pokemon
        self.rotation = Float(rotation)
        self.zoom = Float(zoom)
        self.selectedGene = selectedGene
        self.animationPhase = Float(animationPhase)
        
        generateDNAGeometry()
    }
    
    private func generateDNAGeometry() {
        guard let pokemon = currentPokemon else { return }
        
        var vertices: [DNAVertex] = []
        let helixHeight: Float = 4.0
        let radius: Float = 1.0
        let numSegments = 200
        let numBasePairs = 50
        
        // Generate DNA helix vertices
        for i in 0..<numSegments {
            let t = Float(i) / Float(numSegments - 1)
            let angle = t * Float.pi * 8 // Multiple turns
            let y = (t - 0.5) * helixHeight
            
            // First strand
            let x1 = cos(angle) * radius
            let z1 = sin(angle) * radius
            
            // Second strand (180 degrees offset)
            let x2 = cos(angle + Float.pi) * radius
            let z2 = sin(angle + Float.pi) * radius
            
            // Color based on Pokemon type
            let typeColor = getTypeColor(for: pokemon.primaryType, at: t)
            
            vertices.append(DNAVertex(position: [x1, y, z1], color: typeColor))
            vertices.append(DNAVertex(position: [x2, y, z2], color: typeColor))
            
            // Base pairs (connecting strands)
            if i % (numSegments / numBasePairs) == 0 {
                let baseColor = getBaseColor(at: i / (numSegments / numBasePairs))
                vertices.append(DNAVertex(position: [x1, y, z1], color: baseColor))
                vertices.append(DNAVertex(position: [x2, y, z2], color: baseColor))
            }
        }
        
        let bufferLength = vertices.count * MemoryLayout<DNAVertex>.size
        vertexBuffer = device.makeBuffer(bytes: vertices, length: bufferLength, options: [])
    }
    
    private func getTypeColor(for type: PokemonType, at position: Float) -> [Float] {
        let baseColor = type.color
        let intensity = 0.7 + sin(position * Float.pi * 4 + animationPhase) * 0.3
        
        // Convert SwiftUI Color to RGB float array
        return [0.4, 0.6, 1.0, intensity] // Simplified blue for now
    }
    
    private func getBaseColor(at index: Int) -> [Float] {
        // Different colors for different base pairs (A-T, G-C)
        let colors: [[Float]] = [
            [1.0, 0.2, 0.2, 0.8], // Red (A-T)
            [0.2, 1.0, 0.2, 0.8], // Green (G-C)
            [0.2, 0.2, 1.0, 0.8], // Blue (C-G)
            [1.0, 1.0, 0.2, 0.8]  // Yellow (T-A)
        ]
        return colors[index % colors.count]
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size changes
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        // Clear with transparent background
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        if let vertexBuffer = vertexBuffer {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            // Set uniforms for rotation, zoom, etc.
            var uniforms = DNAUniforms(
                rotation: rotation,
                zoom: zoom,
                animationPhase: animationPhase,
                time: Float(CACurrentMediaTime())
            )
            
            renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<DNAUniforms>.size, index: 1)
            
            let vertexCount = vertexBuffer.length / MemoryLayout<DNAVertex>.size
            renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - DNA Data Models

struct DNAVertex {
    let position: [Float]
    let color: [Float]
}

struct DNAUniforms {
    let rotation: Float
    let zoom: Float
    let animationPhase: Float
    let time: Float
}

struct DNAGene: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let description: String
    let associatedType: PokemonType
    let expressionLevel: Double
    let position: Int
    
    static func generateGenes(for pokemon: Pokemon) -> [DNAGene] {
        var genes: [DNAGene] = []
        
        // Generate genes based on Pokemon types and stats
        let primaryType = pokemon.primaryType
        
        // Type-specific genes
        genes.append(DNAGene(
            name: "\(primaryType.displayName) Core Gene",
            code: "TCG",
            description: "Primary type expression controlling \(primaryType.displayName) abilities",
            associatedType: primaryType,
            expressionLevel: 0.9,
            position: 10
        ))
        
        // Stat-based genes
        genes.append(DNAGene(
            name: "Power Gene",
            code: "ATK",
            description: "Controls physical and special attack capabilities",
            associatedType: .fighting,
            expressionLevel: 0.7,
            position: 25
        ))
        
        genes.append(DNAGene(
            name: "Resilience Gene",
            code: "DEF",
            description: "Defensive capabilities and damage resistance",
            associatedType: .steel,
            expressionLevel: 0.6,
            position: 40
        ))
        
        // Secondary type gene (if exists)
        if pokemon.types.count > 1 {
            let secondaryType = pokemon.types[1].type
            genes.append(DNAGene(
                name: "\(secondaryType.displayName) Support Gene",
                code: "SUP",
                description: "Secondary type support and hybrid abilities",
                associatedType: secondaryType,
                expressionLevel: 0.5,
                position: 55
            ))
        }
        
        return genes
    }
}

// MARK: - Lab Assistant Manager

class LabAssistantManager: ObservableObject {
    @Published var alakazam: LabAssistant
    @Published var porygon: LabAssistant
    @Published var magnezone: LabAssistant
    
    init() {
        alakazam = LabAssistant(
            name: "Alakazam",
            sprite: "🧠",
            primaryColor: .purple,
            specialty: .psychicAnalysis,
            currentAction: "Analyzing DNA patterns",
            animationSpeed: 1.5,
            phaseOffset: 0
        )
        
        porygon = LabAssistant(
            name: "Porygon",
            sprite: "🔹",
            primaryColor: .cyan,
            specialty: .dataProcessing,
            currentAction: "Computing gene sequences",
            animationSpeed: 2.0,
            phaseOffset: .pi / 2
        )
        
        magnezone = LabAssistant(
            name: "Magnezone",
            sprite: "⚡",
            primaryColor: .yellow,
            specialty: .electricalScan,
            currentAction: "Electromagnetic scanning",
            animationSpeed: 1.2,
            phaseOffset: .pi
        )
    }
    
    func initializeAssistants() {
        alakazam.isActive = true
        porygon.isActive = true
        magnezone.isActive = true
    }
    
    func startAnalysis() {
        alakazam.currentAction = "Deep analysis mode"
        porygon.currentAction = "Processing data"
        magnezone.currentAction = "Full spectrum scan"
    }
    
    func completeAnalysis() {
        alakazam.currentAction = "Analysis complete"
        porygon.currentAction = "Data processed"
        magnezone.currentAction = "Scan finished"
    }
    
    func triggerSpecialAction(_ action: SpecialAction) {
        switch action {
        case .deepScan:
            magnezone.currentAction = "Deep scanning..."
        case .geneFusion:
            alakazam.currentAction = "Calculating fusion..."
        case .dataExport:
            porygon.currentAction = "Exporting data..."
        }
    }
}

enum SpecialAction {
    case deepScan, geneFusion, dataExport
}

struct LabAssistant {
    let name: String
    let sprite: String
    let primaryColor: Color
    let specialty: AssistantSpecialty
    var currentAction: String
    var isActive: Bool = false
    let animationSpeed: CGFloat
    let phaseOffset: CGFloat
}

enum AssistantSpecialty {
    case psychicAnalysis, dataProcessing, electricalScan
}

// MARK: - DNA Analyzer

class DNAAnalyzer: ObservableObject {
    @Published var geneSequence: [DNAGene] = []
    @Published var analysisResults: [AnalysisResult] = []
    
    func analyzePokemon(_ pokemon: Pokemon) {
        geneSequence = DNAGene.generateGenes(for: pokemon)
        
        analysisResults = [
            AnalysisResult(title: "Type Purity", value: "94.7%"),
            AnalysisResult(title: "Gene Stability", value: "High"),
            AnalysisResult(title: "Mutation Rate", value: "0.03%"),
            AnalysisResult(title: "Expression Level", value: "Optimal"),
            AnalysisResult(title: "Compatibility", value: "Universal")
        ]
    }
}

struct AnalysisResult {
    let title: String
    let value: String
}

// MARK: - Preview

#Preview {
    DNAHelixViewer(
        pokemon: Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            baseExperience: 112,
            order: 35,
            isDefault: true,
            sprites: PokemonSprites(
                frontDefault: "placeholder",
                frontShiny: nil,
                frontFemale: nil,
                frontShinyFemale: nil,
                backDefault: nil,
                backShiny: nil,
                backFemale: nil,
                backShinyFemale: nil,
                other: nil
            ),
            types: [
                PokemonTypeSlot(slot: 1, type: .electric)
            ],
            abilities: [],
            stats: [],
            species: PokemonSpecies(name: "pikachu", url: ""),
            moves: [],
            gameIndices: []
        )
    )
    .preferredColorScheme(.dark)
}
