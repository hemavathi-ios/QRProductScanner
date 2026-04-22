//
//  ScanRecord.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
import SwiftData
 
@Model
final class ScanRecord {
    var id: UUID
    var productName: String
    var brand: String
    var category: String
    var statusRaw: String
    var scannedAt: Date
    var qrValue: String
    
    // Computed property for enum access
    var status: VerificationStatus {
        get {
            VerificationStatus(rawValue: statusRaw) ?? .unverified
        }
        set {
            statusRaw = newValue.rawValue
        }
    }
    
    init(product: Product, qrValue: String) {
        self.id = UUID()
        self.productName = product.name
        self.brand = product.brand
        self.category = product.category
        self.statusRaw = product.status.rawValue
        self.scannedAt = Date()
        self.qrValue = qrValue
    }
    
    // Formatted scan time for display
    var formattedScanTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scannedAt)
    }
}
