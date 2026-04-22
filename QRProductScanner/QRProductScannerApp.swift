//
//  QRProductScannerApp.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import SwiftUI
import SwiftData

@main
struct QRProductScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ScanRecord.self)
    }
}
