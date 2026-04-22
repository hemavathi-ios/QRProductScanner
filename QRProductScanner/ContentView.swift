//
//  ContentView.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import SwiftUI
 
struct ContentView: View {
    var body: some View {
        TabView {
            ScannerView()
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
    }
}
 
#Preview {
    ContentView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
