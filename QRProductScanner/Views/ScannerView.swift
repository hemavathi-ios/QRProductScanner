//
//  ScannerView.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import SwiftUI
import SwiftData
 
struct ScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var cameraService = CameraService()
    @StateObject private var viewModel = ScannerViewModel()
    
    @State private var isSetup = false
        
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                if cameraService.permissionStatus == .authorized {
                    CameraPreview(session: cameraService.captureSession)
                        .ignoresSafeArea()
                    
                    // Scanning overlay
                    ScannerOverlay()
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Verifying product...")
                                .foregroundStyle(.white)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                } else if cameraService.permissionStatus == .denied {
                    // Permission denied view
                    CameraPermissionDeniedView()
                } else {
                    // Requesting permission view
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Requesting camera access...")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            Text(errorMessage)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    }
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingProductDetail) {
                if let product = viewModel.scannedProduct {
                    ProductDetailView(product: product) {
                        viewModel.resetScan()
                    }
                }
            }
            .onAppear {
                setupCamera()
            }
            .onDisappear {
                cameraService.stopSession()
                isSetup = false
            }
        }
    }
    
    private func setupCamera() {
        guard !isSetup else { return }
        
        cameraService.checkPermission()
        
        Task {
            if cameraService.permissionStatus == .notDetermined {
                let granted = await cameraService.requestPermission()
                cameraService.permissionStatus = granted ? .authorized : .denied
            }
            
            if cameraService.permissionStatus == .authorized {
                do {
                    viewModel.reinitialize(with: modelContext)
                    try cameraService.setupCamera(delegate: viewModel) // use viewModel, delete the vm lines
                    cameraService.startSession()
                    isSetup = true
                } catch {
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
 
// MARK: - Scanner Overlay
struct ScannerOverlay: View {
    var body: some View {
        VStack {
            Spacer()
            
            // Scanning frame
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 250, height: 250)
                .overlay {
                    VStack {
                        Spacer()
                        Text("Position QR code within frame")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, -50)
                }
            
            Spacer()
            
            // Instructions
            VStack(spacing: 12) {
                Label("Point camera at QR code", systemImage: "qrcode.viewfinder")
                    .foregroundStyle(.white)
                    .font(.headline)
                
                Text("Product will be verified automatically")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 40)
        }
    }
}
 
// MARK: - Permission Denied View
struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please enable camera access in Settings to scan QR codes")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
 
#Preview {
    ScannerView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
