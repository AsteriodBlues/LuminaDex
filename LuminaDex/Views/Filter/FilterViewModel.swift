//
//  FilterViewModel.swift
//  LuminaDex
//
//  Day 24: Filter logic and state management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FilterViewModel: ObservableObject {
    @Published var criteria: FilterCriteria
    @Published var matchCount: Int = 0
    @Published var isLoading = false
    
    private let database = DatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(criteria: FilterCriteria = FilterCriteria()) {
        self.criteria = criteria
        
        // Update count when criteria changes
        $criteria
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newCriteria in
                Task {
                    await self?.updateMatchCount()
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleType(_ type: PokemonType) {
        if criteria.types.contains(type) {
            criteria.types.remove(type)
        } else {
            criteria.types.insert(type)
        }
    }
    
    func toggleGeneration(_ generation: Int) {
        if criteria.generations.contains(generation) {
            criteria.generations.remove(generation)
        } else {
            criteria.generations.insert(generation)
        }
    }
    
    func resetFilters() {
        criteria = FilterCriteria()
    }
    
    private func updateMatchCount() async {
        isLoading = true
        do {
            matchCount = try await database.countFilteredPokemon(criteria: criteria)
        } catch {
            print("Error counting filtered Pokemon: \(error)")
            matchCount = 0
        }
        isLoading = false
    }
}