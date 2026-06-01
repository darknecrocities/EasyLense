# EasyLens - System Architecture Documentation

**Version:** 1.0.0  
**Last Updated:** June 2026  
**Status:** Pre-Hardware Integration (Phase 1-2 Complete)

---

## 1. Executive Summary

### What is EasyLens?

EasyLens is a smart assistive eyewear system that helps visually impaired users understand and navigate their surroundings through real-time AI-powered camera analysis. The system combines an ESP32-CAM wearable device with a Flutter mobile application, connected via local WiFi, to provide object detection, hazard alerting, voice guidance, and turn-by-turn navigation assistance.

### Core Objectives

- Provide real-time audio description of the user's environment
- Detect and alert users to hazards (vehicles, stairs, obstacles, etc.)
- Offer turn-by-turn navigation with voice guidance
- Operate with 100% on-device privacy — no cloud dependency for core features
- Support bilingual interaction (English and Filipino)
- Maintain accessibility-first design (WCAG 2.1 AAA)

### Target Users

- Visually impaired and blind individuals
- Elderly users with age-related vision loss
- Users with conditions such as Macular Degeneration, Glaucoma, Cataracts, Diabetic Retinopathy, and Photophobia

### Major Technologies

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform mobile application framework |
| **Dart** | Primary programming language |
| **Provider** | State management |
| **Firebase Auth + Firestore** | Authentication and user data persistence |
| **Google ML Kit** | On-device object detection and image labeling |
| **TensorFlow Lite (SSD MobileNet)** | Local object detection inference |
| **Google Gemini AI** | Cloud-based scene understanding (optional) |
| **Qwen 0.5B (GGUF)** | On-device local LLM for voice commands |
| **flutter_tts** | Text-to-speech voice feedback |
| **speech_to_text** | Voice command input |
| **OpenStreetMap + OSRM** | Navigation and routing |
| **Flutter Map** | Map rendering |
| **Cloudflare R2 (MinIO)** | Profile image storage (S3-compatible) |
| **ESP32-CAM** | Wearable camera hardware (planned integration) |
| **BLE (Bluetooth Low Energy)** | Device communication (planned) |

### Current Development Status

- **Phase 1 (Static Pages):** Complete — all UI screens built
- **Phase 2 (Navigation System):** Complete — map, search, routing implemented
- **Phase 3 (ESP32 Connectivity):** Planned — UI prepared, BLE service stubbed
- **Phase 4 (Live Streaming):** Partially implemented — phone camera active, ESP32 pending
- **Phase 5 (AI Processing):** Partially implemented — ML Kit + TFLite active, Gemini integrated
- **Phase 6 (Voice Assistance):** Partially implemented — voice commands + local LLM active
- **Phase 7 (Cloud Integration):** Planned — Firebase + R2 active, sync pending

---

## 2. High Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Smart Glasses (ESP32-CAM)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ OV2640 Camera │  │ WiFi Module  │  │ Status LEDs/Haptics│ │
│  └──────┬───────┘  └──────┬───────┘  └───────────────────┘  │
│         │                 │                                  │
└─────────┼─────────────────┼──────────────────────────────────┘
          │                 │  HTTP / WebSocket
          │                 ▼
          │      ┌──────────────────┐
          │      │  WiFi Network    │
          │      │  (Local AP/STA)  │
          │      └────────┬─────────┘
          │               │
┌─────────┼───────────────┼──────────────────────────────────┐
│         │               │                                  │
│         ▼               ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Flutter Mobile Application              │   │
│  │                                                      │   │
│  │  ┌───────────────────────────────────────────────┐  │   │
│  │  │            Presentation Layer                  │  │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐  │  │   │
│  │  │  │ Screens  │ │ Widgets  │ │   Theme      │  │  │   │
│  │  │  └─────┬────┘ └────┬─────┘ └──────────────┘  │  │   │
│  │  └────────┼───────────┼──────────────────────────┘  │   │
│  │           │           │                             │   │
│  │  ┌────────┼───────────┼──────────────────────────┐  │   │
│  │  │        ▼           ▼         Business Logic    │  │   │
│  │  │  ┌──────────┐ ┌──────────┐                    │  │   │
│  │  │  │Providers │ │Controllers│                    │  │   │
│  │  │  └─────┬────┘ └────┬─────┘                    │  │   │
│  │  └────────┼───────────┼──────────────────────────┘  │   │
│  │           │           │                             │   │
│  │  ┌────────┼───────────┼──────────────────────────┐  │   │
│  │  │        ▼           ▼       Service Layer       │  │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐  │  │   │
│  │  │  │ AI/ML    │ │ Network  │ │ Device Comm  │  │  │   │
│  │  │  │ Services │ │ Services │ │ (BLE/WiFi)   │  │  │   │
│  │  │  └────┬─────┘ └────┬─────┘ └──────┬───────┘  │  │   │
│  │  └───────┼────────────┼──────────────┼───────────┘  │   │
│  │          │            │              │              │   │
│  │  ┌───────┼────────────┼──────────────┼───────────┐  │   │
│  │  │       ▼            ▼              ▼   Data Layer│  │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐  │  │   │
│  │  │  │ Models   │ │ Firebase │ │ SharedPrefs  │  │  │   │
│  │  │  └──────────┘ └──────────┘ └──────────────┘  │  │   │
│  │  └───────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Capture:** Smart glasses (ESP32-CAM) or phone camera captures image frames
2. **Transmit:** Frames are sent via local WiFi (ESP32) or direct camera stream (phone)
3. **Detect:** ML Kit Object Detection + TFLite SSD process frames for objects
4. **Classify:** Detected objects are mapped to hazard levels (Safe/Warning/Danger)
5. **Format:** NLP formatter generates natural language alerts in English/Filipino
6. **Respond:** TTS speaks alerts, UI displays detection cards and bounding boxes
7. **Navigate:** Optional OSRM-based turn-by-turn guidance overlays

### Communication Flow

| Path | Protocol | Data |
|---|---|---|
| ESP32 → Flutter App | HTTP/WebSocket over WiFi | JPEG frames, telemetry |
| Flutter App → ESP32 | HTTP POST | Commands (capture, stream, status) |
| Flutter App → Cloudflare R2 | HTTPS (MinIO S3) | Profile images |
| Flutter App → Firebase | HTTPS (gRPC) | Auth, Firestore CRUD |
| Flutter App → Gemini API | HTTPS (REST) | Scene analysis (optional) |
| Flutter App → OSRM API | HTTPS (REST) | Route calculation |
| Flutter App → Photon API | HTTPS (REST) | Geocoding search |

