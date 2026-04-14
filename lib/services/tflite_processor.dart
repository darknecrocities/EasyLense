import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class TfliteProcessor {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isReady = false;
  
  // Model info
  int _inputSize = 300;
  bool _isInputUint8 = true;
  
  // Output mapping
  int _locIdx = -1;
  int _clsIdx = -1;
  int _scrIdx = -1;
  int _cntIdx = -1;
  int _maxDetections = 10;
  List<List<int>> _outputShapes = [];

  Future<void> init(String modelPath, String labelsPath) async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(modelPath, options: options);
      
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();
      
      _inputSize = inputTensors[0].shape[1];
      _isInputUint8 = inputTensors[0].type.toString().toLowerCase().contains('uint8');
      
      _outputShapes = [];
      for (int i = 0; i < outputTensors.length; i++) {
        _outputShapes.add(outputTensors[i].shape);
        final s = outputTensors[i].shape;
        if (s.length == 3 && s.last == 4) {
          _locIdx = i;
          _maxDetections = s[1];
        } else if (s.length == 1 || (s.length == 2 && s[1] == 1)) {
          _cntIdx = i;
        }
      }
      
      for (int i = 0; i < _outputShapes.length; i++) {
        if (i == _locIdx || i == _cntIdx) continue;
        if (_clsIdx == -1) _clsIdx = i;
        else if (_scrIdx == -1) _scrIdx = i;
      }
      
      final raw = await rootBundle.loadString(labelsPath);
      _labels = raw.split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => l.replaceFirst(RegExp(r'^\d+\s*'), '').trim())
          .toList();
          
      _isReady = true;
      print('[SSD] TFLite Processor ready. Input size: $_inputSize');
    } catch (e) {
      print('[SSD] Init error: $e');
    }
  }

  List<SSDResult> runInference(Uint8List rgbData) {
    if (!_isReady || _interpreter == null) return [];
    
    try {
      final input = rgbData.reshape([1, _inputSize, _inputSize, 3]);
      final outputs = <int, Object>{};
      
      for (int i = 0; i < _outputShapes.length; i++) {
        final shape = _outputShapes[i];
        outputs[i] = List.filled(shape.reduce((a, b) => a * b), 0.0).reshape(shape);
      }
      
      _interpreter!.runForMultipleInputs([input], outputs);
      
      int count = _maxDetections;
      if (_cntIdx >= 0) {
        count = _getScalar(outputs[_cntIdx]!).toInt();
      }
      
      final results = <SSDResult>[];
      double maxScore = 0.0;
      String maxLabel = 'none';

      for (int i = 0; i < math.min(count, _maxDetections); i++) {
        final double score = _getVal(outputs[_scrIdx]!, i);
        if (score > maxScore) {
          maxScore = score;
          final int tempIdx = _getVal(outputs[_clsIdx]!, i).toInt();
          if (tempIdx >= 0 && tempIdx < _labels.length) maxLabel = _labels[tempIdx];
        }

        if (score < 0.10) continue; // Lowered to 10% to capture all detections
        
        final int classIdx = _getVal(outputs[_clsIdx]!, i).toInt();
        if (classIdx <= 0 || classIdx >= _labels.length) continue;
        
        final name = _labels[classIdx];
        if (name == '???' || name.isEmpty) continue;
        
        results.add(SSDResult(
          label: name,
          confidence: score,
          classIndex: classIdx,
          yMin: _getBox(outputs[_locIdx]!, i, 0),
          xMin: _getBox(outputs[_locIdx]!, i, 1),
          yMax: _getBox(outputs[_locIdx]!, i, 2),
          xMax: _getBox(outputs[_locIdx]!, i, 3),
        ));
      }

      if (results.isNotEmpty) {
        print('[SSD] Detected: ${results.map((r) => "${r.label}(${(r.confidence*100).toInt()}%)").join(", ")}');
      } else {
        print('[SSD] No object above threshold. Best: $maxLabel (${(maxScore*100).toInt()}%)');
      }

      return results;
    } catch (e) {
      print('[SSD] Inference error: $e');
      return [];
    }
  }

  double _getScalar(Object t) {
    if (t is List) {
      var v = t;
      while (v is List && v.isNotEmpty && v[0] is List) v = v[0];
      return (v[0] as num).toDouble();
    }
    return 0.0;
  }

  double _getVal(Object t, int i) {
    if (t is List) return (t[0][i] as num).toDouble();
    return 0.0;
  }

  double _getBox(Object t, int i, int c) {
    if (t is List) return (t[0][i][c] as num).toDouble();
    return 0.0;
  }
  
  void dispose() {
    _interpreter?.close();
  }
}

class SSDResult {
  final String label;
  final double confidence;
  final int classIndex;
  final double yMin, xMin, yMax, xMax;

  SSDResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.yMin,
    required this.xMin,
    required this.yMax,
    required this.xMax,
  });

  Map<String, dynamic> toMap() => {
    'label': label,
    'conf': confidence,
    'idx': classIndex,
    'y1': yMin, 'x1': xMin, 'y2': yMax, 'x2': xMax,
  };

  factory SSDResult.fromMap(Map<String, dynamic> m) => SSDResult(
    label: m['label'],
    confidence: m['conf'],
    classIndex: m['idx'],
    yMin: m['y1'], xMin: m['x1'], yMax: m['y2'], xMax: m['x2'],
  );
}
