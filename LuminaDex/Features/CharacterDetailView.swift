//
//  CharacterDetailView.swift
//  LuminaDex
//
//  Detailed view for Pokemon characters
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [character.role.color.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Character header
                    characterHeader
                    
                    // Tab selector
                    Picker("Info", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Team").tag(1)
                        Text("Achievements").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            overviewSection
                        case 1:
                            teamSection
                        case 2:
                            achievementsSection
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var characterHeader: some View {
        VStack(spacing: 16) {
            // Character image
            AsyncImage(url: URL(string: character.imageURL)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(character.role.color.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(character.role.color, lineWidth: 3)
                        )
                case .failure(_):
                    Circle()
                        .fill(character.role.color.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .shadow(color: character.role.color, radius: 10)
            
            // Character name and role
            VStack(spacing: 8) {
                Text(character.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: character.role.icon)
                    Text(character.role.rawValue)
                }
                .font(.subheadline)
                .foregroundColor(character.role.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(character.role.color.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding(.top, 20)
    }
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // Basic info
            VStack(alignment: .leading, spacing: 12) {
                Label("Basic Information", systemImage: "person.text.rectangle")
                    .font(.headline)
                    .foregroundColor(.white)
                
                CharacterInfoRow(label: "Region", value: character.region, icon: "map")
                CharacterInfoRow(label: "Hometown", value: character.hometown, icon: "house.fill")
                if let age = character.age {
                    CharacterInfoRow(label: "Age", value: "\(age) years old", icon: "calendar")
                }
                CharacterInfoRow(label: "Debut", value: character.debut, icon: "tv")
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Label("About", systemImage: "text.alignleft")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(character.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Specialties
            if !character.specialties.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Specialties", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    CharacterFlowLayout(spacing: 8) {
                        ForEach(character.specialties, id: \.self) { specialty in
                            Text(specialty)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(character.role.color.opacity(0.3))
                                .cornerRadius(15)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Pokémon Team", systemImage: "circle.circle.fill")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(character.pokemonTeam, id: \.self) { pokemon in
                    PokemonTeamCard(name: pokemon)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Achievements", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(character.achievements, id: \.self) { achievement in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                        
                        Text(achievement)
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    if achievement != character.achievements.last {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CharacterInfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct PokemonTeamCard: View {
    let name: String
    
    var spriteURL: String {
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(getPokemonId()).png"
    }
    
    func getPokemonId() -> String {
        // Comprehensive mapping for all Pokemon in character teams
        let mapping: [String: String] = [
            // Starters & Popular
            "Pikachu": "25",
            "Charizard": "6",
            "Greninja": "658",
            "Lucario": "448",
            "Dragonite": "149",
            "Gengar": "94",
            "Venusaur": "3",
            "Blastoise": "9",
            "Snorlax": "143",
            "Lapras": "131",
            
            // Water Types
            "Psyduck": "54",
            "Starmie": "121",
            "Gyarados": "130",
            "Corsola": "222",
            "Politoed": "186",
            "Azurill": "298",
            "Piplup": "393",
            "Buneary": "427",
            "Milotic": "350",
            "Primarina": "730",
            "Gyarados": "130",
            
            // Rock/Ground/Steel
            "Steelix": "208",
            "Geodude": "74",
            "Marshtomp": "259",
            "Forretress": "205",
            "Croagunk": "453",
            "Rhyperior": "464",
            "Aggron": "306",
            "Excadrill": "530",
            "Crustle": "558",
            "Stunfisk": "618",
            
            // Flying Types
            "Crobat": "169",
            "Togekiss": "468",
            "Beautifly": "267",
            "Swanna": "581",
            "Braviary": "628",
            "Unfezant": "521",
            "Tranquill": "520",
            
            // Fire Types
            "Braixen": "654",
            "Blaziken": "257",
            "Munchlax": "446",
            "Quilava": "156",
            "Turtonator": "776",
            "Incineroar": "727",
            "Emboar": "500",
            "Cinderace": "815",
            
            // Electric Types
            "Pachirisu": "417",
            "Electivire": "466",
            "Emolga": "587",
            "Togedemaru": "777",
            "Vikavolt": "738",
            "Charjabug": "737",
            "Heliolisk": "695",
            "Magneton": "82",
            
            // Grass Types
            "Pansage": "511",
            "Tsareena": "763",
            "Shaymin": "492",
            "Sceptile": "254",
            "Mega Sceptile": "254",
            "Roserade": "407",
            
            // Ice Types
            "Mamoswine": "473",
            "Glaceon": "471",
            "Snowy (Alolan Vulpix)": "37",
            "Froslass": "478",
            
            // Dragon Types
            "Haxorus": "612",
            "Gible": "443",
            "Hydreigon": "635",
            "Garchomp": "445",
            "Dragapult": "887",
            "Drapion": "452",
            "Salamence": "373",
            
            // Dark Types
            "Umbreon": "197",
            "Pancham": "674",
            "Zoroark": "571",
            "Weavile": "461",
            "Bisharp": "625",
            "Honchkrow": "430",
            
            // Fairy Types
            "Sylveon": "700",
            "Dedenne": "702",
            "Magearna": "801",
            
            // Normal Types
            "Skitty": "300",
            "Eevee": "133",
            "Eevee (Sandy)": "133",
            "Yamper": "835",
            "Persian": "53",
            "Slaking": "289",
            "Lopunny": "428",
            
            // Fighting Types
            "Chespin": "650",
            "Conkeldurr": "534",
            
            // Psychic Types
            "Spiritomb": "442",
            "Metagross": "376",
            "Mega Metagross": "376",
            
            // Bug Types
            "Bunnelby": "659",
            "Escavalier": "589",
            
            // Poison Types
            "Wobbuffet": "202",
            "Seviper": "336",
            "Yanmega": "469",
            "Gourgeist": "711",
            "Mimikyu": "778",
            "Arbok": "24",
            "Weezing": "110",
            "Carnivine": "455",
            "Mareanie": "747",
            "Morpeko": "877",
            "Cacnea": "331",
            "Chimecho": "358",
            
            // Other specific Pokemon
            "Nidoking": "34",
            "Scizor": "212",
            "Arcanine": "59",
            "Gastrodon": "423",
            "Ninjask": "291",
            "Luxray": "405",
            "Serperior": "497",
            "Vanilluxe": "584",
            "Lampent": "608",
            "Chandelure": "609",
            "Minccino": "572",
            "Ferrothorn": "598",
            "Samurott": "503",
            "Mega Charizard X": "6",
            "Tyranitar": "248",
            "Clawitzer": "693",
            "Slurpuff": "685",
            "Aegislash": "681",
            "Silvally": "773",
            "Lycanroc (Midnight)": "745",
            "Dragonite": "149",
            "Aerodactyl": "142",
            "Skarmory": "227",
            "Cradily": "346",
            "Armaldo": "348",
            "Claydol": "344",
            "Mega Gardevoir": "282",
            "Goodra": "706",
            "Hawlucha": "701",
            "Tyrantrum": "697",
            "Aurorus": "699",
            "Rhyperior": "464",
            "Mr. Rime": "866",
            
            // Legendary/Special
            "Suicune": "245",
            "Eternatus": "890",
            "Regieleki": "894",
            "Squishy (Zygarde Core)": "718",
            "Melmetal": "809",
            "Dialga/Palkia": "483",
            
            // Team Villain Pokemon
            "Cofagrigus": "563",
            "Seismitoad": "537",
            "Eelektross": "604",
            "Toxicroak": "454",
            "Pyroar": "668",
            "Mienshao": "620",
            "Mega Gyarados": "130",
            "Bewear": "760",
            "Lilligant": "549",
            "Mismagius": "429",
            "Clefable": "36",
            "Copperajah": "879",
            "Perrserker": "863",
            "Klinklang": "601",
            
            // Professor Pokemon
            "Rotom": "479",
            "Beldum": "374",
            "Staraptor": "398",
            "Accelgor": "617",
            
            // Additional Pokemon
            "Empoleon": "395",
            "Kingler": "99",
            "Rhydon": "112",
            "Grookey": "810",
            "Inteleon": "818"
        ]
        return mapping[name] ?? "1"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: spriteURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                default:
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                }
            }
            
            Text(name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CharacterFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
            }
            
            height = y + maxHeight
        }
    }
}