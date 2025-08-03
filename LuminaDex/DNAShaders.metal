//
//  DNAShaders.metal
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float pointSize [[point_size]];
};

struct Uniforms {
    float rotation;
    float zoom;
    float animationPhase;
    float time;
};

// MARK: - Vertex Shader

vertex VertexOut dna_vertex_shader(VertexIn in [[stage_in]],
                                   constant Uniforms& uniforms [[buffer(1)]],
                                   uint vertexID [[vertex_id]]) {
    VertexOut out;
    
    // Apply rotation around Y-axis
    float cosAngle = cos(uniforms.rotation);
    float sinAngle = sin(uniforms.rotation);
    
    float3 rotatedPosition;
    rotatedPosition.x = in.position.x * cosAngle - in.position.z * sinAngle;
    rotatedPosition.y = in.position.y;
    rotatedPosition.z = in.position.x * sinAngle + in.position.z * cosAngle;
    
    // Apply zoom
    rotatedPosition *= uniforms.zoom;
    
    // Add slight perspective
    float4 position = float4(rotatedPosition, 1.0);
    
    // Simple orthographic projection with perspective hint
    position.z = position.z * 0.1; // Compress Z for orthographic feel
    position.w = 1.0 + position.z * 0.1; // Slight perspective
    
    out.position = position;
    out.worldPosition = rotatedPosition;
    
    // Animate color intensity based on animation phase
    float intensity = 0.7 + 0.3 * sin(uniforms.animationPhase + vertexID * 0.1);
    out.color = float4(in.color.rgb * intensity, in.color.a);
    
    // Point size for vertices
    out.pointSize = 2.0 + sin(uniforms.time + vertexID * 0.1) * 0.5;
    
    return out;
}

// MARK: - Fragment Shader

fragment float4 dna_fragment_shader(VertexOut in [[stage_in]],
                                    constant Uniforms& uniforms [[buffer(1)]]) {
    
    // Distance from center for glow effect
    float2 center = float2(0.5, 0.5);
    float2 pointCoord = in.position.xy / in.position.w;
    
    // Create holographic glow effect
    float distance = length(in.worldPosition);
    float glow = 1.0 - smoothstep(0.0, 2.0, distance);
    
    // Add shimmer effect based on time
    float shimmer = 0.5 + 0.5 * sin(uniforms.time * 2.0 + distance * 5.0);
    
    // Energy flow effect along the helix
    float flow = sin(in.worldPosition.y * 10.0 - uniforms.time * 3.0) * 0.5 + 0.5;
    
    // Combine effects
    float4 finalColor = in.color;
    finalColor.rgb *= (glow * 0.5 + 0.5);
    finalColor.rgb += shimmer * 0.2;
    finalColor.rgb += flow * 0.3 * finalColor.rgb;
    
    // Add holographic interference patterns
    float interference = sin(in.worldPosition.x * 50.0) * sin(in.worldPosition.z * 50.0) * 0.1;
    finalColor.rgb += interference;
    
    return finalColor;
}

// MARK: - Particle Effect Shaders

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

vertex ParticleVertexOut particle_vertex_shader(ParticleVertexIn in [[stage_in]],
                                                constant Uniforms& uniforms [[buffer(1)]],
                                                uint vertexID [[vertex_id]]) {
    ParticleVertexOut out;
    
    // Update particle position based on velocity and time
    float3 updatedPosition = in.position + in.velocity * uniforms.time * 0.1;
    
    // Apply rotation and zoom
    float cosAngle = cos(uniforms.rotation);
    float sinAngle = sin(uniforms.rotation);
    
    float3 rotatedPosition;
    rotatedPosition.x = updatedPosition.x * cosAngle - updatedPosition.z * sinAngle;
    rotatedPosition.y = updatedPosition.y;
    rotatedPosition.z = updatedPosition.x * sinAngle + updatedPosition.z * cosAngle;
    
    rotatedPosition *= uniforms.zoom;
    
    out.position = float4(rotatedPosition, 1.0);
    
    // Fade color based on life
    out.color = float4(in.color.rgb, in.color.a * in.life);
    
    // Size based on life and distance
    out.size = in.size * in.life * uniforms.zoom;
    out.life = in.life;
    
    return out;
}

fragment float4 particle_fragment_shader(ParticleVertexOut in [[stage_in]],
                                         float2 pointCoord [[point_coord]]) {
    
    // Create circular particle
    float2 center = float2(0.5, 0.5);
    float distance = length(pointCoord - center);
    
    if (distance > 0.5) {
        discard_fragment();
    }
    
    // Soft edge falloff
    float alpha = 1.0 - smoothstep(0.3, 0.5, distance);
    alpha *= in.life;
    
    // Add glow effect
    float glow = 1.0 - distance * 2.0;
    glow = max(0.0, glow);
    
    float4 color = in.color;
    color.rgb += glow * 0.3;
    color.a *= alpha;
    
    return color;
}

// MARK: - Gene Highlight Shader

fragment float4 gene_highlight_shader(VertexOut in [[stage_in]],
                                      constant Uniforms& uniforms [[buffer(1)]]) {
    
    // Pulsing highlight effect for selected genes
    float pulse = sin(uniforms.time * 4.0) * 0.5 + 0.5;
    
    float4 highlightColor = float4(1.0, 1.0, 0.0, 0.8); // Yellow highlight
    float4 originalColor = in.color;
    
    // Mix colors based on pulse
    float4 finalColor = mix(originalColor, highlightColor, pulse * 0.6);
    
    // Add rim lighting effect
    float3 normal = normalize(in.worldPosition);
    float rim = 1.0 - abs(dot(normal, float3(0.0, 0.0, 1.0)));
    finalColor.rgb += rim * rim * highlightColor.rgb * 0.5;
    
    return finalColor;
}

// MARK: - Holographic Grid Shader

struct GridVertexOut {
    float4 position [[position]];
    float2 uv;
    float alpha;
};

vertex GridVertexOut grid_vertex_shader(uint vertexID [[vertex_id]],
                                        constant Uniforms& uniforms [[buffer(1)]]) {
    GridVertexOut out;
    
    // Generate grid vertices procedurally
    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };
    
    float2 pos = positions[vertexID % 4];
    out.position = float4(pos, 0.0, 1.0);
    out.uv = pos * 0.5 + 0.5;
    
    // Animate grid opacity
    out.alpha = 0.1 + 0.05 * sin(uniforms.animationPhase);
    
    return out;
}

fragment float4 grid_fragment_shader(GridVertexOut in [[stage_in]],
                                     constant Uniforms& uniforms [[buffer(1)]]) {
    
    float2 grid = abs(fract(in.uv * 20.0) - 0.5) / fwidth(in.uv * 20.0);
    float line = min(grid.x, grid.y);
    
    float4 color = float4(0.0, 1.0, 1.0, (1.0 - min(line, 1.0)) * in.alpha);
    
    // Add scanning line effect
    float scan = sin(in.uv.y * 10.0 - uniforms.time * 2.0);
    color.rgb += scan * 0.1;
    
    return color;
}