---

## 3. Project Directory Structure

```
easylense_prototype/
│
├── lib/                              # Main application source code
│   ├── main.dart                     # Application entry point
│   │
│   ├── constants/                    # Immutable application constants
│   │   ├── app_constants.dart        # Colors, typography, i18n, mock data
│   │   └── mlkit_label_map.dart      # ML Kit label index-to-name mapping
│   │
│   ├── theme/                        # Theming and styling
│   │   └── app_theme.dart            # Dark mode theme definition
│   │
│   ├── models/                       # Data models
│   │   ├── detected_object.dart      # DetectedObject, RiskLevel enum
│   │   └── destination.dart          # Navigation destination model
│   │
│   ├── providers/                    # State management (ChangeNotifier)
│   │   ├── detection_provider.dart    # Detection scan state & TTS
│   │   ├── gemini_provider.dart       # Gemini AI conversation loop
│   │   ├── navigation_provider.dart   # Navigation, location, search
│   │   └── settings_provider.dart     # Language, BLE, edge mode, TTS toggle
│   │
│   ├── controllers/                  # Input handling controllers
│   │   └── voice_command_controller.dart  # Voice command + local LLM
│   │
│   ├── services/                     # Business logic & external integrations
│   │   ├── ai_detection_service.dart      # Platform-agnostic detection coordinator
│   │   ├── camera_stream_handler.dart     # Camera frame processing pipeline
│   │   ├── tflite_processor.dart          # TFLite SSD interpreter
│   │   ├── tflite_inference_native.dart   # Native ML Kit adapter
│   │   ├── tflite_inference_stub.dart     # Web mock inference
│   │   ├── mlkit_processor.dart           # Google ML Kit object detection + labeling
│   │   ├── gemini_service.dart            # Google Gemini API client
│   │   ├── local_llm_service.dart         # Qwen 0.5B on-device LLM + RAG
│   │   ├── nlp_formatter.dart             # Natural language alert formatting
│   │   ├── hazard_mapper.dart             # Detection-to-hazard mapping
│   │   ├── tts_service.dart               # Text-to-speech (English/Filipino)
│   │   ├── frame_throttler.dart           # Camera frame rate limiter
│   │   ├── isolate_runner.dart            # Background isolate for TFLite
│   │   ├── firebase_service.dart          # Firebase initialization
│   │   ├── cloudflare_service.dart        # Cloudflare R2 image upload
│   │   ├── ble_connection_service.dart    # BLE connection (stubbed)
│   │   ├── spotlight_controller.dart      # Tutorial spotlight positions
│   │   ├── walkthrough_service.dart       # Tutorial completion persistence
│   │   └── tflite_processor.dart          # Low-level TFLite interpreter
│   │
│   ├── screens/                       # Full-page UI screens
│   │   ├── auth/                      # Authentication flow
│   │   │   ├── auth_gateway_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── signup_verify_email_screen.dart
│   │   │   ├── signup_success_screen.dart
│   │   │   ├── signup_error_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── check_email_screen.dart
│   │   │   └── password_reset_success_screen.dart
│   │   │
│   │   ├── onboarding/                # First-time user setup
│   │   │   ├── welcome_screen.dart
│   │   │   ├── introduction_screen.dart
│   │   │   ├── setup_profile_screen.dart
│   │   │   ├── language_screen.dart
│   │   │   ├── birthday_screen.dart
│   │   │   └── visual_condition_screen.dart
│   │   │
│   │   ├── main/                      # Core application screens
│   │   │   ├── home_screen.dart
│   │   │   ├── detection_screen.dart
│   │   │   ├── navigation_assist_screen.dart
│   │   │   ├── accessibility_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── chat_screen.dart
│   │   │
│   │   └── profile/                   # User profile screens
│   │       ├── profile_view_screen.dart
│   │       └── edit_profile_screen.dart
│   │
│   ├── widgets/                       # Reusable UI components
│   │   ├── common/                    # Shared utility widgets
│   │   │   ├── accessible_button.dart
│   │   │   ├── spotlight_target.dart
│   │   │   └── dashboard_walkthrough.dart
│   │   │
│   │   ├── navigation/               # Navigation components
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── custom_nav_bar.dart
│   │   │   ├── floating_menu.dart
│   │   │   └── navigation_view.dart
│   │   │
│   │   ├── dashboard/                # Home dashboard components
│   │   │   ├── scanning_dashboard_view.dart
│   │   │   ├── detection_card.dart
│   │   │   ├── edge_mode_badge.dart
│   │   │   └── camera_preview_widget.dart
│   │   │
│   │   ├── devices/                  # Device pairing & management
│   │   │   ├── devices_view.dart
│   │   │   ├── dashboard_view.dart
│   │   │   ├── pairing_view.dart
│   │   │   ├── results_view.dart
│   │   │   ├── settings_view.dart
│   │   │   └── device_components.dart
│   │   │
│   │   └── map/                      # Map components
│   │       └── map_widgets.dart
│   │
│   └── providers/                    # (additional provider files)
│       └── navigation_provider.dart
│
├── assets/                           # Static resources
│   ├── images/                       # Raster images
│   ├── icons/                        # UI icons (auth, nav, hazards, etc.)
│   ├── fonts/                        # Atkinson Hyperlegible typeface family
│   ├── animation/                    # Lottie/GIF animations
│   ├── models/                       # ML models and config
│   │   ├── mlkit_ssd_mobilenet_v1.tflite
│   │   ├── ssd_mobilenet_v2_quantized.tflite
│   │   ├── mobilenet_v2_ssd_quant_int8.tflite
│   │   ├── labels.txt
│   │   └── hazards_config.json
│   ├── banner.png
│   └── app_icon_logo.png
│
├── docs/                             # Documentation
│   └── (future documentation)
│
├── test/                             # Unit and widget tests
├── android/                          # Android platform project
├── ios/                              # iOS platform project
├── web/                              # Web platform project
├── macos/                            # macOS platform project
├── linux/                            # Linux platform project
├── windows/                          # Windows platform project
│
├── pubspec.yaml                      # Dart dependencies and configuration
├── analysis_options.yaml             # Dart linter rules
├── .env                              # Environment variables (API keys, secrets)
├── .gitignore                        # Git exclusion rules
├── .metadata                         # Flutter project metadata
└── README.md                         # Project overview
```

### Directory Responsibilities

