
# QR Product Scanner - iOS Take-Home Assignment

> **Acviss Technologies - iOS Developer Position**  
> **Submitted by:** Hemavathi  
> **Date:** April 23, 2026

---

## 📱 Overview

QR Product Scanner is a production-ready iOS application that scans QR codes, verifies products against a real-time database, and maintains an offline-first scan history with search capabilities. Built for Acviss Technologies' product authentication platform.

**Key Features:**
- ✅ Real-time QR code scanning with AVFoundation
- ✅ Product verification via Open Food Facts API
- ✅ Fully offline scan history with SwiftData
- ✅ Search and filter functionality
- ✅ Clean architecture with MVVM + Repository pattern
- ✅ SwiftUI with modern iOS 17+ features

---

## 🏗️ Architecture

### **Pattern: MVVM + Repository**

I chose **MVVM (Model-View-ViewModel) with Repository pattern** for clear separation of concerns and testability:

```
┌─────────────────────────────────────────────────────┐
│                      Views                          │
│  (ScannerView, HistoryView, ProductDetailView)     │
└──────────────────┬──────────────────────────────────┘
                   │ Binds to @Published properties
                   ▼
┌─────────────────────────────────────────────────────┐
│                   ViewModels                        │
│     (ScannerViewModel, HistoryViewModel)            │
│  • Business logic                                   │
│  • State management                                 │
│  • Coordinate between Services & Repository        │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌──────────────┐      ┌──────────────────┐
│  Services    │      │   Repository     │
│              │      │                  │
│ • APIService │      │ • ScanRepository │
│ • CameraServ │      │   (Data layer)   │
└──────────────┘      └──────────────────┘
        │                     │
        ▼                     ▼
┌──────────────┐      ┌──────────────────┐
│ Network API  │      │   SwiftData      │
│ (Open Food   │      │   (Local DB)     │
│  Facts)      │      │                  │
└──────────────┘      └──────────────────┘
```

**Why this architecture?**

1. **Testability**: ViewModels contain pure business logic, easy to unit test
2. **Reusability**: Services and Repository can be used across multiple ViewModels
3. **Separation of Concerns**: Each layer has a single responsibility
4. **Maintainability**: Changes in one layer don't cascade to others
5. **Industry Standard**: Familiar pattern for iOS teams

---

## 📂 Project Structure

```
QRProductScanner/
├── App/
│   ├── QRProductScannerApp.swift      # App entry point, SwiftData container
│   └── ContentView.swift              # Root tab navigation
│
├── Models/
│   ├── Product.swift                  # API response & display models
│   └── ScanRecord.swift               # SwiftData @Model for persistence
│
├── ViewModels/
│   ├── ScannerViewModel.swift         # QR scanning & verification logic
│   └── HistoryViewModel.swift         # History management & search
│
├── Views/
│   ├── ScannerView.swift              # Camera preview & QR scanner UI
│   ├── ProductDetailView.swift        # Product verification result
│   ├── HistoryView.swift              # Scan history list with search
│   └── CameraPreview.swift            # UIKit camera wrapper
│
├── Services/
│   ├── APIService.swift               # Networking with async/await
│   └── CameraService.swift            # AVFoundation camera setup
│
├── Repositories/
│   └── ScanRepository.swift           # SwiftData CRUD operations
│
└── README.md                          # This file
```

---

## 🛠️ Technology Stack

### **Core Frameworks (Zero Third-Party Dependencies)**

| Component | Technology | Justification |
|-----------|------------|---------------|
| **UI Framework** | SwiftUI | Modern, declarative, rapid development |
| **Architecture** | MVVM + Repository | Clean separation, testable, maintainable |
| **Networking** | URLSession + async/await | Native, lightweight, modern concurrency |
| **Camera** | AVFoundation | Direct QR detection, full control |
| **Persistence** | SwiftData (iOS 17+) | Zero-config, type-safe, SwiftUI-native |
| **Concurrency** | Swift Concurrency (async/await, actors) | Modern, safe, efficient |

### **Why No Third-Party Libraries?**

- **Demonstrates Swift proficiency**: Shows deep understanding of native frameworks
- **Zero dependencies**: No version conflicts, smaller binary size
- **Production-ready**: Native solutions are battle-tested and maintained by Apple
- **Interview readiness**: Can discuss implementation details without library abstraction

**Alternative considered:**
- **Alamofire** → Rejected: URLSession with async/await is equally clean
- **Core Data** → Rejected: SwiftData is more modern and has less boilerplate
- **Realm** → Rejected: Adds unnecessary complexity for this use case

