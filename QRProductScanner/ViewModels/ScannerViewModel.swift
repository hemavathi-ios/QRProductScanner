//
//  ScannerViewModel.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
import AVFoundation
import SwiftData
 
@MainActor
class ScannerViewModel: NSObject, ObservableObject {
    @Published var scannedProduct: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingProductDetail = false
    @Published var lastScannedCode: String?
    
    private let apiService = APIService.shared
    private var repository: ScanRepository?
    private var isProcessing = false
        
    override init() {
        super.init()
    }

    init(repository: ScanRepository) {
        self.repository = repository
        super.init()
    }
    
    func reinitialize(with context: ModelContext) {
        self.repository = ScanRepository(modelContext: context)
    }
    
    /// Handle QR code detection
    func handleQRCodeDetection(_ code: String) {
        // Prevent duplicate scans
        guard !isProcessing, code != lastScannedCode else { return }
        
        isProcessing = true
        lastScannedCode = code
        
        Task {
            await verifyProduct(barcode: code)
        }
    }
    
    /// Verify product with API and save to history
    private func verifyProduct(barcode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let product = try await apiService.fetchProduct(barcode: barcode)
            
            let scanRecord = ScanRecord(product: product, qrValue: barcode)
            try repository?.saveScan(scanRecord)
            
            scannedProduct = product
            showingProductDetail = true
            
        } catch {
            errorMessage = error.localizedDescription
            
            // ← On error, reset so user can try scanning again
            lastScannedCode = nil
            
            // Show error briefly, then clear it
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            errorMessage = nil
        }
        
        isLoading = false
        isProcessing = false  // ← Always reset, success or failure
    }
    
    /// Reset for new scan
    func resetScan() {
        showingProductDetail = false
        scannedProduct = nil
        errorMessage = nil
        lastScannedCode = nil
        isProcessing = false
    }
}
 
// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            Task { @MainActor in
                handleQRCodeDetection(stringValue)
            }
        }
    }
}