| Directory | Purpose | Owner | Dependencies |
|---|---|---|---|
| `lib/constants/` | Immutable values: colors, fonts, i18n strings, ML label maps | All layers | None |
| `lib/theme/` | Flutter ThemeData configuration | Presentation | AppConstants |
| `lib/models/` | Plain Dart data classes | Data Layer | None |
| `lib/providers/` | ChangeNotifier state managers | Business Logic | Services, Models |
| `lib/controllers/` | Input handling (voice, gesture) | Business Logic | Providers, Services |
| `lib/services/` | External integrations, AI/ML, network | Service Layer | Models, Firebase |
| `lib/screens/` | Full-page widgets, navigation routes | Presentation | Providers, Widgets |
| `lib/widgets/` | Reusable component library | Presentation | Providers, Models |
| `assets/` | Static files (images, fonts, models) | Presentation | Referenced in pubspec.yaml |

---

## 4. File-by-File Documentation

### 4.1 Core Application Files

| File | Purpose | Responsibilities | Dependencies | Notes |
|---|---|---|---|---|
| `main.dart` | Application entry point | Firebase init, Provider setup, auth routing, system UI config | Firebase, Provider, SharedPrefs, all screens | Entry point; `AuthWrapper` handles login state |
| `app_constants.dart` | Centralized constants | Colors, typography, i18n maps, mock data | Flutter Material | Single source of truth for all UI constants |
| `app_theme.dart` | Dark theme configuration | ThemeData with high-contrast, accessibility-optimized styling | AppConstants | WCAG 2.1 AAA compliant design |
| `mlkit_label_map.dart` | ML Kit label index mapping | Maps 400+ ML Kit classification indices to human-readable labels | None | Source: Google ML Kit default model |

### 4.2 Data Models

| File | Purpose | Responsibilities | Dependencies | Notes |
|---|---|---|---|---|
| `detected_object.dart` | Detection result model | `DetectedObject` class, `RiskLevel` enum, distance/color formatting | Flutter Material | Central data type for all detection pipelines |
| `destination.dart` | Navigation destination model | `Destination` class, Firestore serialization, `copyWith` | Cloud Firestore | Supports geocoding results and navigation history |

### 4.3 Providers (State Management)

| File | Purpose | Responsibilities | Dependencies | Notes |
|---|---|---|---|---|
| `detection_provider.dart` | Detection state management | Scan trigger, detection list, TTS control, cumulative metrics | AiDetectionService, TtsService, NlpFormatter, HazardMapper | Core provider for real-time detection |
| `gemini_provider.dart` | Gemini AI conversation loop | Voice activation, camera capture, Gemini API call, TTS response | GeminiService, TtsService, SpeechToText | Speech-to-text + AI analysis loop |
| `navigation_provider.dart` | Navigation state management | Location permissions, geocoding, OSRM routing, history | Firestore, Geolocator, HTTP, FirebaseAuth | Full navigation lifecycle |
| `settings_provider.dart` | App settings management | Language toggle, BLE connection, edge mode, TTS toggle | BleConnectionService | Simple setting toggles |
| `navigation_provider.dart` | Tab navigation state | Tab index tracking (Dashboard, Map, Devices, Chat) | None | Minimal provider for bottom nav |

### 4.4 Controllers

| File | Purpose | Responsibilities | Dependencies | Notes |
|---|---|---|---|---|
| `voice_command_controller.dart` | Voice input and local LLM interaction | Speech-to-text, Qwen 0.5B model download/init, response generation, tab switching | SpeechToText, FlutterTts, LocalLlmService, HTTP | Handles ~397MB model download from Hugging Face |

### 4.5 Services

| File | Purpose | Responsibilities | Dependencies | Notes |
|---|---|---|---|---|
| `ai_detection_service.dart` | Detection coordinator | Platform-aware routing to native or stub TFLite engine | tflite_inference_stub/native | Uses conditional imports for platform separation |
| `tflite_processor.dart` | TFLite SSD interpreter | Model loading, inference, output parsing | tflite_flutter, Flutter Services | Handles MobileNetV2 SSD quantized models |
| `tflite_inference_native.dart` | Native ML Kit adapter | Delegates to MlKitProcessor, maps results to DetectedObject | MlKitProcessor | Android/iOS only |
| `tflite_inference_stub.dart` | Web mock inference | Returns randomized mock detections | None | Used when TFLite native bindings unavailable |
| `mlkit_processor.dart` | Google ML Kit integration | Object detection + image labeling, bounding box normalization, label matching | google_mlkit_object_detection, google_mlkit_image_labeling | Two-stage pipeline: detection first, then semantic labeling |
| `gemini_service.dart` | Gemini AI API client | Image + prompt analysis, retry logic with exponential backoff | google_generative_ai, flutter_dotenv | Uses `gemini-3.1-flash-lite-preview` model |
| `local_llm_service.dart` | On-device Qwen 0.5B LLM | Model init, RAG knowledge base, prompt generation, streaming inference | llama_flutter_android | Singleton with 10-document RAG knowledge base |
| `nlp_formatter.dart` | Natural language alert formatting | Formats detections into spoken alerts in English and Filipino | AppConstants (i18n) | Risk-priority sorted output |
| `hazard_mapper.dart` | Detection-to-hazard mapping | Loads JSON config, maps detections to hazard states | DetectedObject, hazards_config.json | Config-driven hazard classification |
| `tts_service.dart` | Text-to-speech | English (en-US) and Filipino (fil-PH) voice output | flutter_tts | Configurable rate, pitch, volume |
| `camera_stream_handler.dart` | Camera frame pipeline | Processes live frames through ML Kit | MlKitProcessor, Camera | Supports real-time frame-by-frame detection |
| `frame_throttler.dart` | Frame rate limiter | Enforces minimum interval between processed frames | None | Default: ~10 FPS (100ms interval) |
| `isolate_runner.dart` | Background TFLite isolate | Spawns worker isolate, handles YUV→RGB conversion + SSD inference | TfliteProcessor | Critical for maintaining UI performance |
| `firebase_service.dart` | Firebase initialization | Runtime Firebase config from .env, platform-aware options | firebase_core, flutter_dotenv | Called once during app startup |
| `cloudflare_service.dart` | Cloudflare R2 storage | Profile image upload/deletion via S3-compatible MinIO client | minio_new, flutter_dotenv | Presigned URLs with 7-day expiry |
| `ble_connection_service.dart` | BLE connection simulation | Mock connect/disconnect with realistic delays | None | Designed to be replaced with real BLE library |
| `spotlight_controller.dart` | Tutorial spotlight positions | Singleton tracking widget global Rects for walkthrough overlay | Flutter | Decentralized coordinate reporting |
| `walkthrough_service.dart` | Tutorial state persistence | Read/write dashboard tutorial completion flag | SharedPreferences | Uses versioned key `show_dashboard_tutorial_v1` |

