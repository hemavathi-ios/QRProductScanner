//
//  APIService.swift
//  QRProductScanner
//
//  Created by Hemavathi on 22/04/26.
//

import Foundation
 
enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid QR code format"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode product data"
        case .productNotFound:
            return "Product not found in database"
        }
    }
}
 
actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // Fetch product details from Open Food Facts API
    /// - Parameter barcode: The barcode/QR value to look up
    /// - Returns: Product object with verification status
    func fetchProduct(barcode: String) async throws -> Product {
        // Clean the barcode (remove whitespace, special chars)
        let cleanBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanBarcode.isEmpty else {
            throw APIError.invalidURL
        }
        
        let urlString = "\(baseURL)/\(cleanBarcode).json"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            // Decode response
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ProductAPIResponse.self, from: data)
            
            // Check if product was found (status = 1 means found)
            guard apiResponse.status == 1 else {
                throw APIError.productNotFound
            }
            
            // Convert to display model
            return Product(from: apiResponse.product)
            
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
