# QR Product Scanner – iOS Assignment

**Hemavathi | April 2026**

---

## 📱 Overview

QR Product Scanner is an iOS application that scans QR codes, verifies products using a public API, and stores scan history locally for offline access.

### Key Features:
- Real-time QR code scanning (AVFoundation)
- Product verification via Open Food Facts API
- Offline scan history using SwiftData
- Search & filter functionality
- Clean architecture (MVVM + Repository)
- Built with SwiftUI (iOS 17+)

---

## 🏗️ Architecture

### MVVM + Repository Pattern

- **Views** → SwiftUI UI layer  
- **ViewModels** → Business logic & state management  
- **Services** → API & Camera handling  
- **Repository** → Data persistence layer  

### Why this approach:
- Separation of concerns  
- Testability  
- Scalability for production apps  

---

## 🛠️ Tech Stack

- **SwiftUI** – UI  
- **AVFoundation** – QR scanning  
- **URLSession + async/await** – Networking  
- **SwiftData** – Local persistence  

> **Note:** No third-party libraries used.

---

## 🔌 API Integration

**Open Food Facts API**  
`https://world.openfoodfacts.org/api/v0/product/{barcode}.json`

- No API key required  
- Returns product details (name, brand, category)  
- Handles invalid and error cases gracefully  

---

## 💾 Persistence

### SwiftData

- Stores scan history locally  
- Supports search, filter, delete  
- Works offline  

---

## 📸 QR Scanning

- Live camera preview  
- Permission handling with fallback  
- Duplicate scan prevention  
- Haptic feedback on scan  

---

## 🎨 UX Highlights

- Loading & error states  
- Search + filter (All / Genuine / Unverified)  
- Swipe-to-delete  
- Basic accessibility support  

---

## ⚠️ Limitations

- Depends on API availability  
- Works mainly with product barcodes  
- No image caching  
- Search is in-memory  

---

## 🚀 Future Improvements

- Unit testing  
- Image caching  
- Pagination for large data  
- Retry logic for network failures  
- CI/CD integration  

---

## 🧪 Testing

Use sample barcodes:

- `3017620422003` – Nutella  
- `8901030868757` – Parle-G  

**Steps:**
1. Generate a QR code using the barcode  
2. Scan using the app  
3. Verify product details  

---

## ⚙️ Setup

- Xcode 15+  
- iOS 17+  
- No dependencies or API keys required  

---

## 👨‍💻 About

- Built in ~3.5–4 hours  
- Focus on clean architecture & core functionality  
- Designed with production practices in mind  

---

## 📄 License

Submitted as part of Acviss Technologies hiring process.