### 4.6 Screens

| File | Purpose | Dependencies | Future Enhancements |
|---|---|---|---|
| `welcome_screen.dart` | Splash screen with logo animation | None | Skip/delay configuration |
| `introduction_screen.dart` | 4-page feature introduction | AuthGatewayScreen | Interactive demo videos |
| `auth_gateway_screen.dart` | Login/signup choice | LoginScreen, SignupScreen | Biometric auth option |
| `login_screen.dart` | Email/password login | FirebaseAuth, SharedPreferences | Google/Facebook OAuth |
| `signup_screen.dart` | Multi-field registration | FirebaseAuth, Firestore | OAuth signup |
| `signup_verify_email_screen.dart` | Email verification countdown | FirebaseAuth | Auto-detect verification |
| `signup_success_screen.dart` | Post-verification success | SetupProfileScreen | Analytics event |
| `signup_error_screen.dart` | Verification failure | None | Retry guidance |
| `forgot_password_screen.dart` | Password reset request | FirebaseAuth | SMS reset option |
| `check_email_screen.dart` | Reset link sent confirmation | FirebaseAuth | Deep link handling |
| `password_reset_success_screen.dart` | Reset confirmation | None | Auto-navigate to login |
| `setup_profile_screen.dart` | Profile photo upload | ImagePicker, MinIO, Firestore | Camera roll integration |
| `language_screen.dart` | Language selection | Firestore, Auth | More language support |
| `birthday_screen.dart` | Date of birth picker | Firestore, Auth | Accessibility improvements |
| `visual_condition_screen.dart` | Visual condition selection | Firestore, Auth | Condition-specific settings |
| `accessibility_screen.dart` | Voice/haptic/dark mode toggles | Firestore, Auth | Per-condition presets |
| `home_screen.dart` | Main dashboard with tabs | Camera, Provider, Walkthrough | ESP32 live stream |
| `detection_screen.dart` | Real-time detection UI | DetectionProvider | Full-screen radar view |
| `navigation_assist_screen.dart` | Large accessible action buttons | DetectionProvider | Turn-by-turn voice |
| `settings_screen.dart` | App settings | SettingsProvider | Cloud sync settings |
| `chat_screen.dart` | AI chat interface | VoiceCommandController | Voice + text hybrid |
| `profile_view_screen.dart` | User profile display | Firestore, Auth | QR code sharing |
| `edit_profile_screen.dart` | Profile editing | Firestore, Auth, CloudflareService | Emergency contacts |

### 4.7 Widgets

| File | Purpose | Dependencies | Notes |
|---|---|---|---|
| `custom_app_bar.dart` | Top bar with connection status, battery, menu | Provider, BatteryPlus | Real battery level display |
| `custom_nav_bar.dart` | Bottom navigation (Home, Nav, Devices, Chat) | SpotlightTarget | Animated active state |
| `floating_menu.dart` | Hamburger menu overlay | FirebaseAuth, SharedPreferences | Profile, Alert History, Settings, Logout |
| `navigation_view.dart` | Full navigation experience | NavigationProvider, MapWidgets | Search, routing, active navigation sheet |
| `scanning_dashboard_view.dart` | Main dashboard stream view | DetectionProvider, GeminiProvider, HazardMapper | Camera feed, bounding boxes, stats |
| `detection_card.dart` | Single detection result card | DetectedObject | Risk-colored border and badge |
| `edge_mode_badge.dart` | Pulsing edge mode indicator | None | Glow animation with cyan accent |
| `camera_preview_widget.dart` | Simulated camera preview | None | Scan-line animation, corner brackets |
| `devices_view.dart` | Device management state machine | DashboardView, PairingView, ResultsView, SettingsView | Multi-state screen |
| `dashboard_view.dart` | Device list dashboard | SettingsProvider | Add device + connected device cards |
| `pairing_view.dart` | Search/connect device UI | GIF animations | Tap-to-connect, long-press-to-fail |
| `results_view.dart` | Pairing success/failure | None | Animated result icons |
| `settings_view.dart` | Device detail settings | DeviceComponents | Battery, WiFi, firmware info |
| `device_components.dart` | Reusable device UI | None | ActionButton, InfoRow, StatRow |
| `accessible_button.dart` | Large haptic button | HapticFeedback | 80px height, gradient, shadow |
| `spotlight_target.dart` | Self-reporting position tracker | SpotlightController | Used by tutorial overlay |
| `dashboard_walkthrough.dart` | Spotlight tutorial overlay | SpotlightController, WalkthroughService | 13-step guided tour |
| `map_widgets.dart` | Map abstraction layer | FlutterMap, LatLng | OSM default, Google Maps stub |
| `app_theme.dart` | Dark theme definition | AppConstants | High contrast, accessible |

---

## 5. Flutter Application Architecture

### 5.1 Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Presentation Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │   Screens    │  │   Widgets    │  │   Theme/Constants  │  │
│  │ (Pages)      │  │ (Components) │  │ (Design Tokens)   │  │
│  └──────┬───────┘  └──────┬───────┘  └───────────────────┘  │
└─────────┼──────────────────┼──────────────────────────────────┘
          │   InheritedWidget / Provider                         │
          ▼                  │
┌─────────────────────────────────────────────────────────────┐
│                  Business Logic Layer                         │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │  Providers   │  │ Controllers  │                         │
│  │ (State Mgmt) │  │ (Input/CMD)  │                         │
│  └──────┬───────┘  └──────┬───────┘                         │
└─────────┼──────────────────┼──────────────────────────────────┘
          │                  │                                   │
          ▼                  ▼
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   Service Layer                          │ │
│  │  ┌──────────┐┌──────────┐┌──────────┐┌──────────────┐  │ │
│  │  │ AI/ML    ││ Network  ││ Device   ││ Utility      │  │ │
│  │  │ Services ││ Services ││ Comm     ││ Services     │  │ │
│  │  └────┬─────┘└────┬─────┘└────┬─────┘└──────┬───────┘  │ │
│  └───────┼───────────┼───────────┼──────────────┼──────────┘ │
└──────────┼───────────┼───────────┼──────────────┼────────────┘
           │           │           │              │
┌──────────┼───────────┼───────────┼──────────────┼────────────┐
│          ▼           ▼           ▼              ▼            │
│                    Data Layer                                 │
│  ┌──────────┐┌──────────┐┌──────────┐┌──────────────────┐   │
│  │ Models   ││ Firebase ││ Shared   ││ Device Storage   │   │
│  │ (Data)   ││ (Cloud)  ││ Prefs    ││ (Files/Models)   │   │
│  └──────────┘└──────────┘└──────────┘└──────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 5.2 State Management

