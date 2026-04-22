//
//   Product.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
 
// MARK: - API Response Models
struct ProductAPIResponse: Codable {
    let status: Int
    let product: ProductDetail?
}
 
struct ProductDetail: Codable {
    let productName: String?
    let brands: String?
    let categories: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case categories
        case imageURL = "image_url"
    }
}
 
// MARK: - Display Model
struct Product {
    let name: String
    let brand: String
    let category: String
    let status: VerificationStatus
    let imageURL: String?
    
    init(from detail: ProductDetail?) {
        if let detail = detail, let name = detail.productName, !name.isEmpty {
            self.name = name
            self.brand = detail.brands?.components(separatedBy: ",").first?
                .trimmingCharacters(in: .whitespaces) ?? "Unknown Brand"
            
            // Take last category — it's most specific (e.g. "Rice Noodles" not "Plant-based foods")
            self.category = detail.categories?.components(separatedBy: ",").last?
                .trimmingCharacters(in: .whitespaces) ?? ""
            
            self.status = .genuine
            self.imageURL = detail.imageURL
        } else {
            self.name = "Unknown Product"
            self.brand = "Unknown Brand"
            self.category = ""
            self.status = .unverified
            self.imageURL = nil
        }
    }
}
 
// MARK: - Verification Status
enum VerificationStatus: String, Codable {
    case genuine = "Genuine"
    case unverified = "Unverified"
    
    var color: String {
        switch self {
        case .genuine:
            return "green"
        case .unverified:
            return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .genuine:
            return "checkmark.seal.fill"
        case .unverified:
            return "exclamationmark.triangle.fill"
        }
    }
}
