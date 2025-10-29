import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _capturedImagePath;
  Timer? _analysisTimer;
  bool _isRealtimeAnalysis = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isCapturing => _isCapturing;
  String? get capturedImagePath => _capturedImagePath;
  bool get isRealtimeAnalysis => _isRealtimeAnalysis;

  Future<void> initializeCamera() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize controller with back camera
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  void startRealtimeAnalysis(Function(String) onAnalysisComplete) {
    if (!_isInitialized || _controller == null || _isRealtimeAnalysis) {
      return;
    }

    _isRealtimeAnalysis = true;
    notifyListeners();

    // Capture frame every 3 seconds for analysis (slower to avoid camera conflicts)
    _analysisTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        if (_controller != null && _controller!.value.isInitialized) {
          final base64Image = await captureFrameToBase64();
          if (base64Image != null) {
            onAnalysisComplete(base64Image);
          }
        }
      } catch (e) {
        debugPrint('Error in realtime analysis: $e');
        // Stop analysis on error to prevent continuous failures
        stopRealtimeAnalysis();
      }
    });
  }

  void stopRealtimeAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _isRealtimeAnalysis = false;
    notifyListeners();
  }

  Future<Uint8List?> captureImageBytes() async {
    if (!_isInitialized || _controller == null) {
      return null;
    }

    try {
      _isCapturing = true;
      notifyListeners();

      // Take picture
      final image = await _controller!.takePicture();

      // Read image as bytes
      final imageBytes = await image.readAsBytes();
      
      _capturedImagePath = image.path;
      notifyListeners();

      return imageBytes;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    } finally {
      _isCapturing = false;
      notifyListeners();
    }
  }

  Future<String?> captureImage() async {
    final bytes = await captureImageBytes();
    if (bytes == null) return null;

    // Convert to base64
    return base64Encode(bytes);
  }

  Future<String?> captureFrameToBase64() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      // Add a small delay to ensure camera is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error capturing frame: $e');
      return null;
    }
  }

  void disposeCamera() {
    stopRealtimeAnalysis();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }
}