**Pattern:** Provider (ChangeNotifier)

```
MultiProvider (main.dart)
├── ChangeNotifierProvider<DetectionProvider>
├── ChangeNotifierProvider<GeminiProvider>
├── ChangeNotifierProvider<SettingsProvider>
├── ChangeNotifierProvider<NavigationProvider>
└── ChangeNotifierProvider<VoiceCommandController>
```

**Consumption pattern:** Widgets use `context.watch<T>()` for reactive rebuilds and `context.read<T>()` for event-driven calls.

### 5.3 Navigation

- **Pre-auth:** Imperative Navigator.push/pushReplacement between onboarding and auth screens
- **Post-auth:** Tab-based navigation via `CustomNavBar` + `NavigationProvider.currentTabIndex`
- **Routing:** No named routes — all navigation uses direct `MaterialPageRoute` construction
- **Deep linking:** Not yet implemented (planned for cloud integration)

### 5.4 Dependency Flow

```
Screens ──→ Providers ──→ Services ──→ External APIs
   │            │              │
   │            ▼              │
   └────── Widgets ←───────────┘
```

- Screens never directly instantiate services
- Providers mediate between UI and services
- Services are stateless or singleton
- Models are passed as immutable data objects

### 5.5 Error Handling

| Layer | Strategy |
|---|---|
| Presentation | SnackBars, dialog modals, error screens |
| Business Logic | Try/catch with state flags (`_isLoading`, `_errorMessage`) |
| Service | Exception propagation with contextual messages |
| Network | Retry logic (Gemini: exponential backoff), timeout handling |

---

## 6. ESP32-CAM Architecture (Planned Integration)

### 6.1 ESP32 Responsibilities

| Responsibility | Description |
|---|---|
| Camera Initialization | OV2640 sensor setup, resolution config, JPEG compression |
| WiFi Setup | Create access point or connect to local network |
| Local Streaming | HTTP/MJPEG stream server for live frames |
| Image Capture | High-resolution still capture on demand |
| Status Monitoring | Battery level, connection quality, thermal status |

### 6.2 Planned ESP32-CAM Firmware Structure

| File | Purpose | Functions |
|---|---|---|
| `camera_server.cpp` | HTTP server for image streaming | `initCamera()`, `startStream()`, `captureStill()`, `handleClient()` |
| `wifi_manager.cpp` | WiFi connectivity management | `initWiFiAP()`, `initWiFiSTA()`, `scanNetworks()`, `getSignalStrength()` |
| `main.ino` | Entry point and loop | `setup()`, `loop()`, `handleCommands()` |

### 6.3 Inputs/Outputs Per Module

| Module | Inputs | Outputs |
|---|---|---|
| camera_server.cpp | Capture commands (HTTP GET) | JPEG frames, stream chunks |
| wifi_manager.cpp | SSID/password config | Connection status, IP address |
| main.ino | Sensor data, commands | Status telemetry, frames |

---

## 7. WiFi Connectivity Architecture

### 7.1 Current Phase (Static UI Foundation)

The application currently provides a complete UI/UX foundation **before** hardware integration. All device-related screens and services are built with mock/stub implementations.

**Implemented Pages:**
- Home (Dashboard with simulated scanning)
- Navigation (map, search, routing)
- Devices (pairing flow, device settings)
- AI Chat
- Settings (BLE status, connection toggles)
- About, FAQ, Contact, Privacy Policy, Terms of Service

**Purpose:** Deliver a complete, testable user experience that demonstrates the full workflow without requiring physical hardware.

### 7.2 Integration Phase (Future ESP32-CAM Connectivity)

#### Connection Workflow

```
1. User powers on EasyLens Smart Glasses
2. ESP32-CAM creates WiFi access point (or joins existing network)
3. Flutter app scans for available EasyLens devices
4. User selects detected EasyLens device from list
5. Device connection established via local WiFi
6. Camera stream appears in dashboard
7. Frames are processed through ML Kit/TFLite pipeline
8. Detection results displayed with audio feedback
```

#### Future Service Implementations

| Service | Responsibility |
|---|---|
| `wifi_service.dart` | WiFi network scanning, connection management, ESP32 discovery via mDNS/Bonjour |
| `device_discovery_service.dart` | Broadcast listener for ESP32 presence announcements, device info retrieval |
| `esp32_connection_service.dart` | HTTP client for ESP32 endpoints, stream subscription management, command dispatch |

### 7.3 Data Exchange Protocol (Planned)

| Direction | Endpoint | Method | Data |
|---|---|---|---|
| App → ESP32 | `/capture` | GET | Returns JPEG frame |
| App → ESP32 | `/stream` | GET | MJPEG stream |
| App → ESP32 | `/status` | GET | JSON telemetry (battery, signal, temp) |
| App → ESP32 | `/config` | POST | JSON configuration payloads |
| ESP32 → App | WebSocket | Push | Real-time status updates |

---

## 8. Static Pages Architecture

### 8.1 Page Inventory

| Page | Purpose | UI Components | Navigation Flow | Future Dynamic Features |
|---|---|---|---|---|
| **Home** | Primary dashboard with live detection | Camera preview, bounding boxes, hazard card, stats row, Gemini button, mic FAB | Default tab (index 0) | ESP32 live stream, real radar |
| **Navigation** | Turn-by-turn directions | Map, search bar, destination cards, active navigation sheet, route polyline | Tab index 1 | Voice-guided navigation, offline maps |
| **Devices** | Smart glasses management | Device list, add device, pairing flow, device settings, telemetry | Tab index 2 | Real BLE/WiFi device discovery |
| **AI Chat** | Conversational assistant | Message bubbles, text input, voice input, typing indicator | Tab index 3 | Context-aware camera integration |
| **Settings** | App configuration | Language toggle, BLE connect/disconnect, TTS toggle, edge mode badge | From floating menu | Cloud sync, account management |
| **Profile View** | User profile display | Avatar, name, email, phone, birthday, visual condition, emergency contact | From floating menu | QR code sharing, linked accounts |
| **Edit Profile** | Profile modification | Image picker, form fields, password change, save | From profile view | Emergency contacts management |
| **About** | App information | Version, credits, licenses | Future implementation | Open source links |
| **FAQ** | Frequently asked questions | Expandable Q&A cards | Future implementation | Search, chatbot integration |
| **Contact** | Support contact | Form fields, send button | Future implementation | In-app chat support |
| **Privacy Policy** | Legal document | Scrollable text | From auth gateway | Version tracking |
| **Terms of Service** | Legal document | Scrollable text | From auth gateway | Version tracking |

