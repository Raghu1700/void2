import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/esp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_dashboard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Auto-connect to device on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final espProvider = Provider.of<ESPProvider>(context, listen: false);
      espProvider.connectToDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final espProvider = Provider.of<ESPProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SonoSight Dashboard'),
        actions: [ConnectionStatusWidget()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await espProvider.connectToDevice();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main IOP Display Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Current IOP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${espProvider.currentIOP.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        'mmHg',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildIOPStatus(espProvider.currentIOP),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

               // 3D Eye Visualization
               Card(
                 child: Padding(
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Eye Visualization',
                         style: Theme.of(context).textTheme.titleLarge,
                       ),
                       const SizedBox(height: 20),
                       Container(
                         height: 300,
                         width: double.infinity,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(
                             color: Colors.grey.shade300,
                             width: 1,
                           ),
                         ),
                         child: const EyeVisualizationWidget(),
                       ),
                       const SizedBox(height: 16),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           IconButton(
                             onPressed: () {
                               // Reset view - show message for now
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Reset view - touch and drag the eye to rotate!')),
                               );
                             },
                             icon: const Icon(Icons.refresh),
                             tooltip: 'Reset View',
                           ),
                           IconButton(
                             onPressed: () {
                               // Toggle wireframe - show message for now
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Wireframe toggle - coming soon!')),
                               );
                             },
                             icon: const Icon(Icons.grid_3x3),
                             tooltip: 'Toggle Wireframe',
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
              const SizedBox(height: 24),

              // ESP8266 Readings
              Text(
                'Sensor Readings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'ARF',
                      value: espProvider.arf.toStringAsFixed(3),
                      unit: 'μN',
                      icon: Icons.speed,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Deformation',
                      value: espProvider.deformation.toStringAsFixed(4),
                      unit: 'mm',
                      icon: Icons.vertical_align_bottom,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                       const Icon(
                         Icons.settings,
                         size: 32,
                         color: AppTheme.primaryBlue,
                       ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resistance',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            Text(
                              '${espProvider.resistance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Control Buttons
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          espProvider.isScanning
                              ? () => espProvider.stopRealTimeReading()
                              : () => espProvider.startRealTimeReading(),
                      icon: Icon(
                        espProvider.isScanning ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(
                        espProvider.isScanning ? 'Pause Scan' : 'Start Scan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => espProvider.disconnect(),
                      icon: const Icon(Icons.bluetooth_disabled),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOPStatus(double iop) {
    String status;
    Color statusColor;
    IconData statusIcon;

    if (iop < 12) {
      status = 'Low';
      statusColor = AppTheme.primaryBlue;
      statusIcon = Icons.arrow_downward;
    } else if (iop <= 21) {
      status = 'Normal';
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle_outline;
    } else if (iop <= 30) {
      status = 'Elevated';
      statusColor = AppTheme.warningOrange;
      statusIcon = Icons.warning_amber;
    } else {
      status = 'High';
      statusColor = AppTheme.dangerRed;
      statusIcon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
