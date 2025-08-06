//
//  BerryListView.swift
//  LuminaDex
//
//  Berry collection view with grid layout
//

import SwiftUI

struct BerryListView: View {
    @StateObject private var viewModel = BerryListViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: BerryCategory? = nil
    @State private var showingFilters = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    var filteredBerries: [Berry] {
        viewModel.berries.filter { berry in
            let matchesSearch = searchText.isEmpty || 
                berry.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || 
                BerryCategory.categorize(berry) == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Category filter
                    categoryFilter
                    
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        // Berry grid
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredBerries) { berry in
                                    NavigationLink(destination: BerryDetailView(berry: berry)) {
                                        BerryCardView(berry: berry)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Berry Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            await viewModel.loadBerries()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search berries...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All berries
                BerryCategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .gray,
                    action: {
                        selectedCategory = nil
                    }
                )
                
                ForEach(BerryCategory.allCases, id: \.self) { category in
                    BerryCategoryChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        color: category.color,
                        action: {
                            selectedCategory = category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Loading berries...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BerryCategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? color : Color.white.opacity(0.1)
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct BerryCardView: View {
    let berry: Berry
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Berry image
            AsyncImage(url: URL(string: berry.spriteURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .onAppear { imageLoaded = true }
                case .failure(_):
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }
            .scaleEffect(imageLoaded ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: imageLoaded)
            
            // Berry name
            Text(berry.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Berry size indicator
            HStack(spacing: 2) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < berry.size / 100 ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding()
        .frame(width: 100, height: 120)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - View Model
@MainActor
class BerryListViewModel: ObservableObject {
    @Published var berries: [Berry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetcher = BerryFetcher()
    
    func loadBerries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            berries = try await fetcher.fetchAllBerries()
        } catch {
            errorMessage = "Failed to load berries: \(error.localizedDescription)"
            print("Error loading berries: \(error)")
        }
        
        isLoading = false
    }
}