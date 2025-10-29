import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiskProvider extends ChangeNotifier {
  static const String backendUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String backendUrl = 'http://localhost:5000'; // For iOS simulator or physical device on same network

  double _glaucomaRisk = 0.0;
  double _iopLevel = 0.0;
  double _eyeDiameter = 0.0;
  double _bloodPressure = 120.0;
  int _age = 40;
  bool _hasFamilyHistory = false;
  bool _isDiabetic = false;
  bool _isAnalyzing = false;
  String? _lastError;

  // AI Model Results
  ACDPrediction? _lastACDPrediction;
  EyeFeatures? _lastEyeFeatures;

  RiskAnalysis? _lastAnalysis;

  double get glaucomaRisk => _glaucomaRisk;
  double get iopLevel => _iopLevel;
  double get eyeDiameter => _eyeDiameter;
  double get bloodPressure => _bloodPressure;
  int get age => _age;
  bool get hasFamilyHistory => _hasFamilyHistory;
  bool get isDiabetic => _isDiabetic;
  bool get isAnalyzing => _isAnalyzing;
  String? get lastError => _lastError;
  ACDPrediction? get lastACDPrediction => _lastACDPrediction;
  EyeFeatures? get lastEyeFeatures => _lastEyeFeatures;
  RiskAnalysis? get lastAnalysis => _lastAnalysis;

  Future<void> analyzeEyeWithAI(String base64Image,
      {bool preferRightEye = true}) async {
    _isAnalyzing = true;
    _lastError = null;
    notifyListeners();

    try {
      // Call AI backend
      final response = await http
          .post(
            Uri.parse('$backendUrl/analyze_eye'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': base64Image,
              'prefer_right_eye': preferRightEye,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          // Store AI results
          _lastACDPrediction = ACDPrediction.fromJson(data['prediction']);
          _lastEyeFeatures = EyeFeatures.fromJson(data['features']);

          // Update diameter for display
          _eyeDiameter = data['iris']['diameter_px']?.toDouble() ?? 0.0;

          // Map ACD risk to glaucoma risk
          _mapACDToGlaucomaRisk();

          // Generate comprehensive analysis
          _generateAIRecommendations();

          notifyListeners();
        } else {
          _lastError = data['error'] ?? 'Analysis failed';
          notifyListeners();
        }
      } else {
        _lastError = 'Server error: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      _lastError = 'Connection error: $e. Make sure backend is running.';
      notifyListeners();
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void _mapACDToGlaucomaRisk() {
    if (_lastACDPrediction == null) return;

    // Map ACD risk levels to glaucoma risk
    final acd = _lastACDPrediction!.acdMm;

    if (acd < 2.4) {
      _glaucomaRisk = 80.0; // HIGH RISK
    } else if (acd < 2.7) {
      _glaucomaRisk = 50.0; // MODERATE RISK
    } else {
      _glaucomaRisk = 15.0; // LOW RISK
    }
  }

  void _generateAIRecommendations() {
    if (_lastACDPrediction == null) return;

    final recommendations = _lastACDPrediction!.recommendation
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    _lastAnalysis = RiskAnalysis(
      riskLevel: _glaucomaRisk,
      iopLevel: _iopLevel,
      eyeDiameter: _eyeDiameter,
      confidence: _lastACDPrediction!.confidence * 100,
      recommendations: recommendations,
      acdPrediction: _lastACDPrediction,
    );

    notifyListeners();
  }

  void updateIOPLevel(double iop) {
    _iopLevel = iop;
    _calculateRisk();
  }

  void updateEyeDiameter(double diameter) {
    _eyeDiameter = diameter;
    _calculateRisk();
  }

  void updateBloodPressure(double bp) {
    _bloodPressure = bp;
    _calculateRisk();
  }

  void updateAge(int age) {
    _age = age;
    _calculateRisk();
  }

  void updateFamilyHistory(bool history) {
    _hasFamilyHistory = history;
    _calculateRisk();
  }

  void updateDiabetesStatus(bool diabetic) {
    _isDiabetic = diabetic;
    _calculateRisk();
  }

  void analyzeImage(String imagePath) {
    // Simulate AI model analysis
    _eyeDiameter = 24.0 + Random().nextDouble() * 2;
    _calculateRisk();
  }

  void _calculateRisk() {
    // Simplified AI-based risk calculation
    // This would typically call an actual ML model

    double riskScore = 0.0;

    // IOP contribution (40% weight)
    if (_iopLevel > 21) {
      riskScore += ((_iopLevel - 21) / 20) * 40;
    }

    // Age contribution (20% weight)
    if (_age > 40) {
      riskScore += ((_age - 40) / 40).clamp(0, 1) * 20;
    }

    // Blood pressure contribution (15% weight)
    if (_bloodPressure > 140) {
      riskScore += ((_bloodPressure - 140) / 60).clamp(0, 1) * 15;
    }

    // Family history (15% weight)
    if (_hasFamilyHistory) {
      riskScore += 15;
    }

    // Diabetes (10% weight)
    if (_isDiabetic) {
      riskScore += 10;
    }

    _glaucomaRisk = riskScore.clamp(0, 100);

    _lastAnalysis = RiskAnalysis(
      riskLevel: _glaucomaRisk,
      iopLevel: _iopLevel,
      eyeDiameter: _eyeDiameter,
      confidence: 85.0,
      recommendations: _generateRecommendations(),
    );

    notifyListeners();
  }

  List<String> _generateRecommendations() {
    List<String> recommendations = [];

    if (_glaucomaRisk < 30) {
      recommendations.add('Low risk. Continue regular eye exams.');
    } else if (_glaucomaRisk < 60) {
      recommendations.add('Moderate risk. Schedule follow-up in 3 months.');
      recommendations.add('Monitor blood pressure regularly.');
    } else {
      recommendations.add('High risk. Consult an ophthalmologist immediately.');
      recommendations.add('Consider starting treatment if recommended.');
    }

    if (_iopLevel > 21) {
      recommendations.add('IOP is elevated. Regular monitoring required.');
    }

    if (_hasFamilyHistory) {
      recommendations.add(
        'Family history increases risk. Annual screenings recommended.',
      );
    }

    return recommendations;
  }
}

class ACDPrediction {
  final double acdMm;
  final String riskLevel;
  final int riskScore;
  final double confidence;
  final String recommendation;
  final String detectionQuality;
  final List<String> featuresUsed;

  ACDPrediction({
    required this.acdMm,
    required this.riskLevel,
    required this.riskScore,
    required this.confidence,
    required this.recommendation,
    required this.detectionQuality,
    required this.featuresUsed,
  });

  factory ACDPrediction.fromJson(Map<String, dynamic> json) {
    return ACDPrediction(
      acdMm: json['acd_mm']?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] ?? 'UNKNOWN',
      riskScore: json['risk_score'] ?? 0,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] ?? '',
      detectionQuality: json['detection_quality'] ?? 'Unknown',
      featuresUsed: List<String>.from(json['features_used'] ?? []),
    );
  }
}

class EyeFeatures {
  final double irisPupilRatio;
  final double pupilEccentricity;
  final double normalizedPupilSize;
  final double irisDiameterPx;
  final double pupilDiameterPx;

  EyeFeatures({
    required this.irisPupilRatio,
    required this.pupilEccentricity,
    required this.normalizedPupilSize,
    required this.irisDiameterPx,
    required this.pupilDiameterPx,
  });

  factory EyeFeatures.fromJson(Map<String, dynamic> json) {
    return EyeFeatures(
      irisPupilRatio: json['iris_pupil_ratio']?.toDouble() ?? 0.0,
      pupilEccentricity: json['pupil_eccentricity']?.toDouble() ?? 0.0,
      normalizedPupilSize: json['normalized_pupil_size']?.toDouble() ?? 0.0,
      irisDiameterPx: json['iris_diameter_px']?.toDouble() ?? 0.0,
      pupilDiameterPx: json['pupil_diameter_px']?.toDouble() ?? 0.0,
    );
  }
}

class RiskAnalysis {
  final double riskLevel;
  final double iopLevel;
  final double eyeDiameter;
  final double confidence;
  final List<String> recommendations;
  final ACDPrediction? acdPrediction;

  RiskAnalysis({
    required this.riskLevel,
    required this.iopLevel,
    required this.eyeDiameter,
    required this.confidence,
    required this.recommendations,
    this.acdPrediction,
  });
}