---

## 🔌 API Integration

### **Chosen API: Open Food Facts**

**Endpoint:** `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`

**Why this API?**
✅ Free, no API key required  
✅ Returns structured product data (name, brand, category)  
✅ Supports barcode lookups (most QR codes encode barcodes)  
✅ High uptime and reliability  

**Sample Request:**
```
GET https://world.openfoodfacts.org/api/v0/product/737628064502.json
```

**Sample Response:**
```json
{
  "status": 1,
  "product": {
    "product_name": "Coca Cola",
    "brands": "Coca-Cola",
    "categories": "Beverages"
  }
}
```

**Error Handling:**
- Network failures → User-friendly error message
- Invalid QR codes → "Product not found" status
- Timeout (15s) → Network error with retry suggestion

---

## 💾 Data Persistence

### **SwiftData Implementation**

**Model:**
```swift
@Model
final class ScanRecord {
    var id: UUID
    var productName: String
    var brand: String
    var category: String
    var statusRaw: String
    var scannedAt: Date
    var qrValue: String
}
```

**Features:**
- ✅ **Offline-first**: All scans saved locally, no internet required
- ✅ **CRUD operations**: Create, Read, Delete with Repository pattern
- ✅ **Search**: Client-side filtering by product name/brand
- ✅ **Sorting**: Newest scans first
- ✅ **Thread-safe**: `@MainActor` annotations on Repository

**Repository Pattern Benefits:**
- Abstracts SwiftData implementation details
- Easy to swap persistence layer (e.g., move to Core Data)
- Simplifies testing with mock repositories

---

## 📸 Camera & QR Scanning

### **AVFoundation Implementation**

**CameraService Responsibilities:**
1. Permission handling (authorized/denied/notDetermined)
2. AVCaptureSession setup with QR metadata detection
3. Session lifecycle (start/stop)

**Key Features:**
- ✅ Permission prompt with "Open Settings" fallback
- ✅ Live camera preview with scanning overlay
- ✅ Haptic feedback on successful scan
- ✅ Duplicate scan prevention (2-second debounce)
- ✅ Thread-safe with `@MainActor`

**Permission Flow:**
```
App Launch → Check Permission → If Denied: Show "Open Settings"
                              → If Not Determined: Request Access
                              → If Authorized: Setup Camera
```

---

## 🎨 UI/UX Highlights

### **Accessibility**
- ✅ VoiceOver labels for all interactive elements
- ✅ Dynamic Type support (system font scaling)
- ✅ High contrast color scheme (green = genuine, red = unverified)
- ✅ Clear error messaging

### **User Experience**
- ✅ Loading states during API calls
- ✅ Empty states for history (with search/filter variations)
- ✅ Swipe-to-delete on history items
- ✅ Pull-to-refresh implicit with data binding
- ✅ Real-time search with instant filtering

### **Design Patterns**
- Material backgrounds for modals
- SF Symbols for consistency
- Native iOS components (List, Picker, SearchField)
- Tab-based navigation for primary flows

---

## ✅ Requirements Checklist

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| QR Code Scanning | ✅ | AVFoundation with live preview |
| Camera Permission | ✅ | Permission handling + Settings link |
| Product Verification | ✅ | Open Food Facts API with async/await |
| Visual Status Indicator | ✅ | Green (genuine) / Red (unverified) badges |
| Error Handling | ✅ | Network, invalid QR, empty response |
| Offline Scan History | ✅ | SwiftData with full CRUD |
| Search by Product Name | ✅ | Real-time client-side filtering |
| Filter by Status | ✅ | Segmented picker (All/Genuine/Unverified) |
| Delete Individual Scans | ✅ | Swipe-to-delete gesture |
| Clean Architecture | ✅ | MVVM + Repository pattern |
| Code Quality | ✅ | Consistent naming, no dead code |
| README | ✅ | This document |

---

## ⚠️ Known Limitations

### **1. API Dependency**
- **Issue**: Relies on Open Food Facts availability
- **Impact**: Product verification fails if API is down
- **Mitigation**: Clear error messages, cached results in history

### **2. Barcode-Specific**
- **Issue**: Open Food Facts primarily supports product barcodes
- **Impact**: Generic QR codes (URLs, text) won't verify
- **Future**: Add support for multiple QR types (URL, vCard, etc.)

### **3. No Image Caching**
- **Issue**: Product images not saved with history
- **Impact**: Offline history has no visual product representation
- **Future**: Add Kingfisher or SDWebImage for image caching

