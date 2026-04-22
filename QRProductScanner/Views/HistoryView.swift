//
//  HistoryView.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import SwiftUI
import SwiftData
 
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HistoryViewModel()
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search products...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                            viewModel.fetchScans()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.fetchScans()
                }
                
                // Filter Picker
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(HistoryViewModel.FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedFilter) { _, _ in
                    viewModel.fetchScans()
                }
                
                // Scan List
                if viewModel.scans.isEmpty {
                    EmptyHistoryView(
                        isSearching: !viewModel.searchText.isEmpty,
                        isFiltering: viewModel.selectedFilter != .all
                    )
                } else {
                    List {
                        ForEach(viewModel.scans) { scan in
                            ScanHistoryRow(scan: scan)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteScan(scan)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.scans.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Delete All Scans", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    viewModel.deleteAllScans()
                }
            } message: {
                Text("Are you sure you want to delete all scan history? This action cannot be undone.")
            }
            .onAppear {
                // Initialize with actual modelContext
                viewModel.reinitialize(with: modelContext)
            }
        }
    }
}
 
// MARK: - Scan History Row
struct ScanHistoryRow: View {
    let scan: ScanRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: scan.status.icon)
                .foregroundStyle(scan.status == .genuine ? .green : .red)
                .font(.title3)
                .frame(width: 60, height: 60)
                .background(scan.status == .genuine ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .clipShape(Circle())
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.productName)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(scan.brand)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if !scan.category.isEmpty && scan.category != "Uncategorized" {
                            Label(scan.category, systemImage: "tag.fill")
                        }
                    Spacer()
                    Label(scan.formattedScanTime, systemImage: "clock.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(scan.productName), \(scan.status.rawValue), scanned \(scan.formattedScanTime)")
    }
}
 
// MARK: - Empty State
struct EmptyHistoryView: View {
    let isSearching: Bool
    let isFiltering: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isSearching || isFiltering ? "magnifyingglass" : "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(emptyTitle)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(emptyMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var emptyTitle: String {
        if isSearching {
            return "No Results Found"
        } else if isFiltering {
            return "No Matching Scans"
        } else {
            return "No Scan History"
        }
    }
    
    private var emptyMessage: String {
        if isSearching {
            return "Try adjusting your search terms"
        } else if isFiltering {
            return "No scans match the selected filter"
        } else {
            return "Start scanning QR codes to build your history"
        }
    }
}
 
#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
