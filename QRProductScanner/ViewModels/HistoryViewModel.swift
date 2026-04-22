//
//  HistoryViewModel.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
import SwiftData
 
@MainActor
class HistoryViewModel: ObservableObject {
    @Published var scans: [ScanRecord] = []
    @Published var searchText = ""
    @Published var selectedFilter: FilterOption = .all
    @Published var errorMessage: String?
    
    private var repository: ScanRepository?
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case genuine = "Genuine"
        case unverified = "Unverified"
        
        var verificationStatus: VerificationStatus? {
            switch self {
            case .all:
                return nil
            case .genuine:
                return .genuine
            case .unverified:
                return .unverified
            }
        }
    }
    
    init() {}
    
    init(repository: ScanRepository) {
        self.repository = repository
    }
    
    func reinitialize(with context: ModelContext) {
        self.repository = ScanRepository(modelContext: context)
        fetchScans()
    }
    
    /// Fetch and filter scans based on search and filter criteria
    func fetchScans() {
        guard let repository else { return }
        do {
            if !searchText.isEmpty {
                scans = try repository.searchScans(query: searchText)
            } else if let status = selectedFilter.verificationStatus {
                scans = try repository.fetchScans(byStatus: status)
            } else {
                scans = try repository.fetchAllScans()
            }
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load scan history: \(error.localizedDescription)"
            scans = []
        }
    }

    func deleteScan(_ scan: ScanRecord) {
        guard let repository else { return }
        do {
            try repository.deleteScan(scan)
            fetchScans()
        } catch {
            errorMessage = "Failed to delete scan: \(error.localizedDescription)"
        }
    }

    func deleteAllScans() {
        guard let repository else { return }
        do {
            try repository.deleteAllScans()
            scans = []
        } catch {
            errorMessage = "Failed to delete all scans: \(error.localizedDescription)"
        }
    }
}