### **4. Client-Side Search**
- **Issue**: Search happens in-memory, not indexed
- **Impact**: Slower with 1000+ scans
- **Future**: Implement SwiftData predicates for optimized queries

### **5. No Background Scanning**
- **Issue**: Camera stops when app is backgrounded
- **Impact**: Users must keep app in foreground to scan
- **Future**: Add widget for quick scan access

---

## 🚀 Future Improvements

### **If I had more time (priority order):**

#### **1. Unit Tests (2-3 hours)**
```swift
// Example test cases:
- ScannerViewModelTests
  - testSuccessfulProductVerification()
  - testNetworkErrorHandling()
  - testDuplicateScanPrevention()

- HistoryViewModelTests
  - testSearchFunctionality()
  - testStatusFiltering()
  - testDeleteScan()

- APIServiceTests (with URLProtocol mocking)
  - testValidBarcodeResponse()
  - testInvalidBarcode404()
  - testNetworkTimeout()
```

#### **2. Advanced Features (4-5 hours)**
- **Batch scanning**: Scan multiple QR codes in sequence
- **Export history**: CSV/PDF export functionality
- **QR code generation**: Create QR codes for verified products
- **Dark mode optimization**: Ensure perfect contrast in all modes
- **iPad support**: Multi-column layout for scan history

#### **3. Performance Optimizations (2 hours)**
- **SwiftData indexing**: Add `@Attribute(.unique)` for faster queries
- **Image caching**: Integrate SDWebImage for product photos
- **Pagination**: Load history in chunks (50 items at a time)
- **Memory profiling**: Instruments analysis for leak detection

#### **4. Error Recovery (2 hours)**
- **Retry logic**: Exponential backoff for network failures
- **Offline queue**: Save scans when offline, sync when online
- **Error analytics**: Crash reporting with OSLog

#### **5. CI/CD Pipeline (3 hours)**
- **GitHub Actions**: Automated testing on every PR
- **Fastlane**: Automated App Store builds
- **SwiftLint**: Enforce code style consistency

---

## 📋 Testing Instructions

### **How to Test QR Scanning (Open Food Facts)**

This app uses the **Open Food Facts** public API. To test scanning, you need to generate a QR code
from a valid product barcode and scan it with the app.

**Step 1 — Pick a barcode from the list below**

✅ **Valid Products (confirmed working):**

| Barcode | Product |
|---------|---------|
| `3017620422003` | Nutella |
| `8901030868757` | Parle-G Biscuits |
| `8901058851427` | Maggi Noodles |
| `8901719110498` | Amul Butter |
| `0049000028911` | Coca-Cola |
| `4006381333931` | Kinder Bueno |

❌ **Invalid (for testing error handling):**

| Barcode | Expected Result |
|---------|-----------------|
| `000000000000` | "Product not found" |
| `INVALID_QR` | Invalid format error |

**Step 2 — Generate a QR code**

Go to [qr-code-generator.com](https://www.qr-code-generator.com/), paste the barcode number
(e.g. `3017620422003`), and generate the QR code.

**Step 3 — Scan with the app**

Open the app on a physical device, point the camera at the generated QR code, and the product
details will load automatically.

> ⚠️ **Note:** Open Food Facts works with product barcodes, not arbitrary text QR codes.
> Generic QR codes (URLs, plain text) will return "Product not found" — this is expected behaviour.

**Verify an API response manually (optional):**

---

## 🔧 Development Setup

### **Requirements**
- Xcode 15.0+
- iOS 17.0+ deployment target
- Swift 5.9+
- Physical device for camera testing

### **No Additional Setup Needed**
- ✅ Zero dependencies (no CocoaPods, SPM, or Carthage)
- ✅ No API keys required (Open Food Facts is public)
- ✅ No Firebase or backend setup
- ✅ Just open `.xcodeproj` and run

---

## 👨‍💻 About This Implementation

**Time Spent:** ~3.5–4 hours 

**Breakdown:**
- Architecture & planning: 30 min
- Models & Services: 1 hour
- Camera integration: 1 hour  
- Views & UI: 1 hours
- Testing & refinement: 30 min
- Documentation: 30 hour

**Approach:**
- Focused on **core functionality first** (scan → verify → save)
- **Clean code** over feature completeness
- **Production-ready patterns** (MVVM, Repository, async/await)
- **No shortcuts** — proper error handling, permissions, edge cases

---

## 📞 Contact

**Hemavathi M**  
📧 hemavathimreddy1@gmail.com  
🐙 https://github.com/hemavathi-ios

---

## 📄 License

This project is submitted as part of Acviss Technologies' hiring process and is confidential.

---
