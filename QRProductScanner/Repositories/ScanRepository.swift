//
//  ScanRepository.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
import SwiftData
 
@MainActor
class ScanRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Save a new scan record
    func saveScan(_ scanRecord: ScanRecord) throws {
        modelContext.insert(scanRecord)
        try modelContext.save()
    }
    
    /// Fetch all scan records, sorted by date (newest first)
    func fetchAllScans() throws -> [ScanRecord] {
        let descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Search scans by product name
    func searchScans(query: String) throws -> [ScanRecord] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        let allScans = try modelContext.fetch(descriptor)
        
        return allScans.filter { scan in
            scan.productName.lowercased().contains(lowercaseQuery) ||
            scan.brand.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Filter scans by status
    func fetchScans(byStatus status: VerificationStatus) throws -> [ScanRecord] {
        let descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        let allScans = try modelContext.fetch(descriptor)
        
        return allScans.filter { $0.statusRaw == status.rawValue }
    }
    
    /// Delete a scan record
    func deleteScan(_ scanRecord: ScanRecord) throws {
        modelContext.delete(scanRecord)
        try modelContext.save()
    }
    
    /// Delete all scan records
    func deleteAllScans() throws {
        try modelContext.delete(model: ScanRecord.self)
        try modelContext.save()
    }
}
