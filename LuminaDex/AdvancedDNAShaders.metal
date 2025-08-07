//
//  AdvancedDNAShaders.metal
//  LuminaDex
//
//  Advanced 3D shaders for DNA helix visualization
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

// MARK: - Vertex Structures

struct HelixVertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float4 color [[attribute(2)]];
    float2 uv [[attribute(3)]];
};

struct HelixVertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float4 color;
    float2 uv;
    float depth;
    float fogFactor;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4x4 normalMatrix;
    float time;
    int viewMode;
    float particleIntensity;
    int selectedSegmentIndex;
    float4 primaryColor;
    float4 secondaryColor;
};

struct LightingUniforms {
    float3 lightPosition;
    float3 lightColor;
    float ambientIntensity;
    float diffuseIntensity;
    float specularIntensity;
    float shininess;
};

// MARK: - Advanced DNA Vertex Shader

vertex HelixVertexOut advanced_dna_vertex(
    HelixVertexIn in [[stage_in]],
    constant Uniforms& uniforms [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    HelixVertexOut out;
    
    // Apply DNA twist animation
    float twist = sin(uniforms.time * 0.5 + in.position.y * 2.0) * 0.1;
    float3 animatedPosition = in.position;
    animatedPosition.x += cos(twist) * 0.05;
    animatedPosition.z += sin(twist) * 0.05;
    
    // Apply energy pulse along the helix
    float pulse = sin(uniforms.time * 3.0 - in.position.y * 4.0) * 0.5 + 0.5;
    animatedPosition += in.normal * pulse * 0.02;
    
    // Transform positions
    float4 worldPosition = uniforms.modelMatrix * float4(animatedPosition, 1.0);
    float4 viewPosition = uniforms.viewMatrix * worldPosition;
    out.position = uniforms.projectionMatrix * viewPosition;
    
    // Pass world space data for lighting
    out.worldPosition = worldPosition.xyz;
    out.worldNormal = normalize((uniforms.normalMatrix * float4(in.normal, 0.0)).xyz);
    
    // Apply color with animation
    float colorShift = sin(uniforms.time + in.position.y * 2.0) * 0.5 + 0.5;
    out.color = mix(in.color, uniforms.primaryColor, colorShift * 0.3);
    
    // Add glow effect for selected segments
    if (uniforms.selectedSegmentIndex >= 0) {
        float segmentDistance = abs(float(vertexID / 20) - float(uniforms.selectedSegmentIndex));
        float glowIntensity = exp(-segmentDistance * 0.1);
        out.color += float4(1.0, 1.0, 0.0, 0.0) * glowIntensity * 0.5;
    }
    
    out.uv = in.uv;
    out.depth = -viewPosition.z;
    
    // Calculate fog factor for depth effect
    float fogStart = 2.0;
    float fogEnd = 10.0;
    out.fogFactor = clamp((fogEnd - out.depth) / (fogEnd - fogStart), 0.0, 1.0);
    
    return out;
}

// MARK: - Shading Helper Functions

float4 applyStandardShading(
    HelixVertexOut in,
    constant LightingUniforms& lighting,
    constant Uniforms& uniforms
) {
    // Blinn-Phong lighting
    float3 normal = normalize(in.worldNormal);
    float3 lightDir = normalize(lighting.lightPosition - in.worldPosition);
    float3 viewDir = normalize(-in.worldPosition);
    float3 halfVector = normalize(lightDir + viewDir);
    
    // Ambient
    float3 ambient = lighting.ambientIntensity * in.color.rgb;
    
    // Diffuse
    float NdotL = max(dot(normal, lightDir), 0.0);
    float3 diffuse = lighting.diffuseIntensity * NdotL * in.color.rgb * lighting.lightColor;
    
    // Specular
    float NdotH = max(dot(normal, halfVector), 0.0);
    float specular = pow(NdotH, lighting.shininess);
    float3 specularColor = lighting.specularIntensity * specular * lighting.lightColor;
    
    // Subsurface scattering simulation for organic look
    float3 scatterDir = lightDir + normal * 0.5;
    float scatter = max(0.0, dot(viewDir, -scatterDir));
    scatter = pow(scatter, 3.0) * 0.3;
    float3 subsurface = scatter * uniforms.primaryColor.rgb;
    
    float3 finalColor = ambient + diffuse + specularColor + subsurface;
    
    // Add fresnel effect
    float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), 3.0);
    finalColor += fresnel * uniforms.secondaryColor.rgb * 0.3;
    
    return float4(finalColor, in.color.a);
}