### 8.2 Static-to-Dynamic Transition Strategy

Each static page is designed with the future integration in mind:

- **Home:** The `ScanningDashboardView` already accepts a `cameraFeed` widget and `cameraController` — when ESP32 streams, these will pass the remote feed instead of the phone camera
- **Devices:** The `BleConnectionService` stub (with simulated delays) will be replaced with a real BLE/WiFi service. The pairing flow UI is already complete
- **Navigation:** Works with real GPS and OSRM today; future ESP32 GPS integration will enhance accuracy
- **Settings:** BLE status read from stub; real connection state will come from live device

---

## 9. Feature Inventory

| Feature | Status | Description | Priority | Dependencies |
|---|---|---|---|---|
| **Authentication** | Complete | Email/password signup, login, password reset, email verification | Critical | Firebase Auth |
| **Onboarding Flow** | Complete | Welcome, introduction, profile setup, language, birthday, visual condition, accessibility settings | Critical | Firebase Auth, Firestore |
| **ESP32 Device Discovery** | Planned | WiFi/BLE scan for EasyLens glasses | High | ESP32 Hardware |
| **WiFi Connection** | Planned | Connect to ESP32 access point | High | ESP32 Hardware |
| **Live Camera Stream** | Partial | Phone camera works; ESP32 stream planned | High | Camera Plugin, ESP32 |
| **Object Detection (ML Kit)** | Complete | Real-time bounding boxes with 400+ labels | Critical | Google ML Kit |
| **Object Detection (TFLite SSD)** | Complete | MobileNetV2 SSD inference in isolate | Medium | TFLite Flutter |
| **Hazard Detection** | Complete | Config-driven hazard state mapping | Critical | ML Kit/TFLite, HazardMapper |
| **Bilingual Voice Feedback** | Complete | English and Filipino TTS | Critical | FlutterTTS |
| **Voice Commands** | Partial | Speech-to-text with local LLM processing | High | SpeechToText, Qwen 0.5B |
| **Gemini AI Assistant** | Complete | Cloud-based scene analysis with conversation loop | Medium | Google Generative AI |
| **Turn-by-Turn Navigation** | Complete | OSRM routing, OSM map, real-time GPS tracking | High | OSRM, Photon, Geolocator |
| **Map Integration** | Complete | OpenStreetMap with FlutterMap | Medium | FlutterMap |
| **Profile Management** | Complete | View/edit profile, photo upload to Cloudflare R2 | Medium | Cloudflare, Firestore |
| **BLE Connection Stub** | Complete | Simulated connect/disconnect with UI | Medium | None (stub) |
| **Dashboard Walkthrough** | Complete | 13-step spotlight tutorial | Low | SpotlightController |
| **Offline Mode** | Planned | Local caching of maps, models, and history | Medium | SharedPreferences, local storage |
| **Cloud Sync** | Planned | Multi-device setting sync via Firestore | Low | Firestore |
| **Emergency Alert** | Complete | Full-screen emergency overlay with TTS | High | HapticFeedback, TTS |
| **On-Device LLM (Qwen)** | Complete | 0.5B parameter model with RAG knowledge base | Medium | llama_flutter_android |

---

## 10. Data Flow Architecture

### 10.1 Detection Pipeline

```
User opens app → HomeScreen loads
    │
    ├── Permission check (camera)
    │   └── If denied → Permission denied card
    │
    ├── Camera initialization
    │   ├── Phone camera → CameraController
    │   └── Future: ESP32 camera → WiFi stream
    │
    ├── Image stream started in ScanningDashboardView
    │   ├── Phone: cameraController.startImageStream()
    │   └── Future: ESP32: HTTP GET /stream
    │
    ├── Frame received
    │   ├── FrameThrottler checks interval (≥100ms)
    │   ├── If passed → DetectionProvider.scanEnvironment()
    │   └── If dropped → Wait for next frame
    │
    ├── AiDetectionService.detect()
    │   ├── [Native] TfliteInferenceService → MlKitProcessor
    │   │   ├── ObjectDetector → bounding boxes + tracking IDs
    │   │   └── ImageLabeler → semantic labels
    │   └── [Web] TfliteInferenceStub → random mock results
    │
    ├── DetectedObject list returned
    │   ├── NLPFormatter → natural language summary
    │   ├── HazardMapper → hazard state (Path Clear / Vehicle / STOP! / etc.)
    │   └── UI update → bounding boxes + detection cards
    │
    └── User feedback
        ├── Visual: Detection cards with risk colors
        ├── Bounding boxes overlaid on camera preview
        ├── Hazard card with icon and description
        └── Audio: TTS (disabled by default to reduce lag)
```

### 10.2 Gemini AI Conversation Flow

```
User taps "Enable Gemini" button
    │
    ├── TTS: "Gemini is active. What would you like to know?"
    ├── 3-second delay (for TTS to finish)
    ├── Speech-to-text activated
    │
    ├── User speaks query
    ├── Speech recognized → text captured
    │
    ├── Camera takes picture
    ├── Image bytes + text sent to Gemini API
    │   └── Retry up to 3 times with exponential backoff (1s, 2s, 4s)
    │
    ├── Response received
    ├── TTS speaks the answer
    ├── Wait ~length-based delay
    │
    └── Loop back to listening
```

### 10.3 Voice Command Flow

```
User presses mic FAB → VoiceCommandController.toggleListening()
    │
    ├── Speech-to-text activates
    ├── User speaks command
    ├── Speech stops → text captured
    │
    ├── Vision context gathered from DetectionProvider
    │   └── "I can see: stairs, vehicle, person"
    │
    ├── Local LLM (Qwen 0.5B) generates response
    │   ├── RAG retrieval: 3 most relevant knowledge base documents
    │   ├── System prompt + context + user message
    │   └── Streaming inference with safety stops
    │
    ├── Response parsed for intent
    │   ├── "navigate" intent → switch to Navigation tab
    │   ├── "home" intent → switch to Dashboard tab
    │   ├── "device" intent → switch to Devices tab
    │   └── General response → TTS speaks answer
    │
    └── Processing state cleared
```

### 10.4 Navigation Flow

