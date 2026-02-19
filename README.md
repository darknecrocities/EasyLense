![EasyLens Banner](assets/banner.png)

# 🌐 EasyLens — Redefining Vision Through AI & IoT

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Accessibility-First](https://img.shields.io/badge/Accessibility-First-4CAF50?style=for-the-badge)](https://www.w3.org/WAI/standards-guidelines/wcag/)

**EasyLens** is a sophisticated assistive navigation solution designed to provide visually impaired users with real-time, AI-driven environmental awareness. By integrating a mobile application with specialized IoT smart glasses, EasyLens acts as a digital companion, translating the visual world into understandable audio guidance.

---

## 💎 Our Core Values

| 🧗 Independence | 🛡️ Safety | ♿ Accessibility |
| :--- | :--- | :--- |
| Empowering users to navigate unfamiliar environments without constant human assistance. | Prioritizing hazard detection to prevent accidents from stairs, vehicles, and obstacles. | Born from the ground up to follow strict accessibility principles for seamless interaction. |

---

## 🚀 Project Overview

EasyLens bridges the gap between digital intelligence and physical navigation. The system consists of a high-performance Flutter mobile application linked via Bluetooth (BLE) to a pair of IoT smart glasses equipped with cameras and sensors.

### ✨ Key Features
- **🧠 Edge AI Processing:** Local inference for near-zero latency and total data privacy.
- **🗣️ Multilingual Voice:** Real-time translations into **English** and **Filipino**, tailored for local context.
- **📡 BLE Synergy:** Persistent, low-energy connection to smart glasses hardware.
- **🚨 Emergency Guardian:** Rapid-trigger emergency protocol with haptic feedback and contact alerts.
- **🎨 High-Contrast UI:** Glassmorphism-inspired design optimized for low-vision readability.

---

## 🏗️ System Architecture & Implementation

### The Service Layer
EasyLens utilizes a decoupled service-layer architecture to ensure scalability and reliability:

- **AI Inference Engine:** A TFLite-ready pipeline (currently simulated) that classifies objects into danger categories.
- **NLP Audio Formatter:** A localization layer that converts raw detection data into natural, human-like sentences.
- **IoT Connectivity Service:** Manages BLE life cycles, bonding, and data streaming between the app and the glasses.
- **Haptic Feedback Service:** Provides tactile confirmation for all UI interactions, essential for visually impaired users.

---

## 📊 Technical Diagrams

### 🗺️ System Architecture
```mermaid
graph TD
    subgraph "Frontend (Flutter)"
        UI[Glassmorphic UI]
        Providers[Provider State Management]
    end

    subgraph "Core Services"
        AI[AI Detection Service]
        TTS[TTS Audio Service]
        BLE[BLE Connection Service]
        NLP[NLP Translation Service]
    end

    subgraph "External Integration"
        Glasses[IoT Smart Glasses via BLE]
        TFLite[TensorFlow Lite Models]
    end

    UI <--> Providers
    Providers <--> Services
    Services --- AI & TTS & BLE & NLP
    BLE <--> Glasses
    AI <--> TFLite
```

### 🔄 Data Flow Protocol
```mermaid
graph LR
    Environment[Physical Environment] -->|Captured by| Camera[Glass Camera]
    Camera -->|Raw Frame| App[EasyLens App]
    App -->|Input| AI[AI Inference Engine]
    AI -->|Risk Level/Tag| NLP[NLP Formatter]
    NLP -->|Formatted Text| Audio[TTS Service]
    Audio -->|Speech Out| User[User Awareness]
```

### 🔗 Interface Relationship (ERD)
```mermaid
erDiagram
    USER ||--o{ DETECTION : initiates
    USER ||--|| SETTINGS : configures
    DETECTION ||--|| RISK_ASSESSMENT : includes
    IOT_GLASSES ||--o{ DATA_STREAM : generates
    DATA_STREAM ||--|| DETECTION : processed_by
```

---

## 🛠️ Technology Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter / Dart** | Cross-platform mobile foundation |
| **Provider** | Reactive state management |
| **Flutter TTS** | Voice feedback synchronization |
| **Bluetooth LE** | Low-latency hardware communication |
| **TensorFlow Lite** | (Future) On-device machine learning |

---

## 🏁 Roadmap to Production

- [x] **Phase 1: Prototype** — Foundation, UI System, and Simulated Services.
- [ ] **Phase 2: Hardware Sync** — Integration with Physical ESP32/Pi Smart Glasses.
- [ ] **Phase 3: Intelligence** — Implementation of Real-time TFLite detection models.
- [ ] **Phase 4: Global Reach** — Support for more local dialects and improved NLP.

---

## 📖 Usage Guide

1. **Dashboard Home:** Large radar button triggers an environmental scan.
2. **Navigation Hub:** High-contrast buttons for repeatable instructions and emergency alerts.
3. **Settings Console:** Toggle between English/Filipino and manage your Smart Glasses connection.
4. **IoT Interaction:** Watch the Bluetooth status icon; once it glows Green, your glasses are actively feeding data.

---

## 🤝 Contributing & Vision

We are building EasyLens to be the open-standard for assistive vision tech. We welcome contributions from:
- **ML Engineers:** Optimizing TFLite models for urban object detection.
- **IoT Developers:** Enhancing BLE protocols for camera frame streaming.
- **Accessibility Experts:** Refining the UX/UI for diverse visual needs.

**License:** This project is licensed under the [MIT License](LICENSE).

---
*Created with ❤️ for a more accessible world.*