float4 applyXRayEffect(HelixVertexOut in, constant Uniforms& uniforms) {
    // X-Ray visualization with edge detection
    float3 normal = normalize(in.worldNormal);
    float3 viewDir = normalize(-in.worldPosition);
    
    // Edge intensity based on normal
    float edge = 1.0 - abs(dot(viewDir, normal));
    edge = pow(edge, 0.8);
    
    // Create X-ray color
    float3 xrayColor = float3(0.2, 0.8, 1.0);
    float3 finalColor = xrayColor * edge;
    
    // Add internal structure visualization
    float internalStructure = sin(in.worldPosition.y * 20.0 + uniforms.time * 2.0) * 0.5 + 0.5;
    finalColor += float3(0.1, 0.3, 0.5) * internalStructure * 0.3;
    
    // Depth-based intensity
    float depthIntensity = 1.0 - saturate(in.depth / 10.0);
    finalColor *= depthIntensity;
    
    return float4(finalColor, edge * 0.8);
}

float4 applyEnergyVisualization(HelixVertexOut in, constant Uniforms& uniforms) {
    // Energy field visualization
    float3 energyColor = uniforms.primaryColor.rgb;
    
    // Pulsing energy waves
    float wave1 = sin(in.worldPosition.y * 10.0 - uniforms.time * 3.0);
    float wave2 = sin(in.worldPosition.x * 15.0 + uniforms.time * 2.0);
    float wave3 = sin(in.worldPosition.z * 12.0 - uniforms.time * 4.0);
    
    float energy = (wave1 + wave2 + wave3) / 3.0 * 0.5 + 0.5;
    
    // Electric discharge effect
    float discharge = fract(sin(dot(in.worldPosition.xy, float2(12.9898, 78.233))) * 43758.5453);
    discharge = step(0.98, discharge) * sin(uniforms.time * 10.0);
    
    float3 finalColor = energyColor * energy;
    finalColor += float3(1.0, 1.0, 0.5) * discharge;
    
    // Add energy field glow
    float glow = 1.0 - saturate(length(in.worldPosition.xz) / 2.0);
    finalColor += energyColor * glow * 0.3;
    
    return float4(finalColor, 0.8);
}

float4 applyMutationHighlight(HelixVertexOut in, constant Uniforms& uniforms) {
    // Highlight potential mutation points
    float3 baseColor = in.color.rgb;
    
    // Create mutation hotspots
    float mutationNoise = sin(in.worldPosition.x * 20.0) * 
                         sin(in.worldPosition.y * 30.0) * 
                         sin(in.worldPosition.z * 25.0);
    mutationNoise = smoothstep(0.7, 0.9, abs(mutationNoise));
    
    // Mutation color (purple/magenta)
    float3 mutationColor = float3(1.0, 0.0, 1.0);
    
    // Blend with base color
    float3 finalColor = mix(baseColor, mutationColor, mutationNoise);
    
    // Add pulsing effect to mutations
    float pulse = sin(uniforms.time * 5.0) * 0.5 + 0.5;
    finalColor += mutationColor * mutationNoise * pulse * 0.5;
    
    // Highlight selected segment more prominently
    if (uniforms.selectedSegmentIndex >= 0) {
        finalColor += float3(1.0, 1.0, 0.0) * 0.2;
    }
    
    return float4(finalColor, in.color.a);
}

// MARK: - Advanced DNA Fragment Shader

fragment float4 advanced_dna_fragment(
    HelixVertexOut in [[stage_in]],
    constant Uniforms& uniforms [[buffer(1)]],
    constant LightingUniforms& lighting [[buffer(2)]]
) {
    float4 finalColor = in.color;
    
    // Apply different rendering modes
    switch (uniforms.viewMode) {
        case 0: // Standard mode
            finalColor = applyStandardShading(in, lighting, uniforms);
            break;
            
        case 1: // X-Ray mode
            finalColor = applyXRayEffect(in, uniforms);
            break;
            
        case 2: // Energy mode
            finalColor = applyEnergyVisualization(in, uniforms);
            break;
            
        case 3: // Mutation mode
            finalColor = applyMutationHighlight(in, uniforms);
            break;
            
        default:
            break;
    }
    
    // Add holographic interference pattern
    float interference = sin(in.worldPosition.x * 50.0) * sin(in.worldPosition.z * 50.0) * 0.05;
    finalColor.rgb += interference * float3(0.2, 0.5, 1.0);
    
    // Apply fog for depth
    float3 fogColor = float3(0.0, 0.0, 0.1);
    finalColor.rgb = mix(fogColor, finalColor.rgb, in.fogFactor);
    
    // Add rim lighting
    float3 viewDir = normalize(-in.worldPosition);
    float rim = 1.0 - saturate(dot(viewDir, in.worldNormal));
    rim = pow(rim, 2.0);
    finalColor.rgb += rim * uniforms.primaryColor.rgb * 0.5;
    
    // Energy flow effect
    float flow = sin(in.worldPosition.y * 10.0 - uniforms.time * 4.0) * 0.5 + 0.5;
    finalColor.rgb += flow * uniforms.secondaryColor.rgb * 0.2;
    
    return finalColor;
}

