import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../providers/risk_provider.dart';
import '../providers/esp_provider.dart';
import '../theme/app_theme.dart';

class RiskCalculationPage extends StatefulWidget {
  const RiskCalculationPage({super.key});

  @override
  State<RiskCalculationPage> createState() => _RiskCalculationPageState();
}

class _RiskCalculationPageState extends State<RiskCalculationPage> {
  bool _showCamera = true; // Auto-start camera

  @override
  void initState() {
    super.initState();
    // Auto-initialize camera and sync IOP data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cameraProvider =
          Provider.of<CameraProvider>(context, listen: false);
      final espProvider = Provider.of<ESPProvider>(context, listen: false);
      final riskProvider = Provider.of<RiskProvider>(context, listen: false);

      // Auto-start camera
      cameraProvider.initializeCamera();

      // Sync IOP data with risk provider
      if (espProvider.isConnected) {
        riskProvider.updateIOPLevel(espProvider.currentIOP);
      }
    });
  }

  @override
  void dispose() {
    // Stop real-time analysis when leaving the page
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    cameraProvider.stopRealtimeAnalysis();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riskProvider = Provider.of<RiskProvider>(context);
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Analysis'),
        actions: [
          IconButton(
            icon: Icon(_showCamera ? Icons.close : Icons.camera_alt),
            onPressed: () {
              setState(() {
                _showCamera = !_showCamera;
              });
              if (_showCamera) {
                cameraProvider.initializeCamera();
              } else {
                cameraProvider.disposeCamera();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera Preview or Placeholder
            if (_showCamera && cameraProvider.isInitialized)
              _buildCameraPreview(cameraProvider, riskProvider)
            else if (!_showCamera)
              _buildCameraPlaceholder(),

            const SizedBox(height: 24),

            // Digital Risk Reading
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Glaucoma Risk Assessment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildDigitalRiskDisplay(riskProvider.glaucomaRisk),
                    const SizedBox(height: 16),
                    _buildRiskLevel(riskProvider.glaucomaRisk),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Model Parameters
            Text(
              'AI Analysis Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // ACD Prediction
            if (riskProvider.lastACDPrediction != null) ...[
              _buildParameterCard(
                'ACD Prediction',
                '${riskProvider.lastACDPrediction!.acdMm.toStringAsFixed(1)} mm',
                Icons.visibility,
                AppTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              _buildParameterCard(
                'Risk Level',
                riskProvider.lastACDPrediction!.riskLevel,
                Icons.warning,
                _getRiskColor(riskProvider.lastACDPrediction!.riskLevel),
              ),
              const SizedBox(height: 12),
            ],

            // Eye Features
            if (riskProvider.lastEyeFeatures != null) ...[
              _buildParameterCard(
                'Iris-Pupil Ratio',
                riskProvider.lastEyeFeatures!.irisPupilRatio.toStringAsFixed(3),
                Icons.compare_arrows,
                AppTheme.primaryGreen,
              ),
              const SizedBox(height: 12),
              _buildParameterCard(
                'Pupil Eccentricity',
                riskProvider.lastEyeFeatures!.pupilEccentricity
                    .toStringAsFixed(3),
                Icons.center_focus_strong,
                AppTheme.primaryPurple,
              ),
              const SizedBox(height: 12),
            ],

            _buildParameterCard(
              'Confidence',
              '${riskProvider.lastAnalysis?.confidence.toStringAsFixed(1) ?? '0.0'}%',
              Icons.check_circle,
              AppTheme.primaryPurple,
            ),

            const SizedBox(height: 24),

            // Recommendations
            if (riskProvider.lastAnalysis != null)
              Card(
                color: _getRecommendationColor(
                  riskProvider.glaucomaRisk,
                ).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.recommend,
                            color: _getRecommendationColor(
                              riskProvider.glaucomaRisk,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommendations',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...riskProvider.lastAnalysis!.recommendations.map(
                        (rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(rec)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(
      CameraProvider cameraProvider, RiskProvider riskProvider) {
    if (cameraProvider.controller == null || !cameraProvider.isInitialized) {
      return Card(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.1),
                AppTheme.primaryGreen.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Initializing Camera...',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 400,
            child: CameraPreview(cameraProvider.controller!),
          ),
          // Overlay with instructions
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cameraProvider.isRealtimeAnalysis
                    ? 'Real-time analysis active - analyzing every 3 seconds'
                    : 'Focus on your eye and tap capture or start real-time',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Real-time Analysis Toggle Button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: cameraProvider.isRealtimeAnalysis
                        ? () => cameraProvider.stopRealtimeAnalysis()
                        : () => cameraProvider
                                .startRealtimeAnalysis((base64Image) async {
                              await riskProvider.analyzeEyeWithAI(base64Image);
                            }),
                    backgroundColor: cameraProvider.isRealtimeAnalysis
                        ? AppTheme.dangerRed
                        : AppTheme.successGreen,
                    child: cameraProvider.isRealtimeAnalysis
                        ? const Icon(Icons.stop)
                        : const Icon(Icons.play_arrow),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: riskProvider.isAnalyzing
                        ? null
                        : () async {
                            final base64Image =
                                await cameraProvider.captureFrameToBase64();
                            if (base64Image != null) {
                              await riskProvider.analyzeEyeWithAI(base64Image);
                            }
                          },
                    backgroundColor: riskProvider.isAnalyzing
                        ? Colors.grey
                        : AppTheme.primaryBlue,
                    child: riskProvider.isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.camera),
                  ),
                ],
              ),
            ),
          ),
          // Real-time analysis indicator
          if (cameraProvider.isRealtimeAnalysis)
            Positioned(
              top: 50,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Real-time analysis running...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Error message
          if (riskProvider.lastError != null)
            Positioned(
              top: cameraProvider.isRealtimeAnalysis ? 90 : 50,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  riskProvider.lastError!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Card(
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryRed.withOpacity(0.1),
              AppTheme.accentGold.withOpacity(0.1),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppTheme.primaryRed,
              ),
              SizedBox(height: 16),
              Text(
                'Camera auto-started - Focus on your eye',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalRiskDisplay(double risk) {
    Color color;
    if (risk < 30) {
      color = AppTheme.successGreen;
    } else if (risk < 60) {
      color = AppTheme.warningOrange;
    } else {
      color = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            risk.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevel(double risk) {
    String level;
    Color color;

    if (risk < 30) {
      level = 'Low Risk';
      color = AppTheme.successGreen;
    } else if (risk < 60) {
      level = 'Moderate Risk';
      color = AppTheme.warningOrange;
    } else {
      level = 'High Risk';
      color = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParameterCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRecommendationColor(double risk) {
    if (risk < 30) return AppTheme.successGreen;
    if (risk < 60) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return AppTheme.successGreen;
      case 'MODERATE':
        return AppTheme.warningOrange;
      case 'HIGH':
        return AppTheme.dangerRed;
      default:
        return Colors.grey;
    }