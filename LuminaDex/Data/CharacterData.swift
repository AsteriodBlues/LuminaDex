//
//  CharacterData.swift
//  LuminaDex
//
//  Pokemon series main characters and companions
//

import Foundation
import SwiftUI

// MARK: - Character Model
struct Character: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let role: CharacterRole
    let region: String
    let age: Int?
    let hometown: String
    let specialties: [String]
    let pokemonTeam: [String]
    let description: String
    let achievements: [String]
    let imageURL: String
    let debut: String
    
    var displayName: String {
        name
    }
    
    enum CharacterRole: String, CaseIterable, Codable {
        case protagonist = "Protagonist"
        case rival = "Rival"
        case gymLeader = "Gym Leader"
        case eliteFour = "Elite Four"
        case champion = "Champion"
        case professor = "Professor"
        case companion = "Companion"
        case villain = "Villain"
        
        var color: Color {
            switch self {
            case .protagonist: return .blue
            case .rival: return .red
            case .gymLeader: return .orange
            case .eliteFour: return .purple
            case .champion: return .yellow
            case .professor: return .green
            case .companion: return .pink
            case .villain: return .black
            }
        }
        
        var icon: String {
            switch self {
            case .protagonist: return "star.fill"
            case .rival: return "person.2.fill"
            case .gymLeader: return "shield.fill"
            case .eliteFour: return "crown.fill"
            case .champion: return "trophy.fill"
            case .professor: return "graduationcap.fill"
            case .companion: return "heart.fill"
            case .villain: return "flame.fill"
            }
        }
    }
}