// MARK: - Particle Shaders

struct ParticleVertexIn {
    float3 position [[attribute(0)]];
    float3 velocity [[attribute(1)]];
    float4 color [[attribute(2)]];
    float size [[attribute(3)]];
    float life [[attribute(4)]];
};

struct ParticleVertexOut {
    float4 position [[position]];
    float4 color;
    float size [[point_size]];
    float life;
};

vertex ParticleVertexOut particle_vertex_advanced(
    ParticleVertexIn in [[stage_in]],
    constant Uniforms& uniforms [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    ParticleVertexOut out;
    
    // Update particle position with spiral motion
    float3 position = in.position;
    float angle = uniforms.time * 2.0 + float(vertexID) * 0.1;
    position.x += cos(angle) * 0.1;
    position.z += sin(angle) * 0.1;
    position.y += in.velocity.y * uniforms.time * 0.5;
    
    // Transform to screen space
    float4 worldPos = uniforms.modelMatrix * float4(position, 1.0);
    float4 viewPos = uniforms.viewMatrix * worldPos;
    out.position = uniforms.projectionMatrix * viewPos;
    
    // Fade based on life and add glow
    float fade = in.life * uniforms.particleIntensity;
    out.color = float4(in.color.rgb * (1.0 + sin(uniforms.time * 3.0) * 0.3), in.color.a * fade);
    
    // Size based on distance and life
    float distanceFactor = 1.0 / (1.0 + length(viewPos.xyz) * 0.1);
    out.size = in.size * 100.0 * distanceFactor * fade;
    out.life = in.life;
    
    return out;
}

fragment float4 particle_fragment_advanced(
    ParticleVertexOut in [[stage_in]],
    float2 pointCoord [[point_coord]]
) {
    // Create soft circular particle
    float2 center = float2(0.5, 0.5);
    float distance = length(pointCoord - center);
    
    if (distance > 0.5) {
        discard_fragment();
    }
    
    // Soft edge with glow
    float alpha = 1.0 - smoothstep(0.2, 0.5, distance);
    alpha *= in.life;
    
    // Add inner glow
    float glow = exp(-distance * 3.0);
    float3 glowColor = in.color.rgb + float3(1.0, 1.0, 1.0) * glow * 0.5;
    
    return float4(glowColor, alpha * in.color.a);
}

// MARK: - Background Grid Shader

struct GridVertexOut {
    float4 position [[position]];
    float2 uv;
    float3 worldPosition;
};

vertex GridVertexOut grid_vertex_advanced(
    uint vertexID [[vertex_id]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    GridVertexOut out;
    
    // Generate fullscreen quad
    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };
    
    float2 pos = positions[vertexID];
    out.position = float4(pos, 0.99, 1.0); // Render behind DNA
    out.uv = pos * 0.5 + 0.5;
    out.worldPosition = float3(pos * 10.0, -5.0);
    
    return out;
}

fragment float4 grid_fragment_advanced(
    GridVertexOut in [[stage_in]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    // Create holographic grid
    float gridSize = 0.1;
    float2 grid = abs(fract(in.uv / gridSize) - 0.5) / fwidth(in.uv / gridSize);
    float line = min(grid.x, grid.y);
    
    // Animated scan lines
    float scan = sin(in.uv.y * 50.0 - uniforms.time * 2.0) * 0.5 + 0.5;
    scan *= sin(in.uv.x * 30.0 + uniforms.time * 1.5) * 0.5 + 0.5;
    
    // Grid color with primary type tint
    float3 gridColor = uniforms.primaryColor.rgb * 0.3;
    float alpha = (1.0 - min(line, 1.0)) * 0.2;
    alpha += scan * 0.05;
    
    // Add perspective fade
    float fade = 1.0 - saturate(length(in.uv - 0.5) * 2.0);
    alpha *= fade;
    
    return float4(gridColor, alpha);
}

// MARK: - Post-processing Effects

kernel void bloom_filter(
    texture2d<float, access::read> inputTexture [[texture(0)]],
    texture2d<float, access::write> outputTexture [[texture(1)]],
    constant float& threshold [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    float4 color = inputTexture.read(gid);
    
    // Extract bright areas
    float brightness = dot(color.rgb, float3(0.299, 0.587, 0.114));
    
    if (brightness > threshold) {
        // Apply gaussian blur for bloom
        float4 bloom = float4(0.0);
        float weights[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};
        
        for (int i = -4; i <= 4; i++) {
            for (int j = -4; j <= 4; j++) {
                uint2 samplePos = uint2(int2(gid) + int2(i, j));
                float4 sampleColor = inputTexture.read(samplePos);
                float weight = weights[abs(i)] * weights[abs(j)];
                bloom += sampleColor * weight;
            }
        }
        
        outputTexture.write(color + bloom * 0.5, gid);
    } else {
        outputTexture.write(color, gid);
    }
}