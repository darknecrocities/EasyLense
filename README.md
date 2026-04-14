![EasyLens Banner](assets/banner.png)

# 🌐 EasyLens — Redefining Vision Through AI & IoT

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Google ML Kit](https://img.shields.io/badge/ML%20Kit-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/ml-kit)
[![Cloudflare R2](https://img.shields.io/badge/Cloudflare%20R2-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://www.cloudflare.com/products/r2/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

**EasyLens** is a sophisticated assistive navigation solution designed to provide visually impaired users with real-time, AI-driven environmental awareness. By integrating a mobile application with specialized IoT smart glasses, EasyLens acts as a digital companion, translating the visual world into understandable audio guidance and high-contrast visual cues.

---

## 💎 Our Core Values

| 🧗 Independence | 🛡️ Safety | ♿ Accessibility |
| :--- | :--- | :--- |
| Empowering users to navigate unfamiliar environments without constant human assistance. | Prioritizing hazard detection to prevent accidents from stairs, vehicles, and obstacles. | Born from the ground up to follow strict accessibility principles (WCAG) for seamless interaction. |

---

## 🚀 Project Overview

EasyLens bridges the gap between digital intelligence and physical navigation. The system consists of a high-performance Flutter mobile application that leverages **Google ML Kit** for on-device vision processing and **Cloudflare R2** for efficient asset hosting, providing a seamless "connected" experience for the visually impaired.

---

## ✨ Key Features

### 👁️ Dual-API Vision System
- **Real-Time Detection:** Native Google ML Kit Object Detection providing tight bounding boxes and persistent tracking IDs.
- **Granular Classification:** Integrated Image Labeling API identifying **400+ specific objects** (e.g., "Laptop", "Chair", "Beverage") instead of generic categories.
- **Compound Labeling:** Intelligently combines base categories with specific semantic names (e.g., "Home Good - Laptop").

### 🗺️ Navigation Hub
- **Smart Search:** Search for destinations with Google Maps integration.
- **Historical Tracking:** Quick access to "Recent Destinations" for repeated routes.
- **Visual Guidance:** High-contrast directions and "Start Navigation" triggers with haptic feedback.

### 👤 Profile & Cloud Sync
- **Identity Management:** Secure Firebase Authentication (Login/Signup/Password Reset).
- **Photo Hosting:** User profile pictures are hosted on **Cloudflare R2** via S3-compatible APIs for high performance and scalability.
- **Preferences:** Personalized setup for "Visual Condition" and "Language" (English/Filipino).

### 📡 IoT Connectivity
- **BLE Synergy:** Reactive Bluetooth Low Energy (BLE) status monitoring for seamless pairing with IoT Smart Glasses.
- **Hazard Alerts:** (Experimental) Special detection tracks for common hazards like stairs and vehicles.

---

## 🏗️ System Architecture

EasyLens utilizes a decoupled service-layer architecture to ensure stability across vision and navigation tasks.

### 🔄 Data Flow Protocol
```mermaid
graph LR
    Environment[Physical Environment] -->|Captured by| Camera[Camera Stream]
    Camera -->|InputImage| MLKit[Google ML Kit Processor]
    MLKit -->|Object Box| HUD[Dynamic Dashboard]
    MLKit -->|Semantic Label| Labels[Compound Label Map]
    Labels -->|Display| UI[High-Contrast Profile]
```

### 🧠 Vision Architecture
EasyLens employs a **Base Object Detector** for performance (tracking boxes every frame) and a **Semantic Image Labeler** for specificity (running every 5th frame), ensuring a fluid UI while maintaining high intelligence.

---

## 🛠️ Technology Stack

| Category | Technology |
| :--- | :--- |
| **Foundation** | [Flutter](https://flutter.dev) / [Dart](https://dart.dev) |
| **Intelligence** | [Google ML Kit](https://developers.google.com/ml-kit) (Object Detection & Image Labeling) |
| **Backend** | [Firebase](https://firebase.google.com) (Auth, Firestore) |
| **Cloud Storage** | [Cloudflare R2](https://www.cloudflare.com/products/r2/) (S3-Compatible Object Storage) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **IoT/Hardware** | [Bluetooth Low Energy (BLE)](https://pub.dev/packages/flutter_blue_plus) |
| **Configuration** | [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv) |

---

## 🏁 Roadmap to Production

- [x] **Phase 1: Foundation** — UI System, Firebase Auth, and Theme Engine.
- [x] **Phase 2: Vision Core** — Google ML Kit Dual-API integration and Compound Labeling.
- [x] **Phase 3: Cloud Sync** — Cloudflare R2 Profile Photo hosting and Firestore Metadata.
- [/] **Phase 4: Navigation** — Full Turn-by-Turn integration and Google Maps Sync.
- [ ] **Phase 5: Hardware Integration** — Direct camera streaming from ESP32-CAM Smart Glasses.

---

## 📖 Usage Guide

1. **Environmental Scan:** Open the Dashboard; ML Kit automatically draws and labels objects in view.
2. **Navigation:** Swipe to the Navigation tab to search for destinations or re-trace recent routes.
3. **Connectivity:** Pair your glasses via the Devices tab; the "Active" badge indicates data flow.
4. **Profile:** Manage your visual condition and profile aesthetics in the Profile View.

---

## 🤝 Contributing

We are building EasyLens to be the open-standard for assistive vision tech.
- **Vision:** Help us expand the `MlKitLabelMap` for better object filtering.
- **UX/UI:** Optimize the high-contrast patterns for specific visual conditions like Glaucoma or Cataracts.

---
*Created with ❤️ for a more accessible world.*

