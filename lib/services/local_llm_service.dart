import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class RagDocument {
  final String title;
  final String content;
  final List<String> keywords;

  const RagDocument({
    required this.title,
    required this.content,
    required this.keywords,
  });
}

/// Service responsible for managing and executing the local LLM via llama_flutter_android with On-Device RAG.
class LocalLlmService {
  static final LocalLlmService _instance = LocalLlmService._internal();
  factory LocalLlmService() => _instance;
  LocalLlmService._internal();

  bool _isInitialized = false;
  final LlamaController _controller = LlamaController();
  
  bool get isInitialized => _isInitialized;

  /// Knowledge Base for On-Device Retrieval-Augmented Generation (RAG)
  static const List<RagDocument> _knowledgeBase = [
    RagDocument(
      title: "Platform Overview & Mission",
      content: "EasyLens is an assistive vision platform dedicated to bridging the gap between the sighted world and users with visual impairments. Our mission is to provide real-time, high-fidelity audio and haptic descriptions of the environment, supporting independence, safety, dignity, and autonomy in daily activities.",
      keywords: ["mission", "vision", "overview", "platform", "easylens", "purpose", "who are you", "what is easylens"],
    ),
    RagDocument(
      title: "AI Eyes & Vision System Specs",
      content: "The EasyLens vision system uses MobileNetV2 and SSD (Single Shot MultiBox Detector) integrated natively with Google ML Kit. It processes live camera streams at 30-60 FPS in a background Isolate thread to prevent UI jank. It identifies global scenes (e.g. 'Kitchen') and maps localized bounding box coordinates of surrounding objects.",
      keywords: ["vision", "camera", "eyes", "fps", "mobilenetv2", "ssd", "ml kit", "mlkit", "processing", "detector", "object"],
    ),
    RagDocument(
      title: "Local LLM Brain & Privacy",
      content: "Our local model is Qwen 0.5B (GGUF format), running fully on-device via the llama_flutter_android high-performance C++ backend. It utilizes ARM CPU multi-threading, Vulkan, and NNAPI where available. It operates with 100% data privacy: no visual or personal data ever leaves the local device.",
      keywords: ["brain", "model", "llm", "llama", "local", "privacy", "qwen", "security", "data", "encryption", "on-device"],
    ),
    RagDocument(
      title: "Navigation & Spatial Routing",
      content: "Navigation is powered by OpenStreetMap pedestrian data and the Open Source Routing Machine (OSRM) with contraction hierarchies for sub-millisecond route calculation. Geocoding uses the Photon API with fuzzy matching (e.g. 'Holy Angel Univ'). Logic prioritizes sidewalks over main roads for pedestrian safety.",
      keywords: ["navigation", "route", "map", "osrm", "photon", "gps", "direction", "sidewalk", "destination", "turn"],
    ),
    RagDocument(
      title: "Dashboard Interface (Home Screen)",
      content: "The Dashboard features a custom canvas-based Radar Widget mapping objects from a 120-degree camera field of view to a 360-degree top-down perspective. It provides proximity rings at 1m, 3m, and 5m distances, and an Objects Tab listing recognized items. Tapping an item triggers a pinpoint audio description.",
      keywords: ["dashboard", "home", "radar", "proximity", "rings", "objects tab", "view", "scanner"],
    ),
    RagDocument(
      title: "Smart Glasses Peripheral Sync",
      content: "EasyLens connects to EasyLens Smart Glasses Model V1 via Bluetooth Low Energy (BLE). The glasses mirror their camera feed to the phone for secondary processing. The app tracks telemetry in real-time including signal strength (RSSI), battery percentage, and thermal status.",
      keywords: ["glasses", "smart glasses", "ble", "bluetooth", "pair", "glasses sync", "telemetry", "rssi", "battery"],
    ),
    RagDocument(
      title: "Chat Screen & AI Assistant Screen",
      content: "The Chat & Assistant interface supports manual typing, speech-to-text (STT), and Braille keyboards. It provides a high-contrast AAA accessible UI and answers conversational requests like 'What's in front of me?', 'Describe this object', or 'How far is the door?' using the context from the camera.",
      keywords: ["chat", "chatbot", "assistant", "conversational", "stt", "typing", "braille", "question", "ask"],
    ),
    RagDocument(
      title: "Accessibility Protocols & Haptics",
      content: "EasyLens conforms to WCAG 2.1 AAA accessibility levels (minimum 48x48dp touch targets and screen-reader optimized labels). It uses haptic feedback: Soft Heartbeat means system ready; Sharp Double-Click indicates an obstacle within 1 meter; Rapid Triple-Buzz signals a critical path obstruction.",
      keywords: ["accessibility", "wcag", "contrast", "haptic", "vibration", "buzz", "feedback", "blind", "screen reader"],
    ),
    RagDocument(
      title: "Interaction & Clock Face Description Protocols",
      content: "We use the Clock Face method for spatial directions: 12 o'clock is straight ahead, 3 o'clock is 90 degrees right, 6 o'clock is behind, and 9 o'clock is 90 degrees left. Priority levels: Level 1 (Hazards e.g. stairs, cars, pits - announce instantly), Level 2 (Navigation cues - every 30s), Level 3 (Environment context - only when asked). Responses are kept under 25 words.",
      keywords: ["clock", "o'clock", "direction", "priority", "hazard", "stairs", "car", "distance", "describe"],
    ),
    RagDocument(
      title: "Troubleshooting & Error States",
      content: "1. AI Sight Loss (low confidence): 'I'm having trouble seeing. Ensure the lens is clean and lighting is sufficient.' 2. GPS Drift: 'GPS signal is weak. Try moving away from tall buildings.' 3. Smart Glasses Sync Loss: 'I've lost contact with your glasses. Ensure they are powered on and close.'",
      keywords: ["trouble", "fail", "error", "lost", "weak", "gps", "disconnected", "sight", "troubleshooting", "help"],
    )
  ];

