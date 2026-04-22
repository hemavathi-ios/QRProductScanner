//
//  ProductDetailView.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import SwiftUI
 
struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Badge
                    StatusBadge(status: product.status)
                        .padding(.top)
                    
                    // Product Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(
                            icon: "tag.fill",
                            label: "Product Name",
                            value: product.name
                        )
                        
                        Divider()
                        
                        DetailRow(
                            icon: "building.2.fill",
                            label: "Brand",
                            value: product.brand
                        )
                        
                        Divider()
                        
                        DetailRow(
                            icon: "square.grid.2x2.fill",
                            label: "Category",
                            value: product.category
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    // Additional Info
                    if product.status == .genuine {
                        InfoBox(
                            icon: "checkmark.shield.fill",
                            title: "Verified Product",
                            message: "This product has been verified in our database.",
                            color: .green
                        )
                    } else {
                        InfoBox(
                            icon: "exclamationmark.shield.fill",
                            title: "Unverified Product",
                            message: "This product could not be verified. It may not be in our database.",
                            color: .orange
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
 
// MARK: - Status Badge
struct StatusBadge: View {
    let status: VerificationStatus
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(status.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(status == .genuine ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .foregroundStyle(status == .genuine ? .green : .red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(status == .genuine ? Color.green : Color.red, lineWidth: 2)
        }
        .padding(.horizontal)
    }
}
 
// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}
 
// MARK: - Info Box
struct InfoBox: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
 
#Preview {
    ProductDetailView(
        product: Product(
            from: ProductDetail(
                productName: "Coca Cola",
                brands: "Coca-Cola",
                categories: "Beverages",
                imageURL: nil
            )
        ),
        onDismiss: {}
    )
}
