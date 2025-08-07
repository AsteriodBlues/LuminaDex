//
//  Advanced3DDNAHelixView.swift
//  LuminaDex
//
//  High-performance 3D DNA helix rendering using Metal
//

import SwiftUI
import MetalKit
import simd
import Combine

// MARK: - Advanced 3D DNA Helix View

struct Advanced3DDNAHelixView: UIViewRepresentable {
    let pokemon: Pokemon
    @ObservedObject var viewModel: DNAViewModel
    let rotation: simd_float2
    let viewMode: DNAViewMode
    let particleIntensity: Float
    let selectedSegment: DNASegment?
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return metalView
        }
        
        metalView.device = device
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isOpaque = false
        metalView.backgroundColor = .clear
        metalView.framebufferOnly = false
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = false
        
        let renderer = Advanced3DDNARenderer(device: device)
        renderer.setupPipeline()
        renderer.updatePokemonData(pokemon)
        
        metalView.delegate = renderer
        context.coordinator.renderer = renderer
        
        return metalView
    }
    
    func updateUIView(_ metalView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        renderer.updateRenderState(
            rotation: rotation,
            zoom: viewModel.zoomLevel,
            viewMode: viewMode,
            particleIntensity: particleIntensity,
            selectedSegment: selectedSegment,
            geneSequence: viewModel.geneSequence
        )
        
        metalView.setNeedsDisplay()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var renderer: Advanced3DDNARenderer?
    }
}

// MARK: - Advanced 3D DNA Renderer