```
User opens Navigation tab
    │
    ├── Permission check (location)
    │   ├── If denied → Enable Location prompt
    │   └── If granted → GPS tracking starts
    │
    ├── Dashboard view
    │   ├── "Where do you want to go?" search prompt
    │   └── Recent destinations from Firestore
    │
    ├── User taps search → Search view
    │   ├── Photon API geocoding (fuzzy matching)
    │   ├── Search results displayed
    │   └── User selects destination
    │
    ├── Confirm destination → Map preview shown
    ├── User confirms → NavigationProvider.startNavigation()
    │
    ├── OSRM route calculation
    │   ├── HTTP GET to router.project-osrm.org
    │   ├── Route geometry (GeoJSON) parsed
    │   └── Navigation steps extracted
    │
    ├── Active navigation
    │   ├── Full map with polyline and markers
    │   ├── Draggable sheet with stats (distance, ETA, next turn)
    │   └── Real-time GPS position tracking (5m filter)
    │
    └── User cancels or arrives → stopNavigation()
```

---

## 11. Security Architecture

### 11.1 Current Security Posture

| Domain | Implementation | Status |
|---|---|---|
| **Authentication** | Firebase Auth with email/password | Active |
| **Data in Transit** | HTTPS for all external API calls | Active |
| **API Keys** | Stored in `.env`, loaded at runtime | Active |
| **User Data** | Firestore with security rules | Active |
| **Image Storage** | Cloudflare R2 with presigned URLs (7-day expiry) | Active |
| **On-Device AI** | All ML processing local; no data leaves device | Active (by design) |
| **WiFi Communication** | Not yet implemented | Planned |

### 11.2 Future Security Measures

| Feature | Description | Phase |
|---|---|---|
| **WiFi Encryption** | WPA2/WPA3 for ESP32 access point | Phase 3 |
| **Device Authentication** | MAC-based or token-based pairing | Phase 3 |
| **End-to-End Encryption** | Encrypted frame transmission between ESP32 and app | Phase 4 |
| **Cloud Data Encryption** | AES-256 at rest for cloud-stored data | Phase 7 |
| **Firebase Security Rules** | Granular per-user read/write rules | Current |
| **Certificate Pinning** | Prevent MITM on API calls | Phase 5 |
| **Biometric Auth** | Fingerprint/Face ID for app unlock | Phase 6 |

---

## 12. Development Roadmap

### Phase 1: Static Pages ✅ (Complete)

**Goals:** Build complete UI/UX foundation before hardware integration.

**Deliverables:**
- Splash screen with animation sequence
- 4-page introduction carousel
- Auth gateway (signup/login choice)
- Full signup flow with validation and email verification
- Login with "Stay logged in" option
- Password reset with countdown timer
- Onboarding: profile photo upload, language selection, birthday picker, visual condition, accessibility toggles
- Home dashboard shell
- Navigation view shell
- Devices management shell
- AI Chat interface shell

### Phase 2: Navigation System ✅ (Complete)

**Goals:** Implement working navigation with real GPS and routing.

**Deliverables:**
- GPS permission handling
- Photon API geocoding search
- OSRM route calculation
- Active navigation with draggable sheet
- Route polyline rendering on OSM map
- Real-time position tracking
- Navigation history (Firestore)
- Destination cards with distance/ETA

### Phase 3: ESP32 WiFi Connectivity ⬜ (Planned)

**Goals:** Establish local WiFi communication between ESP32-CAM and Flutter app.

**Deliverables:**
- WiFi service implementation
- Device discovery (mDNS/SSDP)
- ESP32 connection management
- Pairing UI integration with real services
- Connection status telemetry display
- Error handling for connection failures

### Phase 4: Live Camera Streaming ⬜ (Planned)

**Goals:** Stream ESP32 camera feed to Flutter app in real time.

**Deliverables:**
- MJPEG stream decoder
- Replace phone camera with ESP32 stream in dashboard
- Frame throttling for network efficiency
- Stream quality adaptation
- Latency optimization

### Phase 5: AI Processing 🔄 (In Progress)

**Goals:** Complete on-device AI pipeline for real-time detection.

**Deliverables (Complete):**
- Google ML Kit object detection + image labeling
- TFLite SSD MobileNet inference in background isolate
- Hazard mapping with config-driven states
- Bilingual NLP formatter
- Frame throttler for performance

**Deliverables (Remaining):**
- Performance benchmarking and optimization
- Model quantization tuning for edge devices
- Haptic feedback integration for hazard alerts

### Phase 6: Voice Assistance 🔄 (In Progress)

**Goals:** Full voice-controlled interaction with local AI.

**Deliverables (Complete):**
- Speech-to-text integration
- Qwen 0.5B local LLM with RAG knowledge base
- Voice command intent parsing
- TTS with English and Filipino support

**Deliverables (Remaining):**
- Wake word detection ("Hey EasyLens")
- Continuous listening mode
- Voice navigation commands
- Braille keyboard support

### Phase 7: Cloud Integration ⬜ (Planned)

**Goals:** Add cloud sync, analytics, and remote diagnostics.

**Deliverables:**
- Multi-device settings sync via Firestore
- Usage analytics dashboard
- Remote firmware updates (OTA)
- User accounts and profile management
- Emergency contact integration
- SOS alert broadcasting

---

## 13. Future Scalability Plan

### 13.1 Multiple EasyLens Devices

- Device registry in Firestore (per user)
- Simultaneous connection to multiple ESP32 units
- Device prioritization and seamless handoff
- Centralized device management UI

### 13.2 Cloud Backend

- RESTful API server (Node.js/Firebase Functions)
- Image logging and review (opt-in)
- Model update distribution
- User feedback collection

### 13.3 Firebase Integration

| Service | Current Use | Future Use |
|---|---|---|
| **Firebase Auth** | Email/password | OAuth (Google, Facebook), phone auth |
| **Cloud Firestore** | User profiles, navigation history | Device registry, settings sync, analytics |
| **Firebase Storage** | None | User-uploaded images, logs |
| **Firebase Cloud Messaging** | None | Emergency alerts, OTA notifications |
| **Firebase Functions** | None | Server-side processing, webhooks |
| **Firebase Analytics** | None | Usage metrics, crash reporting |

### 13.4 AI Model Upgrades

- Over-the-air model updates via Firebase ML
- User-specific model fine-tuning
- A/B testing for model versions
- Edge compute optimization using NNAPI/Vulkan

### 13.5 OTA Firmware Updates

- ESP32 OTA via Arduino OTA library
- Version management in Firestore
- Rollback capability
- Staged rollout with analytics

### 13.6 User Accounts

- Rich profile with preferences
- Emergency contacts management
- Accessibility profile sharing across devices
- Usage history and insights

### 13.7 Remote Diagnostics

- Device health monitoring dashboard
- Crash report aggregation
- Network quality metrics
- Battery usage analytics

### 13.8 Analytics Dashboard

