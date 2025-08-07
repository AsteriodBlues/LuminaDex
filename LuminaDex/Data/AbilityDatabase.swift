//
//  AbilityDatabase.swift
//  LuminaDex
//
//  Comprehensive database of Pokemon abilities with unique descriptions
//

import Foundation

struct AbilityDatabase {
    static let shared = AbilityDatabase()
    
    private let abilities: [String: AbilityInfo] = [
        // Gen 1-2 Starter Abilities
        "overgrow": AbilityInfo(
            name: "Overgrow",
            description: "Powers up Grass-type moves by 50% when HP falls below 1/3 of maximum.",
            effect: "Grass moves get 1.5x power boost in a pinch"
        ),
        "chlorophyll": AbilityInfo(
            name: "Chlorophyll", 
            description: "Doubles Speed stat in harsh sunlight weather conditions.",
            effect: "2x Speed in sun"
        ),
        "blaze": AbilityInfo(
            name: "Blaze",
            description: "Powers up Fire-type moves by 50% when HP falls below 1/3 of maximum.",
            effect: "Fire moves get 1.5x power boost in a pinch"
        ),
        "solar-power": AbilityInfo(
            name: "Solar Power",
            description: "Boosts Special Attack by 50% in sun, but loses 1/8 HP each turn.",
            effect: "1.5x Sp.Atk in sun, but damages user"
        ),
        "torrent": AbilityInfo(
            name: "Torrent",
            description: "Powers up Water-type moves by 50% when HP falls below 1/3 of maximum.",
            effect: "Water moves get 1.5x power boost in a pinch"
        ),
        "rain-dish": AbilityInfo(
            name: "Rain Dish",
            description: "Restores 1/16 of maximum HP each turn during rain.",
            effect: "Heals in rain"
        ),
        
        // Pikachu Line
        "static": AbilityInfo(
            name: "Static",
            description: "30% chance to paralyze attackers on contact. Attracts Electric types in the wild.",
            effect: "May paralyze on contact"
        ),
        "lightning-rod": AbilityInfo(
            name: "Lightning Rod",
            description: "Draws in all Electric-type moves and raises Special Attack when hit by one.",
            effect: "Absorbs Electric moves for Sp.Atk boost"
        ),
        
        // Common Abilities
        "pressure": AbilityInfo(
            name: "Pressure",
            description: "Forces opposing Pokémon to use 2 PP for moves that target this Pokémon.",
            effect: "Opponents use 2x PP"
        ),
        "intimidate": AbilityInfo(
            name: "Intimidate",
            description: "Lowers all opponents' Attack by one stage upon entering battle.",
            effect: "Lowers foe's Attack on switch-in"
        ),
        "levitate": AbilityInfo(
            name: "Levitate",
            description: "Immune to Ground-type moves and arena traps by floating.",
            effect: "Immunity to Ground moves"
        ),
        "synchronize": AbilityInfo(
            name: "Synchronize",
            description: "Passes poison, paralysis, or burn status to the Pokémon that inflicted it.",
            effect: "Shares status conditions"
        ),
        "inner-focus": AbilityInfo(
            name: "Inner Focus",
            description: "Prevents flinching from any move or ability.",
            effect: "Cannot flinch"
        ),
        "swift-swim": AbilityInfo(
            name: "Swift Swim",
            description: "Doubles Speed stat during rainy weather.",
            effect: "2x Speed in rain"
        ),
        "sand-stream": AbilityInfo(
            name: "Sand Stream",
            description: "Summons a sandstorm that lasts 5 turns upon entering battle.",
            effect: "Auto-summons sandstorm"
        ),
        "drought": AbilityInfo(
            name: "Drought",
            description: "Summons harsh sunlight that lasts 5 turns upon entering battle.",
            effect: "Auto-summons sun"
        ),
        "drizzle": AbilityInfo(
            name: "Drizzle",
            description: "Summons rain that lasts 5 turns upon entering battle.",
            effect: "Auto-summons rain"
        ),
        
        // Legendary Abilities
        "slow-start": AbilityInfo(
            name: "Slow Start",
            description: "Halves Attack and Speed for 5 turns after entering battle.",
            effect: "Weakened for 5 turns"
        ),
        "multitype": AbilityInfo(
            name: "Multitype",
            description: "Changes type to match the held Plate or Z-Crystal.",
            effect: "Type changes with held item"
        ),
        "wonder-guard": AbilityInfo(
            name: "Wonder Guard",
            description: "Only super-effective moves can damage this Pokémon.",
            effect: "Immune to non-super-effective moves"
        ),
        
        // Dragon Types
        "multiscale": AbilityInfo(
            name: "Multiscale",
            description: "Halves damage taken when HP is full.",
            effect: "50% damage reduction at full HP"
        ),
        "mold-breaker": AbilityInfo(
            name: "Mold Breaker",
            description: "Moves ignore abilities that would block or weaken them.",
            effect: "Ignores defensive abilities"
        ),
        
        // Fighting Types
        "guts": AbilityInfo(
            name: "Guts",
            description: "Boosts Attack by 50% when afflicted with a status condition.",
            effect: "1.5x Attack when statused"
        ),
        "iron-fist": AbilityInfo(
            name: "Iron Fist",
            description: "Powers up punching moves by 20%.",
            effect: "1.2x power for punch moves"
        ),
        "no-guard": AbilityInfo(
            name: "No Guard",
            description: "All moves used by or against this Pokémon will never miss.",
            effect: "All moves hit"
        ),
        
        // Psychic Types
        "magic-guard": AbilityInfo(
            name: "Magic Guard",
            description: "Only takes damage from direct attacks, immune to indirect damage.",
            effect: "No indirect damage"
        ),
        "trace": AbilityInfo(
            name: "Trace",
            description: "Copies the ability of the opponent upon entering battle.",
            effect: "Copies foe's ability"
        ),
        "telepathy": AbilityInfo(
            name: "Telepathy",
            description: "Avoids damage from allies' moves in Double/Triple battles.",
            effect: "Immune to ally attacks"
        ),
        
        // Ghost Types
        "cursed-body": AbilityInfo(
            name: "Cursed Body",
            description: "30% chance to disable a move that hits this Pokémon.",
            effect: "May disable attacker's move"
        ),
        "infiltrator": AbilityInfo(
            name: "Infiltrator",
            description: "Passes through barriers and substitutes when attacking.",
            effect: "Ignores screens and substitutes"
        ),
        
        // Steel Types
        "sturdy": AbilityInfo(
            name: "Sturdy",
            description: "Cannot be knocked out with one hit when at full HP. Immune to OHKO moves.",
            effect: "Survives any hit from full HP"
        ),
        "heavy-metal": AbilityInfo(
            name: "Heavy Metal",
            description: "Doubles the Pokémon's weight.",
            effect: "2x weight"
        ),
        "light-metal": AbilityInfo(
            name: "Light Metal",
            description: "Halves the Pokémon's weight.",
            effect: "0.5x weight"
        ),
        
        // Bug Types
        "swarm": AbilityInfo(
            name: "Swarm",
            description: "Powers up Bug-type moves by 50% when HP falls below 1/3.",
            effect: "Bug moves stronger in a pinch"
        ),
        "compound-eyes": AbilityInfo(
            name: "Compound Eyes",
            description: "Increases accuracy of moves by 30%.",
            effect: "1.3x accuracy"
        ),
        "tinted-lens": AbilityInfo(
            name: "Tinted Lens",
            description: "Doubles the power of not very effective moves.",
            effect: "2x power for resisted moves"
        ),
        
        // Ice Types
        "snow-warning": AbilityInfo(
            name: "Snow Warning",
            description: "Summons a hailstorm that lasts 5 turns upon entering battle.",
            effect: "Auto-summons hail"
        ),
        "ice-body": AbilityInfo(
            name: "Ice Body",
            description: "Restores 1/16 HP each turn in hail.",
            effect: "Heals in hail"
        ),
        "snow-cloak": AbilityInfo(
            name: "Snow Cloak",
            description: "Raises evasion by 25% in a hailstorm.",
            effect: "Harder to hit in hail"
        ),
        
        // Dark Types
        "dark-aura": AbilityInfo(
            name: "Dark Aura",
            description: "Powers up all Dark-type moves by 33% for all Pokémon in battle.",
            effect: "Boosts all Dark moves"
        ),
        "bad-dreams": AbilityInfo(
            name: "Bad Dreams",
            description: "Damages sleeping foes for 1/8 of their max HP each turn.",
            effect: "Hurts sleeping enemies"
        ),
        
        // Fairy Types
        "fairy-aura": AbilityInfo(
            name: "Fairy Aura",
            description: "Powers up all Fairy-type moves by 33% for all Pokémon in battle.",
            effect: "Boosts all Fairy moves"
        ),
        "pixilate": AbilityInfo(
            name: "Pixilate",
            description: "Normal-type moves become Fairy-type and get 20% power boost.",
            effect: "Normal moves become Fairy"
        ),
        
        // Unique/Signature Abilities
        "stance-change": AbilityInfo(
            name: "Stance Change",
            description: "Changes between Shield and Blade form when using King's Shield or attacking.",
            effect: "Form changes with moves"
        ),
        "schooling": AbilityInfo(
            name: "Schooling",
            description: "Forms a school when HP is above 25% and level is 20 or higher.",
            effect: "Changes form based on HP"
        ),
        "battle-bond": AbilityInfo(
            name: "Battle Bond",
            description: "Transforms into Ash-Greninja after knocking out a Pokémon.",
            effect: "Transforms after KO"
        ),
        "power-construct": AbilityInfo(
            name: "Power Construct",
            description: "Transforms into Complete Forme when HP falls below 50%.",
            effect: "Changes form at low HP"
        ),
        
        // Eevee Evolution Abilities
        "water-absorb": AbilityInfo(
            name: "Water Absorb",
            description: "Restores HP when hit by Water-type moves instead of taking damage.",
            effect: "Heals from Water moves"
        ),
        "volt-absorb": AbilityInfo(
            name: "Volt Absorb",
            description: "Restores HP when hit by Electric-type moves instead of taking damage.",
            effect: "Heals from Electric moves"
        ),
        "flash-fire": AbilityInfo(
            name: "Flash Fire",
            description: "Powers up Fire-type moves by 50% when hit by Fire moves. Immune to Fire.",
            effect: "Absorbs Fire for power"
        ),
        "leaf-guard": AbilityInfo(
            name: "Leaf Guard",
            description: "Prevents status conditions in harsh sunlight.",
            effect: "Status immunity in sun"
        ),
        "magic-bounce": AbilityInfo(
            name: "Magic Bounce",
            description: "Reflects status moves back at the attacker.",
            effect: "Bounces back status moves"
        ),
        
        // Speed Abilities
        "speed-boost": AbilityInfo(
            name: "Speed Boost",
            description: "Raises Speed by one stage at the end of each turn.",
            effect: "+1 Speed each turn"
        ),
        "quick-feet": AbilityInfo(
            name: "Quick Feet",
            description: "Boosts Speed by 50% when afflicted with a status condition.",
            effect: "1.5x Speed when statused"
        ),
        "unburden": AbilityInfo(
            name: "Unburden",
            description: "Doubles Speed when the held item is lost or consumed.",
            effect: "2x Speed without item"
        ),
        
        // Defensive Abilities
        "thick-fat": AbilityInfo(
            name: "Thick Fat",
            description: "Halves damage from Fire and Ice-type moves.",
            effect: "Resists Fire and Ice"
        ),
        "fur-coat": AbilityInfo(
            name: "Fur Coat",
            description: "Halves damage from physical moves.",
            effect: "2x Defense"
        ),
        "filter": AbilityInfo(
            name: "Filter",
            description: "Reduces super effective damage by 25%.",
            effect: "Reduces super effective hits"
        ),
        "solid-rock": AbilityInfo(
            name: "Solid Rock",
            description: "Reduces super effective damage by 25%.",
            effect: "Reduces super effective hits"
        ),
        
        // Status Abilities
        "poison-point": AbilityInfo(
            name: "Poison Point",
            description: "30% chance to poison attackers on contact.",
            effect: "May poison on contact"
        ),
        "flame-body": AbilityInfo(
            name: "Flame Body",
            description: "30% chance to burn attackers on contact. Halves egg hatching time.",
            effect: "May burn on contact"
        ),
        "effect-spore": AbilityInfo(
            name: "Effect Spore",
            description: "30% chance to inflict poison, sleep, or paralysis on contact.",
            effect: "Random status on contact"
        ),
        
        // Weather-based
        "sand-veil": AbilityInfo(
            name: "Sand Veil",
            description: "Raises evasion by 25% in a sandstorm. Immune to sandstorm damage.",
            effect: "Harder to hit in sandstorm"
        ),
        "sand-rush": AbilityInfo(
            name: "Sand Rush",
            description: "Doubles Speed in a sandstorm. Immune to sandstorm damage.",
            effect: "2x Speed in sandstorm"
        ),
        "ice-scales": AbilityInfo(
            name: "Ice Scales",
            description: "Halves damage from special moves.",
            effect: "50% special damage reduction"
        ),
        
        // Mega Evolution Abilities
        "adaptability": AbilityInfo(
            name: "Adaptability",
            description: "STAB moves get 2x power instead of 1.5x.",
            effect: "Stronger same-type moves"
        ),
        "aerilate": AbilityInfo(
            name: "Aerilate",
            description: "Normal-type moves become Flying-type and get 20% power boost.",
            effect: "Normal moves become Flying"
        ),
        "refrigerate": AbilityInfo(
            name: "Refrigerate",
            description: "Normal-type moves become Ice-type and get 20% power boost.",
            effect: "Normal moves become Ice"
        ),
        "galvanize": AbilityInfo(
            name: "Galvanize",
            description: "Normal-type moves become Electric-type and get 20% power boost.",
            effect: "Normal moves become Electric"
        ),
        
        // Hidden Abilities
        "protean": AbilityInfo(
            name: "Protean",
            description: "Changes type to match the move being used before it hits.",
            effect: "Type changes before attacking"
        ),
        "libero": AbilityInfo(
            name: "Libero",
            description: "Changes type to match the move being used before it hits.",
            effect: "Type changes before attacking"
        ),
        "contrary": AbilityInfo(
            name: "Contrary",
            description: "Stat changes have opposite effect (boosts become drops and vice versa).",
            effect: "Inverted stat changes"
        ),
        "sheer-force": AbilityInfo(
            name: "Sheer Force",
            description: "Removes additional effects to increase move damage by 30%.",
            effect: "1.3x power, no secondary effects"
        ),
        "unaware": AbilityInfo(
            name: "Unaware",
            description: "Ignores the opponent's stat changes when calculating damage.",
            effect: "Ignores foe's stat changes"
        )
    ]
    
    func getAbilityInfo(for name: String) -> AbilityInfo {
        let normalizedName = name.lowercased().replacingOccurrences(of: " ", with: "-")
        
        if let ability = abilities[normalizedName] {
            return ability
        }
        
        // Return default for unknown abilities
        return AbilityInfo(
            name: formatAbilityName(name),
            description: "A unique ability that provides special effects in battle.",
            effect: "Special battle effect"
        )
    }
    
    private func formatAbilityName(_ name: String) -> String {
        name.replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

struct AbilityInfo {
    let name: String
    let description: String
    let effect: String
}