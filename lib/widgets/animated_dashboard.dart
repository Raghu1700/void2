import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/esp_provider.dart';
import '../theme/app_theme.dart';
import 'animated_metric_card.dart';

class AnimatedDashboard extends StatefulWidget {
  const AnimatedDashboard({super.key});

  @override
  State<AnimatedDashboard> createState() => _AnimatedDashboardState();
}

class _AnimatedDashboardState extends State<AnimatedDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espProvider = Provider.of<ESPProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.offWhite,
            AppTheme.lightCream.withOpacity(0.5),
            AppTheme.pureWhite,
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(),

              const SizedBox(height: 24),

              // Sensor Readings Section
              _buildSensorReadingsSection(espProvider),

              const SizedBox(height: 28),

              // Control Buttons
              _buildControlButtons(espProvider),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.remove_red_eye_rounded,
              color: AppTheme.textDark,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SonoSight',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'IOP Monitoring Dashboard',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorReadingsSection(ESPProvider espProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: AppTheme.textDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sensor Readings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
              ),
            ],
          ),
        ),

        // Metric Cards Grid
        _buildMetricsGrid(espProvider),
      ],
    );
  }

  Widget _buildMetricsGrid(ESPProvider espProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Distance',
                value: espProvider.distance.toStringAsFixed(2),
                unit: 'cm',
                icon: Icons.straighten_rounded,
                color: AppTheme.infoBlue,
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Area',
                value: (espProvider.area * 10000).toStringAsFixed(4),
                unit: 'cm²',
                icon: Icons.crop_square_rounded,
                color: AppTheme.primaryPurple,
                delay: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'ARF',
                value: espProvider.arf.toStringAsFixed(3),
                unit: 'N',
                icon: Icons.waves_rounded,
                color: AppTheme.successGreen,
                delay: 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Deformation',
                value: (espProvider.deformation * 1000).toStringAsFixed(4),
                unit: 'm',
                icon: Icons.compress_rounded,
                color: AppTheme.warningOrange,
                delay: 150,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'IOP',
                value: espProvider.currentIOP.toStringAsFixed(2),
                unit: 'mmHg',
                icon: Icons.remove_red_eye_rounded,
                color: AppTheme.accentGold,
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Avg IOP',
                value: espProvider.avgIOP.toStringAsFixed(2),
                unit: 'mmHg',
                icon: Icons.analytics_rounded,
                color: AppTheme.accentGold,
                delay: 250,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(ESPProvider espProvider) {
    return Column(
      children: [
        // Info banner about Firebase
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryRed.withOpacity(0.1),
                AppTheme.accentGold.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_sync_rounded,
                color: AppTheme.accentGold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-time Firebase Sync',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add data to Firebase Console to see it here',
                      style: TextStyle(
                        color: AppTheme.warmGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Control buttons
        Row(
          children: [
            Expanded(
              child: _buildStyledButton(
                label: espProvider.isConnected ? 'Disconnect' : 'Connect',
                icon: espProvider.isConnected
                    ? Icons.link_off_rounded
                    : Icons.link_rounded,
                color: espProvider.isConnected
                    ? AppTheme.dangerRed
                    : AppTheme.primaryRed,
                onPressed: espProvider.isConnected
                    ? espProvider.disconnect
                    : espProvider.connectToDevice,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledButton(
                label: espProvider.isScanning ? 'Stop' : 'Start',
                icon: espProvider.isScanning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: espProvider.isScanning
                    ? AppTheme.warningOrange
                    : AppTheme.successGreen,
                onPressed: espProvider.isConnected
                    ? (espProvider.isScanning
                        ? espProvider.stopRealTimeReading
                        : espProvider.startRealTimeReading)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == AppTheme.accentGold
              ? AppTheme.textDark
              : AppTheme.pureWhite,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: onPressed != null ? 6 : 2,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
