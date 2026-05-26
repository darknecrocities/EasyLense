import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../providers/navigation_provider.dart';
import '../providers/detection_provider.dart';
import '../models/detected_object.dart';
import '../services/local_llm_service.dart';

class VoiceCommandController extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final LocalLlmService _llmService = LocalLlmService();

  bool _isListening = false;
  String _lastWords = '';
  bool _isInitializing = true;
  bool _isProcessing = false;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Initializing local brain...';
  
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isInitializing => _isInitializing;
  bool get isProcessing => _isProcessing;
  double get downloadProgress => _downloadProgress;
  String get statusMessage => _statusMessage;

  VoiceCommandController() {
    _init();
  }

  Future<void> _init() async {
    await _initTts();
    await _initLlm();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); 
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initLlm() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/qwen_0.5b.gguf';
      final modelFile = File(modelPath);

      if (!modelFile.existsSync()) {
        _statusMessage = "Model not found in local storage. Checking assets...";
        notifyListeners();
        print("Model not found in local storage. Checking assets...");
        try {
          final data = await rootBundle.load('assets/models/qwen_0.5b.gguf');
          final bytes = data.buffer.asUint8List();
          await modelFile.writeAsBytes(bytes, flush: true);
          print("Model successfully copied from assets to $modelPath");
        } catch (e) {
          print("Failed to copy from assets: $e. Starting download from Hugging Face...");
          await _downloadModel(modelPath);
        }
      }
      
      _statusMessage = "Initializing Qwen 0.5B local engine...";
      notifyListeners();
      await _llmService.initialize(modelPath);
      _statusMessage = "EasyLens is ready.";
      notifyListeners();
    } catch (e) {
      _statusMessage = "Error initializing AI model.";
      notifyListeners();
      print("Error initializing LLM: $e");
    }
  }

  Future<void> _downloadModel(String destinationPath) async {
    final url = 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf';
    try {
      _statusMessage = "Downloading Qwen 0.5B (~397MB) from Hugging Face...";
      notifyListeners();
      
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      
      if (response.statusCode != 200) {
        throw Exception("Failed to download model, status code: ${response.statusCode}");
      }

      final contentLength = response.contentLength ?? 1;
      int downloadedBytes = 0;
      final file = File(destinationPath);
      final sink = file.openWrite();

      await response.stream.listen((chunk) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        _downloadProgress = downloadedBytes / contentLength;
        _statusMessage = "Downloading local brain: ${(_downloadProgress * 100).toStringAsFixed(1)}%";
        notifyListeners();
      }).asFuture();

      await sink.close();
      print("Model downloaded successfully to $destinationPath");
    } catch (e) {
      print("Failed to download model: $e");
      _statusMessage = "Failed to download model. Please check internet connection.";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleListening(BuildContext context) async {
    if (_isInitializing || _isProcessing) return;

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        _lastWords = '';
        notifyListeners();
        _speech.listen(
          onResult: (val) {
            _lastWords = val.recognizedWords;
            notifyListeners();
          },
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      notifyListeners();
      
      if (_lastWords.isNotEmpty) {
        final detectionProvider = Provider.of<DetectionProvider>(context, listen: false);
        await Future.delayed(const Duration(milliseconds: 200));
        final String visionContext = _formatVisionContext(detectionProvider.detections);
        await _processVoiceCommand(_lastWords, visionContext, context);
      }
    }
  }

  String _formatVisionContext(List<DetectedObject> objects) {
    if (objects.isEmpty) return "Currently, I don't see any specific objects.";
    
    final sorted = List<DetectedObject>.from(objects)..sort((a,b) => b.confidence.compareTo(a.confidence));
    final labels = sorted.map((obj) => obj.name).take(3).toList();
    
    return "I can see the following in front of you: ${labels.join(', ')}.";
  }

  Future<void> _processVoiceCommand(String command, String visionContext, BuildContext context) async {
    if (_isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final navProvider = Provider.of<NavigationProvider>(context, listen: false);
      
      if (!_llmService.isInitialized) {
        await _flutterTts.speak("EasyLens is still processing startup data. Please wait.");
        _isProcessing = false;
        notifyListeners();
        return;
      }

      final response = await _llmService.generateResponse(
        userMessage: command,
        visionContext: visionContext,
      );

      if (response.toLowerCase().contains('"intent": "navigate"') || 
          response.toLowerCase().contains("switching to") ||
          response.toLowerCase().contains("opening")) {
        
        if (response.toLowerCase().contains("map") || response.toLowerCase().contains("navigation")) {
          await _flutterTts.speak("Switching to Navigation.");
          navProvider.setTabIndex(1);
        } else if (response.toLowerCase().contains("home") || response.toLowerCase().contains("dashboard")) {
          await _flutterTts.speak("Going to Dashboard.");
          navProvider.setTabIndex(0);
        } else if (response.toLowerCase().contains("device") || response.toLowerCase().contains("glasses")) {
          await _flutterTts.speak("Opening Devices.");
          navProvider.setTabIndex(2);
        } else if (response.toLowerCase().contains("chat")) {
          await _flutterTts.speak("Opening Chatbot.");
          navProvider.setTabIndex(3);
        } else {
          await _flutterTts.speak(response);
        }
      } else {
        await _flutterTts.speak(response);
      }
    } catch (e) {
      debugPrint("Voice command error: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> generateResponseFromText(String text) async {
    if (_isProcessing) return "One moment, I am already thinking...";
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      final response = await _llmService.generateResponse(
        userMessage: text,
        visionContext: "The user is currently using the dedicated chat interface.",
      );
      return response;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