- Real-time active users
- Detection accuracy metrics
- Feature usage heatmaps
- Performance benchmarks (FPS, latency)

---

## 14. Technical Decisions

### 14.1 Flutter

| Aspect | Decision |
|---|---|
| **Why Flutter?** | Single codebase for Android, iOS, Web, macOS, Linux, Windows |
| **Advantages** | Hot reload, rich widget library, strong typing, large ecosystem |
| **Tradeoffs** | Larger binary size, platform-specific plugins sometimes unstable, Web lacks full native capabilities |
| **State Management** | Provider (simple, well-documented, sufficient for current complexity) |
| **Future Consideration** | Riverpod or Bloc if complexity grows significantly |

### 14.2 ESP32-CAM

| Aspect | Decision |
|---|---|
| **Why ESP32-CAM?** | Low cost (~$10), built-in camera + WiFi + BLE, large community |
| **Advantages** | OV2640 camera with JPEG compression, dual-core processor, low power |
| **Tradeoffs** | Limited RAM (520KB), no hardware FPU, constrained processing for on-device AI |
| **Role** | Image capture + transmission only; all AI processing on phone |

### 14.3 WiFi Connectivity

| Aspect | Decision |
|---|---|
| **Why WiFi?** | Higher bandwidth than BLE for video streaming, lower latency |
| **Advantages** | Can stream MJPEG at 30fps, HTTP protocol simplicity |
| **Tradeoffs** | Higher power consumption than BLE, requires network setup |
| **Future Enhancement** | BLE for control commands, WiFi for video stream |

### 14.4 Local Processing

| Aspect | Decision |
|---|---|
| **Why Local?** | Privacy (no visual data leaves device), offline capability, zero latency |
| **Advantages** | 100% private, works without internet, instant feedback |
| **Tradeoffs** | Limited model complexity, phone battery drain, storage for models |
| **Hybrid Approach** | Local ML Kit/TFLite for real-time detection; optional Gemini for complex queries |

### 14.5 Modular Architecture

| Aspect | Decision |
|---|---|
| **Why Modular?** | Clear separation of concerns, testability, parallel development |
| **Advantages** | Each layer independently testable, easy to swap implementations |
| **Tradeoffs** | More boilerplate, more files, indirection |
| **Key Pattern** | Conditional imports for platform-specific code (tflite_inference_stub vs native) |

---

## 15. Contributor Guide

### 15.1 Adding New Pages

1. Create file in `lib/screens/<category>/` (auth/, onboarding/, main/, profile/)
2. Extend `StatefulWidget` or `StatelessWidget`
3. Use `context.watch<T>()` for reactive state, `context.read<T>()` for events
4. Register in navigation (push route or add to tab index)
5. Add any required assets to `pubspec.yaml`

**Naming Convention:** `snake_case_screen.dart`, class name `SnakeCaseScreen`

### 15.2 Adding New Services

1. Create file in `lib/services/`
2. Class name: `PascalCaseService`
3. Methods should return `Future<T>` for async operations
4. Initialize in the appropriate provider's `init()` method
5. Add `.env` keys to `firebase_service.dart` if needed

**Patterns:**
- Stateless utilities: static methods
- Stateful connections: instance methods, `init()` / `dispose()` lifecycle
- Platform-specific: conditional imports with stub + native implementations

### 15.3 Adding ESP32 Modules (Future)

1. Create module in `ESP32/` directory (root of project)
2. Follow existing module structure: `*_manager.cpp` + `*_manager.h`
3. Register endpoints in `main.ino`
4. Document protocol in this architecture doc

### 15.4 Naming Conventions

| Artifact | Convention | Example |
|---|---|---|
| Files | `snake_case` | `detection_provider.dart` |
| Classes | `PascalCase` | `DetectionProvider` |
| Methods/Functions | `camelCase` | `scanEnvironment()` |
| Constants | `camelCase` | `fontSizeTitle` |
| Enums | `PascalCase` | `RiskLevel` |
| Enum values | `camelCase` | `RiskLevel.safe` |
| Private members | `_camelCase` | `_isScanning` |
| Assets | `snake_case` | `easylens_logo.png` |

### 15.5 Folder Standards

- **One class per file** (except tightly coupled helpers)
- **Maximum ~400 lines per file** (refactor into services if exceeded)
- **Screens folder** mirrors navigation hierarchy
- **Widgets folder** mirrors component categories (common, navigation, dashboard, devices)
- **Services** are stateless or singleton — no widgets in services

### 15.6 Documentation Standards

- Every public class and method should have a doc comment (`///`)
- Complex logic requires inline explanation
- Architecture changes must update this document
- Mark experimental features with `@experimental` or `// Future:`

### 15.7 Testing Guidelines

- Unit tests for services and models: `test/services/*_test.dart`
- Widget tests for reusable components: `test/widgets/*_test.dart`
- Integration tests for full flows: `test/integration/`
- Mock external dependencies (Firebase, APIs) using `mockito`

---

## 16. Conclusion

### Current State

EasyLens has successfully completed its static UI foundation (Phase 1-2) with a fully functional navigation system and an extensive set of accessibility-first screens. The AI processing pipeline (Phase 5) is partially operational on-device using ML Kit and TensorFlow Lite, with optional cloud augmentation via Google Gemini. Voice assistance (Phase 6) is functional with a local Qwen 0.5B LLM and keyword-based RAG knowledge base.

### Architecture Philosophy

- **Privacy by design:** All core perception happens on-device. No visual data ever leaves the device unless the user explicitly opts into cloud features.
- **Accessibility first:** Every UI component is built for WCAG 2.1 AAA compliance — large touch targets, high contrast, screen reader support, haptic feedback.
- **Hardware-ready:** All device communication layers are stubbed but fully UI-integrated, enabling rapid ESP32-CAM integration when hardware is available.
- **Platform adaptable:** Conditional imports allow graceful degradation on unsupported platforms (Web TFLite stub, phone camera fallback).

### Future WiFi Integration Strategy

1. Complete device discovery UI (already built in Devices tab)
2. Implement WiFi service for ESP32 scanning and connection
3. Replace phone camera source with ESP32 stream
4. Add stream health monitoring and reconnection logic
5. Optimize for low-latency real-time interaction

### Long-Term Project Vision

EasyLens aims to become a comprehensive assistive platform that:
- Runs on affordable, accessible hardware
- Works completely offline for core functionality
- Adapts to individual user needs through AI
- Connects users with their community through optional cloud features
- Remains open and extensible for third-party developers

---

*This document is maintained as the single source of truth for EasyLens architecture. All contributors should update it when making significant structural changes.*
