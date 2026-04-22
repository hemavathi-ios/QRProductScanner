//
//  CameraService.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import AVFoundation
import UIKit
 
enum CameraError: LocalizedError {
    case permissionDenied
    case setupFailed
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera access denied. Please enable it in Settings."
        case .setupFailed:
            return "Failed to setup camera. Please try again."
        case .notAvailable:
            return "Camera not available on this device."
        }
    }
}
 
enum CameraPermissionStatus {
    case authorized
    case denied
    case notDetermined
}
 
@MainActor
class CameraService: NSObject, ObservableObject {
    @Published var permissionStatus: CameraPermissionStatus = .notDetermined
    
    private let session = AVCaptureSession()
    private var delegate: AVCaptureMetadataOutputObjectsDelegate?
    
    var captureSession: AVCaptureSession {
        session
    }
    
    /// Check current camera permission status
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionStatus = .authorized
        case .denied, .restricted:
            permissionStatus = .denied
        case .notDetermined:
            permissionStatus = .notDetermined
        @unknown default:
            permissionStatus = .notDetermined
        }
    }
    
    /// Request camera permission
    func requestPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    /// Setup camera session for QR scanning
    /// Setup camera session for QR scanning
    func setupCamera(delegate: AVCaptureMetadataOutputObjectsDelegate) throws {
        self.delegate = delegate
        
        // ← Remove existing inputs/outputs before re-adding
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            throw CameraError.notAvailable
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            throw CameraError.setupFailed
        }
        
        session.beginConfiguration()  // ← Wrap changes in begin/commit
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            session.commitConfiguration()
            throw CameraError.setupFailed
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128, .upce]
        } else {
            session.commitConfiguration()
            throw CameraError.setupFailed
        }
        
        session.commitConfiguration()
    }

    /// Start camera session
    func startSession() {
        let session = self.session
        Task.detached {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }

    /// Stop camera session
    func stopSession() {
        let session = self.session  // ← Same pattern
        Task.detached {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
}