// MARK: - Character Database
struct CharacterDatabase {
    static let mainCharacters: [Character] = [
        // MARK: Protagonists
        Character(
            id: "ash-ketchum",
            name: "Ash Ketchum",
            role: .protagonist,
            region: "Kanto",
            age: 10,
            hometown: "Pallet Town",
            specialties: ["Electric", "Flying", "Fire"],
            pokemonTeam: ["Pikachu", "Charizard", "Greninja", "Lucario", "Dragonite", "Gengar"],
            description: "The main protagonist of the Pokémon anime series. Ash dreams of becoming a Pokémon Master and has traveled through many regions, competing in Pokémon Leagues and making countless friends.",
            achievements: [
                "Orange Islands Champion",
                "Battle Frontier Champion",
                "Alola League Champion",
                "World Coronation Series Champion"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/cd/Ash_JN.png/250px-Ash_JN.png",
            debut: "Pokémon - I Choose You!"
        ),
        Character(
            id: "red",
            name: "Red",
            role: .protagonist,
            region: "Kanto",
            age: 11,
            hometown: "Pallet Town",
            specialties: ["All Types"],
            pokemonTeam: ["Pikachu", "Charizard", "Venusaur", "Blastoise", "Snorlax", "Lapras"],
            description: "The protagonist of Pokémon Red, Blue, and Yellow. Known as the strongest trainer who defeated Team Rocket and became Champion of the Indigo League.",
            achievements: [
                "Kanto Champion",
                "Defeated Team Rocket",
                "Battle Legend"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/5/53/Red_Masters.png/256px-Red_Masters.png",
            debut: "Pokémon Red and Blue"
        ),
        
        // MARK: Companions
        Character(
            id: "misty",
            name: "Misty",
            role: .companion,
            region: "Kanto",
            age: 10,
            hometown: "Cerulean City",
            specialties: ["Water"],
            pokemonTeam: ["Psyduck", "Starmie", "Gyarados", "Corsola", "Politoed", "Azurill"],
            description: "Cerulean City Gym Leader and Ash's first traveling companion. Known for her fiery temper and expertise with Water-type Pokémon.",
            achievements: [
                "Cerulean City Gym Leader",
                "Whirl Cup Top 8",
                "Water Pokémon Master in training"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/b/b0/Misty_JN.png/250px-Misty_JN.png",
            debut: "Pokémon - I Choose You!"
        ),
        Character(
            id: "brock",
            name: "Brock",
            role: .companion,
            region: "Kanto",
            age: 15,
            hometown: "Pewter City",
            specialties: ["Rock", "Ground"],
            pokemonTeam: ["Steelix", "Crobat", "Geodude", "Marshtomp", "Forretress", "Croagunk"],
            description: "Former Pewter City Gym Leader who traveled with Ash through multiple regions. Now a Pokémon Doctor.",
            achievements: [
                "Pewter City Gym Leader",
                "Pokémon Doctor",
                "Pokémon Breeder"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/e/ee/Brock_JN.png/250px-Brock_JN.png",
            debut: "Showdown in Pewter City"
        ),
        Character(
            id: "serena",
            name: "Serena",
            role: .companion,
            region: "Kalos",
            age: 10,
            hometown: "Vaniville Town",
            specialties: ["Fairy", "Fire", "Flying"],
            pokemonTeam: ["Braixen", "Pancham", "Sylveon"],
            description: "A Pokémon Performer from Kalos who traveled with Ash. Known for her performances and strong bond with her Pokémon.",
            achievements: [
                "Kalos Queen Runner-up",
                "Pokémon Performer",
                "Multiple Princess Keys"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/f/f5/Serena_XY.png/250px-Serena_XY.png",
            debut: "Kalos, Where Dreams and Adventures Begin!"
        ),
        Character(
            id: "dawn",
            name: "Dawn",
            role: .companion,
            region: "Sinnoh",
            age: 10,
            hometown: "Twinleaf Town",
            specialties: ["Water", "Ice", "Normal"],
            pokemonTeam: ["Piplup", "Buneary", "Pachirisu", "Mamoswine", "Quilava", "Togekiss"],
            description: "A Pokémon Coordinator from Sinnoh who aimed to follow in her mother's footsteps. Known for her catchphrase 'No need to worry!'",
            achievements: [
                "Grand Festival Runner-up",
                "Wallace Cup Winner",
                "Multiple Contest Ribbons"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/3e/Dawn_JN.png/250px-Dawn_JN.png",
            debut: "Following a Maiden's Voyage!"
        ),
        Character(
            id: "may",
            name: "May",
            role: .companion,
            region: "Hoenn",
            age: 10,
            hometown: "Petalburg City",
            specialties: ["Fire", "Grass", "Ice"],
            pokemonTeam: ["Blaziken", "Beautifly", "Skitty", "Venusaur", "Munchlax", "Glaceon"],
            description: "A Pokémon Coordinator from Hoenn who initially started her journey reluctantly but grew to love Pokémon Contests.",
            achievements: [
                "Grand Festival Top 8",
                "Kanto Grand Festival Top 4",
                "Multiple Contest Ribbons"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/9/95/May_AG.png/200px-May_AG.png",
            debut: "Get the Show on the Road!"
        ),
        
        // MARK: Rivals
        Character(
            id: "gary-oak",
            name: "Gary Oak",
            role: .rival,
            region: "Kanto",
            age: 10,
            hometown: "Pallet Town",
            specialties: ["Various"],
            pokemonTeam: ["Blastoise", "Umbreon", "Electivire", "Scizor", "Arcanine", "Nidoking"],
            description: "Professor Oak's grandson and Ash's first rival. Initially arrogant, he later became a Pokémon Researcher.",
            achievements: [
                "Pokémon Researcher",
                "Former Trainer",
                "Multiple Badge Winner"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/cc/Gary_Oak_JN.png/250px-Gary_Oak_JN.png",
            debut: "Pokémon - I Choose You!"
        ),
        Character(
            id: "paul",
            name: "Paul",
            role: .rival,
            region: "Sinnoh",
            age: 11,
            hometown: "Veilstone City",
            specialties: ["Various"],
            pokemonTeam: ["Electivire", "Drapion", "Aggron", "Gastrodon", "Ninjask", "Froslass"],
            description: "Ash's main rival in Sinnoh, known for his harsh training methods and focus on power. Eventually learned to respect his Pokémon.",
            achievements: [
                "Battle Pyramid Winner",
                "Sinnoh League Top 8",
                "Multiple Region Badges"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/0/0b/Paul_DP.png/250px-Paul_DP.png",
            debut: "Two Degrees of Separation!"
        ),
        
        // MARK: Professors
        Character(
            id: "professor-oak",
            name: "Professor Oak",
            role: .professor,
            region: "Kanto",
            age: 60,
            hometown: "Pallet Town",
            specialties: ["Research", "Poetry"],
            pokemonTeam: ["Dragonite", "Rotom"],
            description: "The most renowned Pokémon Professor, specializing in Pokémon and human relationships. Gives new trainers their first Pokémon.",
            achievements: [
                "Leading Pokémon Researcher",
                "Pokédex Creator",
                "Former Champion"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/3b/Professor_Oak_JN.png/250px-Professor_Oak_JN.png",
            debut: "Pokémon - I Choose You!"
        ),
        Character(
            id: "professor-kukui",
            name: "Professor Kukui",
            role: .professor,
            region: "Alola",
            age: nil,
            hometown: "Hau'oli City",
            specialties: ["Pokémon Moves", "Battle"],
            pokemonTeam: ["Incineroar", "Braviary", "Lucario", "Venusaur", "Empoleon", "Melmetal"],
            description: "Alola's Pokémon Professor who researches Pokémon moves. Also known as the Masked Royal, a famous Battle Royal fighter.",
            achievements: [
                "Alola League Founder",
                "Battle Royal Champion",
                "Move Researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/a/a4/Professor_Kukui_SM.png/250px-Professor_Kukui_SM.png",
            debut: "Alola to New Adventure!"
        ),
        
        // MARK: Champions
        Character(
            id: "cynthia",
            name: "Cynthia",
            role: .champion,
            region: "Sinnoh",
            age: nil,
            hometown: "Celestic Town",
            specialties: ["Various"],
            pokemonTeam: ["Garchomp", "Lucario", "Milotic", "Roserade", "Togekiss", "Spiritomb"],
            description: "The Champion of the Sinnoh region and one of the strongest trainers in the world. Also a Pokémon archaeologist.",
            achievements: [
                "Sinnoh Champion",
                "World Championship Runner-up",
                "Mythology Researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/30/Cynthia_Masters.png/256px-Cynthia_Masters.png",
            debut: "Top-Down Training!"
        ),
        Character(
            id: "leon",
            name: "Leon",
            role: .champion,
            region: "Galar",
            age: nil,
            hometown: "Postwick",
            specialties: ["Various"],
            pokemonTeam: ["Charizard", "Dragapult", "Aegislash", "Haxorus", "Rhyperior", "Mr. Rime"],
            description: "The undefeated Champion of Galar and formerly the World Coronation Series Monarch. Known for getting lost easily.",
            achievements: [
                "Galar Champion",
                "Former World Monarch",
                "Undefeated Streak"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/c8/Leon_Masters.png/256px-Leon_Masters.png",
            debut: "Letter of the Law!"
        ),
        
        // MARK: Villains
        Character(
            id: "giovanni",
            name: "Giovanni",
            role: .villain,
            region: "Kanto",
            age: nil,
            hometown: "Unknown",
            specialties: ["Ground", "Poison"],
            pokemonTeam: ["Persian", "Rhyperior", "Nidoking", "Garchomp", "Kingler", "Rhydon"],
            description: "The leader of Team Rocket and former Viridian City Gym Leader. A powerful trainer with ambitions to control legendary Pokémon.",
            achievements: [
                "Team Rocket Boss",
                "Former Gym Leader",
                "Crime Syndicate Leader"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/4/45/Giovanni_Masters.png/256px-Giovanni_Masters.png",
            debut: "Battle Aboard the St. Anne"
        ),
        Character(
            id: "jessie",
            name: "Jessie",
            role: .villain,
            region: "Kanto",
            age: 25,
            hometown: "Unknown",
            specialties: ["Poison", "Bug"],
            pokemonTeam: ["Wobbuffet", "Seviper", "Yanmega", "Gourgeist", "Mimikyu", "Arbok"],
            description: "A member of Team Rocket who constantly follows Ash to steal Pikachu. Despite being a villain, she has a good heart.",
            achievements: [
                "Team Rocket Agent",
                "Pokémon Coordinator",
                "Performer"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/5/57/Jessie_JN.png/250px-Jessie_JN.png",
            debut: "Pokémon Emergency!"
        ),
        Character(
            id: "james",
            name: "James",
            role: .villain,
            region: "Kanto",
            age: 25,
            hometown: "Unknown",
            specialties: ["Grass", "Poison"],
            pokemonTeam: ["Weezing", "Carnivine", "Mareanie", "Morpeko", "Cacnea", "Chimecho"],
            description: "A member of Team Rocket trio with Jessie and Meowth. Despite his villainous role, he's kind-hearted and cares for his Pokémon.",
            achievements: [
                "Team Rocket Agent",
                "Bottle Cap Collector",
                "Rich Heritage"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/e/e8/James_JN.png/250px-James_JN.png",
            debut: "Pokémon Emergency!"
        ),
        
        // MARK: More Companions
        Character(
            id: "iris",
            name: "Iris",
            role: .companion,
            region: "Unova",
            age: 10,
            hometown: "Village of Dragons",
            specialties: ["Dragon"],
            pokemonTeam: ["Haxorus", "Dragonite", "Emolga", "Excadrill", "Hydreigon", "Gible"],
            description: "A Dragon-type specialist who traveled with Ash through Unova. Later became Unova Champion.",
            achievements: [
                "Unova Champion",
                "Dragon Master in training",
                "Village of Dragons prodigy"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/3f/Iris_BW.png/250px-Iris_BW.png",
            debut: "In the Shadow of Zekrom!"
        ),
        Character(
            id: "cilan",
            name: "Cilan",
            role: .companion,
            region: "Unova",
            age: 16,
            hometown: "Striaton City",
            specialties: ["Grass", "Connoisseur"],
            pokemonTeam: ["Pansage", "Crustle", "Stunfisk"],
            description: "One of the Striaton City Gym Leaders and a Pokémon Connoisseur who traveled with Ash.",
            achievements: [
                "Striaton City Gym Leader",
                "A-Class Pokémon Connoisseur",
                "Fishing Connoisseur"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/0/01/Cilan_BW.png/250px-Cilan_BW.png",
            debut: "Triple Leaders, Team Threats!"
        ),
        Character(
            id: "clemont",
            name: "Clemont",
            role: .companion,
            region: "Kalos",
            age: 12,
            hometown: "Lumiose City",
            specialties: ["Electric", "Inventor"],
            pokemonTeam: ["Bunnelby", "Chespin", "Luxray", "Heliolisk", "Magneton"],
            description: "Lumiose City Gym Leader and inventor who traveled with Ash through Kalos.",
            achievements: [
                "Lumiose City Gym Leader",
                "Inventor extraordinaire",
                "Created Clembot"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/c5/Clemont_XY.png/250px-Clemont_XY.png",
            debut: "Kalos, Where Dreams and Adventures Begin!"
        ),
        Character(
            id: "bonnie",
            name: "Bonnie",
            role: .companion,
            region: "Kalos",
            age: 7,
            hometown: "Lumiose City",
            specialties: ["Caring", "Support"],
            pokemonTeam: ["Dedenne", "Squishy (Zygarde Core)"],
            description: "Clemont's younger sister who traveled with Ash through Kalos. Too young to be a trainer but cared for Dedenne.",
            achievements: [
                "Zygarde Core caretaker",
                "Future trainer",
                "Helped save Kalos"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/8a/Bonnie_XY.png/250px-Bonnie_XY.png",
            debut: "Kalos, Where Dreams and Adventures Begin!"
        ),
        Character(
            id: "lillie",
            name: "Lillie",
            role: .companion,
            region: "Alola",
            age: 11,
            hometown: "Melemele Island",
            specialties: ["Research", "Ice"],
            pokemonTeam: ["Snowy (Alolan Vulpix)", "Magearna"],
            description: "Professor Kukui's assistant and Ash's classmate who overcame her fear of touching Pokémon.",
            achievements: [
                "Overcame Pokémon phobia",
                "Found Mohn (father)",
                "Trainer in training"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/a/a5/Lillie_SM.png/250px-Lillie_SM.png",
            debut: "Alola to New Adventure!"
        ),
        Character(
            id: "kiawe",
            name: "Kiawe",
            role: .companion,
            region: "Alola",
            age: 11,
            hometown: "Akala Island",
            specialties: ["Fire"],
            pokemonTeam: ["Turtonator", "Charizard", "Marowak"],
            description: "Ash's classmate and rival in Alola. Works on his family's farm and specializes in Fire-types.",
            achievements: [
                "Trial Captain",
                "Grand Trial winner",
                "Fire dancer"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/f/f8/Kiawe_SM.png/250px-Kiawe_SM.png",
            debut: "Alola to New Adventure!"
        ),
        Character(
            id: "sophocles",
            name: "Sophocles",
            role: .companion,
            region: "Alola",
            age: 11,
            hometown: "Melemele Island",
            specialties: ["Electric", "Technology"],
            pokemonTeam: ["Togedemaru", "Vikavolt", "Charjabug"],
            description: "Ash's classmate in Alola who loves technology and Electric-type Pokémon.",
            achievements: [
                "Trial Captain",
                "Tech genius",
                "Charjabug race winner"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/cc/Sophocles_SM.png/250px-Sophocles_SM.png",
            debut: "Alola to New Adventure!"
        ),
        Character(
            id: "mallow",
            name: "Mallow",
            role: .companion,
            region: "Alola",
            age: 11,
            hometown: "Akala Island",
            specialties: ["Grass", "Cooking"],
            pokemonTeam: ["Tsareena", "Shaymin"],
            description: "Ash's classmate and aspiring chef who specializes in Grass-type Pokémon.",
            achievements: [
                "Trial Captain",
                "Restaurant helper",
                "Master chef in training"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/e/e6/Mallow_SM.png/250px-Mallow_SM.png",
            debut: "Alola to New Adventure!"
        ),
        Character(
            id: "lana",
            name: "Lana",
            role: .companion,
            region: "Alola",
            age: 11,
            hometown: "Melemele Island",
            specialties: ["Water", "Fishing"],
            pokemonTeam: ["Primarina", "Eevee (Sandy)"],
            description: "Ash's classmate who loves Water-type Pokémon and fishing.",
            achievements: [
                "Trial Captain",
                "Z-Move master",
                "Expert fisher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/7/73/Lana_SM.png/250px-Lana_SM.png",
            debut: "Alola to New Adventure!"
        ),
        Character(
            id: "goh",
            name: "Goh",
            role: .companion,
            region: "Kanto",
            age: 10,
            hometown: "Vermilion City",
            specialties: ["Catching", "Research"],
            pokemonTeam: ["Cinderace", "Inteleon", "Grookey", "Suicune", "Eternatus", "Regieleki"],
            description: "Ash's research partner at Cerise Laboratory. His goal is to catch every Pokémon, including Mew.",
            achievements: [
                "Project Mew member",
                "Caught over 100 Pokémon",
                "Legendary Pokémon trainer"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/6/65/Goh_JN.png/250px-Goh_JN.png",
            debut: "Enter Pikachu!"
        ),
        Character(
            id: "chloe",
            name: "Chloe",
            role: .companion,
            region: "Kanto",
            age: 10,
            hometown: "Vermilion City",
            specialties: ["Research", "School"],
            pokemonTeam: ["Eevee", "Yamper"],
            description: "Professor Cerise's daughter who initially wasn't interested in Pokémon but grew to love them.",
            achievements: [
                "Student researcher",
                "Eevee specialist",
                "Contest participant"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/b/bc/Chloe_JN.png/250px-Chloe_JN.png",
            debut: "Enter Pikachu!"
        ),
        
        // MARK: More Rivals
        Character(
            id: "trip",
            name: "Trip",
            role: .rival,
            region: "Unova",
            age: 10,
            hometown: "Nuvema Town",
            specialties: ["Photography", "Strategy"],
            pokemonTeam: ["Serperior", "Conkeldurr", "Vanilluxe", "Lampent", "Tranquill"],
            description: "Ash's main rival in Unova who looks down on trainers from Kanto.",
            achievements: [
                "Unova League participant",
                "Photographer",
                "Beat multiple Gym Leaders"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/4/41/Trip_BW.png/250px-Trip_BW.png",
            debut: "In the Shadow of Zekrom!"
        ),
        Character(
            id: "bianca",
            name: "Bianca",
            role: .rival,
            region: "Unova",
            age: 10,
            hometown: "Nuvema Town",
            specialties: ["Cute Pokémon", "Enthusiasm"],
            pokemonTeam: ["Emboar", "Chandelure", "Minccino", "Escavalier"],
            description: "A bubbly trainer from Unova who often bumps into people when excited.",
            achievements: [
                "Unova League Top 16",
                "Clubsplosion participant",
                "Multiple badge winner"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/30/Bianca_BW.png/250px-Bianca_BW.png",
            debut: "Minccino—Neat and Tidy!"
        ),
        Character(
            id: "cameron",
            name: "Cameron",
            role: .rival,
            region: "Unova",
            age: 10,
            hometown: "Unknown",
            specialties: ["Power", "Determination"],
            pokemonTeam: ["Lucario", "Ferrothorn", "Hydreigon", "Samurott", "Swanna"],
            description: "An absent-minded but determined trainer who defeated Ash in the Unova League.",
            achievements: [
                "Unova League Top 8",
                "Defeated Ash",
                "8 Unova badges"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/cd/Cameron_BW.png/250px-Cameron_BW.png",
            debut: "Goodbye, Junior Cup—Hello, Adventure!"
        ),
        Character(
            id: "alain",
            name: "Alain",
            role: .rival,
            region: "Kalos",
            age: nil,
            hometown: "Unknown",
            specialties: ["Mega Evolution", "Power"],
            pokemonTeam: ["Mega Charizard X", "Metagross", "Tyranitar", "Weavile", "Bisharp", "Unfezant"],
            description: "Professor Sycamore's former assistant and Ash's strongest rival in Kalos.",
            achievements: [
                "Kalos League Champion",
                "Defeated 10 Mega Evolution trainers",
                "Team Flare agent (former)"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/d/d6/Alain_XY.png/250px-Alain_XY.png",
            debut: "Mega Evolution Special I"
        ),
        Character(
            id: "sawyer",
            name: "Sawyer",
            role: .rival,
            region: "Kalos",
            age: 10,
            hometown: "Unknown",
            specialties: ["Analysis", "Note-taking"],
            pokemonTeam: ["Mega Sceptile", "Salamence", "Slaking", "Clawitzer", "Slurpuff", "Aegislash"],
            description: "A studious trainer who looked up to Ash and took detailed notes on battles.",
            achievements: [
                "Kalos League Top 4",
                "8 Kalos badges",
                "Defeated Ash once"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/3/37/Sawyer_XY.png/250px-Sawyer_XY.png",
            debut: "Battling with Elegance and a Big Smile!"
        ),
        Character(
            id: "gladion",
            name: "Gladion",
            role: .rival,
            region: "Alola",
            age: 12,
            hometown: "Aether Paradise",
            specialties: ["Dark", "Edgy"],
            pokemonTeam: ["Silvally", "Lycanroc (Midnight)", "Crobat", "Zoroark", "Umbreon"],
            description: "Lillie's older brother and Ash's rival in Alola. Former Team Skull enforcer.",
            achievements: [
                "Alola League runner-up",
                "Team Skull enforcer",
                "Aether Foundation heir"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/7/72/Gladion_SM.png/250px-Gladion_SM.png",
            debut: "A Glaring Rivalry!"
        ),
        
        // MARK: More Elite Four & Champions
        Character(
            id: "lance",
            name: "Lance",
            role: .champion,
            region: "Johto/Kanto",
            age: nil,
            hometown: "Blackthorn City",
            specialties: ["Dragon"],
            pokemonTeam: ["Dragonite", "Dragonite", "Dragonite", "Gyarados", "Charizard", "Aerodactyl"],
            description: "Dragon Master and Champion of the Indigo League. Member of the Elite Four.",
            achievements: [
                "Kanto/Johto Champion",
                "Dragon Master",
                "G-Men member"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/5/56/Lance_Masters.png/256px-Lance_Masters.png",
            debut: "The Lake of Rage"
        ),
        Character(
            id: "steven",
            name: "Steven Stone",
            role: .champion,
            region: "Hoenn",
            age: nil,
            hometown: "Mossdeep City",
            specialties: ["Steel", "Rock", "Minerals"],
            pokemonTeam: ["Mega Metagross", "Skarmory", "Cradily", "Armaldo", "Claydol", "Aggron"],
            description: "Former Hoenn Champion and stone collector. Son of Devon Corporation president.",
            achievements: [
                "Hoenn Champion",
                "Stone collector",
                "Mega Stone researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/88/Steven_Masters.png/256px-Steven_Masters.png",
            debut: "Dewford Town"
        ),
        Character(
            id: "diantha",
            name: "Diantha",
            role: .champion,
            region: "Kalos",
            age: nil,
            hometown: "Unknown",
            specialties: ["Various", "Acting"],
            pokemonTeam: ["Mega Gardevoir", "Gourgeist", "Goodra", "Hawlucha", "Tyrantrum", "Aurorus"],
            description: "Kalos Champion and famous movie star. Known for her elegance in battle.",
            achievements: [
                "Kalos Champion",
                "Famous actress",
                "Top 8 World Coronation Series"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/5/5a/Diantha_XY.png/250px-Diantha_XY.png",
            debut: "The Bonds of Evolution!"
        ),
        
        // MARK: More Professors
        Character(
            id: "professor-elm",
            name: "Professor Elm",
            role: .professor,
            region: "Johto",
            age: nil,
            hometown: "New Bark Town",
            specialties: ["Breeding", "Eggs"],
            pokemonTeam: ["Corsola"],
            description: "Johto's Pokémon Professor who specializes in Pokémon breeding and was Professor Oak's student.",
            achievements: [
                "Pokémon breeding expert",
                "Egg research pioneer",
                "Discovered baby Pokémon"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/b/bd/Professor_Elm_JN.png/250px-Professor_Elm_JN.png",
            debut: "Don't Touch That 'dile"
        ),
        Character(
            id: "professor-birch",
            name: "Professor Birch",
            role: .professor,
            region: "Hoenn",
            age: nil,
            hometown: "Littleroot Town",
            specialties: ["Field Research", "Habitats"],
            pokemonTeam: ["Beldum"],
            description: "Hoenn's Pokémon Professor who studies Pokémon habitats and behaviors in the wild.",
            achievements: [
                "Habitat researcher",
                "Field work expert",
                "Father of May/Brendan"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/f/fb/Professor_Birch_AG.png/250px-Professor_Birch_AG.png",
            debut: "Get the Show on the Road!"
        ),
        Character(
            id: "professor-rowan",
            name: "Professor Rowan",
            role: .professor,
            region: "Sinnoh",
            age: 60,
            hometown: "Sandgem Town",
            specialties: ["Evolution", "Forms"],
            pokemonTeam: ["Staraptor"],
            description: "Sinnoh's Pokémon Professor who studies Pokémon evolution. Professor Oak's senior.",
            achievements: [
                "Evolution expert",
                "Professor Oak's senior",
                "Discovered many evolution methods"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/c5/Professor_Rowan_DP.png/250px-Professor_Rowan_DP.png",
            debut: "Following a Maiden's Voyage!"
        ),
        Character(
            id: "professor-juniper",
            name: "Professor Juniper",
            role: .professor,
            region: "Unova",
            age: nil,
            hometown: "Nuvema Town",
            specialties: ["Origins", "Distribution"],
            pokemonTeam: ["Accelgor"],
            description: "Unova's Pokémon Professor who studies the origins of Pokémon.",
            achievements: [
                "Origin researcher",
                "First female professor",
                "Dream World researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/80/Professor_Juniper_BW.png/250px-Professor_Juniper_BW.png",
            debut: "In the Shadow of Zekrom!"
        ),
        Character(
            id: "professor-sycamore",
            name: "Professor Sycamore",
            role: .professor,
            region: "Kalos",
            age: nil,
            hometown: "Lumiose City",
            specialties: ["Mega Evolution", "Change"],
            pokemonTeam: ["Garchomp"],
            description: "Kalos's Pokémon Professor who studies Mega Evolution and Pokémon change.",
            achievements: [
                "Mega Evolution discoverer",
                "Former student of Rowan",
                "Published researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/f/f5/Professor_Sycamore_XY.png/250px-Professor_Sycamore_XY.png",
            debut: "Lumiose City Pursuit!"
        ),
        Character(
            id: "professor-cerise",
            name: "Professor Cerise",
            role: .professor,
            region: "Kanto",
            age: nil,
            hometown: "Vermilion City",
            specialties: ["All Pokémon", "Research"],
            pokemonTeam: ["Yamper"],
            description: "Runs the Cerise Laboratory where Ash and Goh work as research fellows.",
            achievements: [
                "Laboratory director",
                "All-region researcher",
                "Mew researcher"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/a/ad/Professor_Cerise_JN.png/250px-Professor_Cerise_JN.png",
            debut: "Enter Pikachu!"
        ),
        
        // MARK: Team Leaders
        Character(
            id: "cyrus",
            name: "Cyrus",
            role: .villain,
            region: "Sinnoh",
            age: 27,
            hometown: "Sunyshore City",
            specialties: ["Dark", "Technology"],
            pokemonTeam: ["Weavile", "Honchkrow", "Crobat", "Gyarados", "Houndoom", "Dialga/Palkia"],
            description: "Leader of Team Galactic who sought to create a new world without emotions.",
            achievements: [
                "Team Galactic Boss",
                "Summoned Dialga/Palkia",
                "Technology genius"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/8f/Cyrus_Masters.png/256px-Cyrus_Masters.png",
            debut: "Losing Its Lustrous"
        ),
        Character(
            id: "ghetsis",
            name: "Ghetsis",
            role: .villain,
            region: "Unova",
            age: nil,
            hometown: "Unknown",
            specialties: ["Manipulation", "Power"],
            pokemonTeam: ["Hydreigon", "Cofagrigus", "Seismitoad", "Eelektross", "Drapion", "Toxicroak"],
            description: "True leader of Team Plasma who manipulated N for his own goals.",
            achievements: [
                "Team Plasma Boss",
                "Master manipulator",
                "Nearly conquered Unova"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/81/Ghetsis_Masters.png/256px-Ghetsis_Masters.png",
            debut: "Team Plasma's Pokémon Power Plot!"
        ),
        Character(
            id: "lysandre",
            name: "Lysandre",
            role: .villain,
            region: "Kalos",
            age: nil,
            hometown: "Unknown",
            specialties: ["Technology", "Beauty"],
            pokemonTeam: ["Mega Gyarados", "Pyroar", "Honchkrow", "Mienshao"],
            description: "Leader of Team Flare who sought to create a beautiful world by destroying the current one.",
            achievements: [
                "Team Flare Boss",
                "Inventor",
                "Former philanthropist"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/f/f5/Lysandre_XY.png/250px-Lysandre_XY.png",
            debut: "Mega Evolution Special II"
        ),
        Character(
            id: "lusamine",
            name: "Lusamine",
            role: .villain,
            region: "Alola",
            age: 41,
            hometown: "Aether Paradise",
            specialties: ["Ultra Beasts", "Beauty"],
            pokemonTeam: ["Bewear", "Lilligant", "Milotic", "Mismagius", "Clefable"],
            description: "President of the Aether Foundation who became obsessed with Ultra Beasts.",
            achievements: [
                "Aether Foundation President",
                "Ultra Beast researcher",
                "Mother of Lillie and Gladion"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/c/cc/Lusamine_SM.png/250px-Lusamine_SM.png",
            debut: "A Dream Encounter!"
        ),
        Character(
            id: "rose",
            name: "Chairman Rose",
            role: .villain,
            region: "Galar",
            age: nil,
            hometown: "Wyndon",
            specialties: ["Business", "Energy"],
            pokemonTeam: ["Copperajah", "Ferrothorn", "Perrserker", "Escavalier", "Klinklang"],
            description: "Chairman of the Galar League who awakened Eternatus to solve an energy crisis.",
            achievements: [
                "League Chairman",
                "Macro Cosmos CEO",
                "Awakened Eternatus"
            ],
            imageURL: "https://archives.bulbagarden.net/media/upload/thumb/8/85/Chairman_Rose_TW.png/250px-Chairman_Rose_TW.png",
            debut: "Sword and Shield: The Darkest Day!"
        )
    ]
    
    static func getCharactersByRole(_ role: Character.CharacterRole) -> [Character] {
        mainCharacters.filter { $0.role == role }
    }
    
    static func getCharactersByRegion(_ region: String) -> [Character] {
        mainCharacters.filter { $0.region == region }
    }
    
    static func getCharacter(id: String) -> Character? {
        mainCharacters.first { $0.id == id }
    }
}