  /// Initialize the model using llama_flutter_android's LlamaController.
  Future<void> initialize(String modelFilePath) async {
    if (_isInitialized) return;

    try {
      if (!File(modelFilePath).existsSync()) {
        throw Exception("Model file missing at $modelFilePath");
      }

      await _controller.loadModel(
        modelPath: modelFilePath,
      );
      
      _isInitialized = true;
      debugPrint("Local Qwen 0.5B (llama_flutter_android) initialized successfully.");
    } catch (e) {
      debugPrint("Error initializing Local Qwen 0.5B on Android: $e");
      rethrow;
    }
  }

  /// Retrieve the most relevant documents for a given query to feed into RAG
  List<RagDocument> retrieveRelevantDocs(String query, {int topK = 3}) {
    final cleanQuery = query.toLowerCase();
    final scoredDocs = _knowledgeBase.map((doc) {
      int score = 0;
      for (final keyword in doc.keywords) {
        if (cleanQuery.contains(keyword)) {
          score += 10; // High score for direct keyword hits
        }
      }
      final queryWords = cleanQuery.split(RegExp(r'\s+'));
      for (final word in queryWords) {
        if (word.length > 3) {
          if (doc.content.toLowerCase().contains(word)) score += 1;
          if (doc.title.toLowerCase().contains(word)) score += 2;
        }
      }
      return MapEntry(doc, score);
    }).toList();

    // Sort by score descending
    scoredDocs.sort((a, b) => b.value.compareTo(a.value));
    
    // Select topK, but ensure we don't return zero-relevance documents if nothing matched (return default docs instead)
    final results = scoredDocs.take(topK).map((entry) => entry.key).toList();
    return results;
  }

  /// Generate a response with app identity and vision awareness, augmented with retrieved RAG context.
  Future<String> generateResponse({
    required String userMessage,
    String visionContext = "",
  }) async {
    if (!_isInitialized) {
      return "EasyLens is still initializing. Please wait a moment.";
    }

    try {
      StringBuffer responseBuffer = StringBuffer();
      
      // Perform on-device RAG retrieval
      final relevantDocs = retrieveRelevantDocs(userMessage, topK: 3);
      
      final String ragContext = relevantDocs.map((doc) {
        return "[DOCUMENT: ${doc.title}]\n${doc.content}";
      }).join("\n\n");

      // Concise core system prompt to set the assistant identity
      const String systemPrompt = 
          "You are the EasyLens Assistant, the primary logic and voice companion for the EasyLens assistive vision ecosystem. "
          "You help blind and visually impaired individuals navigate and understand their surroundings. "
          "Keep answers extremely concise, direct, helpful, and reassuring (target 10-25 words). "
          "Use the 'Clock Face' method for directions (12 o'clock = straight ahead).";

      // Format utilizing standard ChatML structure for Qwen-Instruct
      final fullPrompt = "<|im_start|>system\n$systemPrompt<|im_end|>\n"
                       "<|im_start|>context\n"
                       "--- EASYLENSE KNOWLEDGE BASE (RETRIEVED VIA RAG) ---\n"
                       "$ragContext\n\n"
                       "--- VISION SYSTEM STATUS ---\n"
                       "${visionContext.isNotEmpty ? visionContext : 'No vision context available.'}\n"
                       "<|im_end|>\n"
                       "<|im_start|>user\n$userMessage<|im_end|>\n"
                       "<|im_start|>assistant\n";

      // Run local inference stream
      final stream = _controller.generate(
        prompt: fullPrompt,
        temperature: 0.3, // Lower temp is ideal for factual RAG responses
      );

      await for (final token in stream) {
        responseBuffer.write(token);
        
        // Safety stop triggers
        if (token.contains("<|im_end|>") || token.contains("</s>")) break;
        if (responseBuffer.length > 400) break; 
      }

      return responseBuffer.toString().trim()
          .replaceAll("<|im_end|>", "")
          .replaceAll("</s>", "")
          .trim();
    } catch (e) {
      debugPrint("RAG LLM Generation error: $e");
      return "I'm sorry, I'm having trouble thinking clearly right now.";
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}