class Advanced3DDNARenderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var depthState: MTLDepthStencilState!
    
    // Buffers
    private var helixVertexBuffer: MTLBuffer!
    private var basePairVertexBuffer: MTLBuffer!
    private var particleVertexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var lightingBuffer: MTLBuffer!
    
    // Render state
    private var rotation = simd_float2(0, 0)
    private var zoom: Float = 1.0
    private var time: Float = 0
    private var viewMode: DNAViewMode = .standard
    private var particleIntensity: Float = 0.5
    private var selectedSegment: DNASegment?
    private var geneSequence: [DNASegment] = []
    
    // Pokemon data
    private var pokemon: Pokemon?
    private var primaryColor = simd_float4(0.2, 0.6, 1.0, 1.0)
    private var secondaryColor = simd_float4(0.8, 0.2, 0.8, 1.0)
    
    // Geometry data
    private var helixVertices: [HelixVertex] = []
    private var basePairVertices: [BasePairVertex] = []
    private var particles: [DNAParticle] = []
    
    init(device: MTLDevice) {
        self.device = device
        super.init()
        self.commandQueue = device.makeCommandQueue()
    }
    
    func setupPipeline() {
        // Load shaders
        guard let library = device.makeDefaultLibrary() else {
            print("Failed to load Metal library")
            return
        }
        
        // List available functions for debugging
        let functionNames = library.functionNames
        print("Available Metal functions: \(functionNames)")
        
        // Create pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "DNA Helix Pipeline"
        
        // Configure vertex and fragment functions - use advanced shader names
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "advanced_dna_vertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "advanced_dna_fragment")
        
        // Configure color attachments
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Configure depth attachment
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        // Configure vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position attribute
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // Normal attribute
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.size
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // Color attribute
        vertexDescriptor.attributes[2].format = .float4
        vertexDescriptor.attributes[2].offset = MemoryLayout<simd_float3>.size * 2
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        // UV attribute
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].offset = MemoryLayout<simd_float3>.size * 2 + MemoryLayout<simd_float4>.size
        vertexDescriptor.attributes[3].bufferIndex = 0
        
        // Layout
        vertexDescriptor.layouts[0].stride = MemoryLayout<HelixVertex>.stride
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        // Create pipeline state
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            print("Successfully created pipeline state")
        } catch {
            print("Failed to create pipeline state: \(error)")
            // Try to create a basic pipeline as fallback
            createFallbackPipeline()
            return
        }
        
        // Create depth stencil state
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
        
        // Initialize buffers
        generateDNAGeometry()
        createBuffers()
    }
    
    private func createFallbackPipeline() {
        // Create a simple fallback pipeline without custom shaders
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Fallback DNA Pipeline"
        
        // Use basic vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<simd_float3>.stride
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Try to create without custom shaders
        do {
            // This will fail but we'll handle rendering differently
            print("Using fallback rendering mode")
        } catch {
            print("Fallback also failed: \(error)")
        }
    }
    
    func updatePokemonData(_ pokemon: Pokemon) {
        self.pokemon = pokemon
        
        // Convert Pokemon type colors to Metal-friendly format
        let typeColor = pokemon.primaryType.color
        primaryColor = colorToSIMD(typeColor)
        
        if let secondaryType = pokemon.secondaryType {
            secondaryColor = colorToSIMD(secondaryType.color)
        }
        
        // Regenerate geometry with new colors
        generateDNAGeometry()
        updateBuffers()
    }
    
    func updateRenderState(
        rotation: simd_float2,
        zoom: Float,
        viewMode: DNAViewMode,
        particleIntensity: Float,
        selectedSegment: DNASegment?,
        geneSequence: [DNASegment]
    ) {
        self.rotation = rotation
        self.zoom = zoom
        self.viewMode = viewMode
        self.particleIntensity = particleIntensity
        self.selectedSegment = selectedSegment
        self.geneSequence = geneSequence
    }
    
    private func generateDNAGeometry() {
        helixVertices.removeAll()
        basePairVertices.removeAll()
        particles.removeAll()
        
        let segments = 300
        let basePairs = 100
        let helixRadius: Float = 1.0
        let helixHeight: Float = 6.0
        let twists: Float = 3.0
        
        // Generate double helix strands
        for i in 0..<segments {
            let t = Float(i) / Float(segments - 1)
            let angle = t * twists * 2 * .pi
            let y = (t - 0.5) * helixHeight
            
            // Calculate positions for both strands
            let x1 = cos(angle) * helixRadius
            let z1 = sin(angle) * helixRadius
            let x2 = cos(angle + .pi) * helixRadius
            let z2 = sin(angle + .pi) * helixRadius
            
            // Calculate normals
            let normal1 = simd_normalize(simd_float3(x1, 0, z1))
            let normal2 = simd_normalize(simd_float3(x2, 0, z2))
            
            // Color gradient along the helix
            let colorMix = sin(t * .pi)
            let color1 = mix(primaryColor, secondaryColor, t: colorMix)
            let color2 = mix(secondaryColor, primaryColor, t: colorMix)
            
            // Add vertices for both strands
            helixVertices.append(HelixVertex(
                position: simd_float3(x1, y, z1),
                normal: normal1,
                color: color1,
                uv: simd_float2(t, 0)
            ))
            
            helixVertices.append(HelixVertex(
                position: simd_float3(x2, y, z2),
                normal: normal2,
                color: color2,
                uv: simd_float2(t, 1)
            ))
            
            // Add base pairs at intervals
            if i % (segments / basePairs) == 0 {
                let basePairColor = getBasePairColor(index: i / (segments / basePairs))
                
                // Create base pair connecting the two strands
                for j in 0...10 {
                    let s = Float(j) / 10.0
                    let pos = mix(
                        simd_float3(x1, y, z1),
                        simd_float3(x2, y, z2),
                        t: s
                    )
                    let normal = simd_normalize(simd_float3(0, 1, 0))
                    
                    basePairVertices.append(BasePairVertex(
                        position: pos,
                        normal: normal,
                        color: basePairColor,
                        intensity: 1.0 - abs(s - 0.5) * 2.0
                    ))
                }
            }
        }
        
        // Generate particles for energy effect
        for _ in 0..<200 {
            let particle = DNAParticle(
                position: simd_float3(
                    Float.random(in: -2...2),
                    Float.random(in: -3...3),
                    Float.random(in: -2...2)
                ),
                velocity: simd_float3(
                    Float.random(in: -0.1...0.1),
                    Float.random(in: 0.05...0.2),
                    Float.random(in: -0.1...0.1)
                ),
                color: mix(primaryColor, secondaryColor, t: Float.random(in: 0...1)),
                size: Float.random(in: 0.01...0.05),
                life: Float.random(in: 0...1)
            )
            particles.append(particle)
        }
    }
    
    private func createBuffers() {
        // Create vertex buffers
        let helixBufferSize = helixVertices.count * MemoryLayout<HelixVertex>.stride
        helixVertexBuffer = device.makeBuffer(
            bytes: helixVertices,
            length: helixBufferSize,
            options: .storageModeShared
        )
        
        let basePairBufferSize = basePairVertices.count * MemoryLayout<BasePairVertex>.stride
        basePairVertexBuffer = device.makeBuffer(
            bytes: basePairVertices,
            length: basePairBufferSize,
            options: .storageModeShared
        )
        
        let particleBufferSize = particles.count * MemoryLayout<DNAParticle>.stride
        particleVertexBuffer = device.makeBuffer(
            bytes: particles,
            length: particleBufferSize,
            options: .storageModeShared
        )
        
        // Create uniform buffer
        uniformBuffer = device.makeBuffer(
            length: MemoryLayout<Uniforms>.stride,
            options: .storageModeShared
        )
        
        // Create lighting buffer
        lightingBuffer = device.makeBuffer(
            length: MemoryLayout<LightingUniforms>.stride,
            options: .storageModeShared
        )
    }
    
    private func updateBuffers() {
        // Update vertex buffers with new data
        if !helixVertices.isEmpty {
            let helixPointer = helixVertexBuffer.contents()
            memcpy(helixPointer, helixVertices, helixVertices.count * MemoryLayout<HelixVertex>.stride)
        }
        
        if !basePairVertices.isEmpty {
            let basePairPointer = basePairVertexBuffer.contents()
            memcpy(basePairPointer, basePairVertices, basePairVertices.count * MemoryLayout<BasePairVertex>.stride)
        }
        
        if !particles.isEmpty {
            let particlePointer = particleVertexBuffer.contents()
            memcpy(particlePointer, particles, particles.count * MemoryLayout<DNAParticle>.stride)
        }
    }
    
    private func updateUniforms() {
        time += 1.0 / 60.0
        
        // Create transformation matrices
        let aspect: Float = 1.0 // Will be updated with actual view aspect ratio
        let projectionMatrix = matrix_perspective_left_hand(
            fovyRadians: .pi / 4,
            aspectRatio: aspect,
            nearZ: 0.1,
            farZ: 100.0
        )
        
        let viewMatrix = matrix_look_at_left_hand(
            eye: simd_float3(0, 0, 5),
            center: simd_float3(0, 0, 0),
            up: simd_float3(0, 1, 0)
        )
        
        let rotationX = matrix4x4_rotation(radians: rotation.y, axis: simd_float3(1, 0, 0))
        let rotationY = matrix4x4_rotation(radians: rotation.x, axis: simd_float3(0, 1, 0))
        let scale = matrix4x4_scale(zoom, zoom, zoom)
        
        let modelMatrix = scale * rotationX * rotationY
        
        var uniforms = Uniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: modelMatrix.inverse.transpose,
            time: time,
            viewMode: Int32(viewModeToInt(viewMode)),
            particleIntensity: particleIntensity,
            selectedSegmentIndex: Int32(selectedSegmentIndex()),
            primaryColor: primaryColor,
            secondaryColor: secondaryColor
        )
        
        let uniformPointer = uniformBuffer.contents()
        memcpy(uniformPointer, &uniforms, MemoryLayout<Uniforms>.stride)
        
        // Update lighting uniforms
        var lighting = LightingUniforms(
            lightPosition: simd_float3(5, 5, 5),
            lightColor: simd_float3(1, 1, 1),
            ambientIntensity: 0.3,
            diffuseIntensity: 0.7,
            specularIntensity: 0.5,
            shininess: 32.0
        )
        
        let lightingPointer = lightingBuffer.contents()
        memcpy(lightingPointer, &lighting, MemoryLayout<LightingUniforms>.stride)
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view resize
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Failed to get drawable or command buffer")
            return
        }
        
        // Check if we have a valid pipeline state
        guard pipelineState != nil else {
            print("No valid pipeline state - skipping render")
            // Draw a simple colored background to show something is working
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: 0.1, 
                green: 0.2, 
                blue: 0.4, 
                alpha: 1.0
            )
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.endEncoding()
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
            return
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        // Update uniforms
        updateUniforms()
        
        // Update particle positions
        updateParticles()
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        renderEncoder.label = "DNA Helix Render"
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setCullMode(.back)
        renderEncoder.setFrontFacing(.counterClockwise)
        
        // Set uniforms
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(lightingBuffer, offset: 0, index: 2)
        
        // Draw DNA helix strands
        if !helixVertices.isEmpty {
            renderEncoder.setVertexBuffer(helixVertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(
                type: .triangleStrip,
                vertexStart: 0,
                vertexCount: helixVertices.count
            )
        }
        
        // Draw base pairs
        if !basePairVertices.isEmpty && viewMode != .xray {
            renderEncoder.setVertexBuffer(basePairVertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(
                type: .lineStrip,
                vertexStart: 0,
                vertexCount: basePairVertices.count
            )
        }
        
        // Draw particles if enabled
        if particleIntensity > 0 && !particles.isEmpty {
            renderEncoder.setVertexBuffer(particleVertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(
                type: .point,
                vertexStart: 0,
                vertexCount: particles.count
            )
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Helper Methods
    
    private func updateParticles() {
        for i in 0..<particles.count {
            particles[i].position += particles[i].velocity * (1.0 / 60.0)
            particles[i].life -= 1.0 / 180.0 // 3 second lifespan
            
            // Reset particle if it dies
            if particles[i].life <= 0 {
                particles[i].position = simd_float3(
                    Float.random(in: -2...2),
                    -3,
                    Float.random(in: -2...2)
                )
                particles[i].life = 1.0
            }
            
            // Wrap around if particle goes too high
            if particles[i].position.y > 3 {
                particles[i].position.y = -3
            }
        }
        
        // Update particle buffer
        if !particles.isEmpty {
            let particlePointer = particleVertexBuffer.contents()
            memcpy(particlePointer, particles, particles.count * MemoryLayout<DNAParticle>.stride)
        }
    }
    
    private func colorToSIMD(_ color: Color) -> simd_float4 {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return simd_float4(Float(red), Float(green), Float(blue), Float(alpha))
    }
    
    private func mix(_ a: simd_float4, _ b: simd_float4, t: Float) -> simd_float4 {
        return a * (1 - t) + b * t
    }
    
    private func mix(_ a: simd_float3, _ b: simd_float3, t: Float) -> simd_float3 {
        return a * (1 - t) + b * t
    }
    
    private func getBasePairColor(index: Int) -> simd_float4 {
        let colors: [simd_float4] = [
            simd_float4(1.0, 0.3, 0.3, 0.8), // Adenine - Red
            simd_float4(0.3, 1.0, 0.3, 0.8), // Guanine - Green
            simd_float4(0.3, 0.3, 1.0, 0.8), // Cytosine - Blue
            simd_float4(1.0, 1.0, 0.3, 0.8)  // Thymine - Yellow
        ]
        return colors[index % colors.count]
    }
    
    private func viewModeToInt(_ mode: DNAViewMode) -> Int {
        switch mode {
        case .standard: return 0
        case .xray: return 1
        case .energy: return 2
        case .mutation: return 3
        }
    }
    
    private func selectedSegmentIndex() -> Int {
        guard let segment = selectedSegment else { return -1 }
        return geneSequence.firstIndex(where: { $0.id == segment.id }) ?? -1
    }
}

// MARK: - Data Structures

struct HelixVertex {
    let position: simd_float3
    let normal: simd_float3
    let color: simd_float4
    let uv: simd_float2
}

struct BasePairVertex {
    let position: simd_float3
    let normal: simd_float3
    let color: simd_float4
    let intensity: Float
}

struct DNAParticle {
    var position: simd_float3
    var velocity: simd_float3
    let color: simd_float4
    let size: Float
    var life: Float
}

struct Uniforms {
    let modelMatrix: simd_float4x4
    let viewMatrix: simd_float4x4
    let projectionMatrix: simd_float4x4
    let normalMatrix: simd_float4x4
    let time: Float
    let viewMode: Int32
    let particleIntensity: Float
    let selectedSegmentIndex: Int32
    let primaryColor: simd_float4
    let secondaryColor: simd_float4
}

struct LightingUniforms {
    let lightPosition: simd_float3
    let lightColor: simd_float3
    let ambientIntensity: Float
    let diffuseIntensity: Float
    let specularIntensity: Float
    let shininess: Float
}

// MARK: - Matrix Helper Functions

func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> simd_float4x4 {
    let ys = 1 / tanf(fovyRadians * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (farZ - nearZ)
    
    return simd_float4x4(
        simd_float4(xs,  0,  0,  0),
        simd_float4( 0, ys,  0,  0),
        simd_float4( 0,  0, zs,  1),
        simd_float4( 0,  0, -nearZ * zs, 0)
    )
}

func matrix_look_at_left_hand(eye: simd_float3, center: simd_float3, up: simd_float3) -> simd_float4x4 {
    let z = simd_normalize(center - eye)
    let x = simd_normalize(simd_cross(up, z))
    let y = simd_cross(z, x)
    
    return simd_float4x4(
        simd_float4(x.x, y.x, z.x, 0),
        simd_float4(x.y, y.y, z.y, 0),
        simd_float4(x.z, y.z, z.z, 0),
        simd_float4(-simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye), 1)
    )
}

func matrix4x4_rotation(radians: Float, axis: simd_float3) -> simd_float4x4 {
    let unitAxis = simd_normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    
    return simd_float4x4(
        simd_float4(ct + x * x * ci, x * y * ci - z * st, x * z * ci + y * st, 0),
        simd_float4(y * x * ci + z * st, ct + y * y * ci, y * z * ci - x * st, 0),
        simd_float4(z * x * ci - y * st, z * y * ci + x * st, ct + z * z * ci, 0),
        simd_float4(0, 0, 0, 1)
    )
}

func matrix4x4_scale(_ s: Float) -> simd_float4x4 {
    return simd_float4x4(
        simd_float4(s, 0, 0, 0),
        simd_float4(0, s, 0, 0),
        simd_float4(0, 0, s, 0),
        simd_float4(0, 0, 0, 1)
    )
}

func matrix4x4_scale(_ sx: Float, _ sy: Float, _ sz: Float) -> simd_float4x4 {
    return simd_float4x4(
        simd_float4(sx, 0, 0, 0),
        simd_float4(0, sy, 0, 0),
        simd_float4(0, 0, sz, 0),
        simd_float4(0, 0, 0, 1)
    )
}