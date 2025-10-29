import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/esp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_dashboard.dart';

class AnimatedDashboardPage extends StatefulWidget {
  const AnimatedDashboardPage({super.key});

  @override
  State<AnimatedDashboardPage> createState() => _AnimatedDashboardPageState();
}

class _AnimatedDashboardPageState extends State<AnimatedDashboardPage> {
  @override
  void initState() {
    super.initState();

    // Auto-connect to device on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final espProvider = Provider.of<ESPProvider>(context, listen: false);
      if (!espProvider.isConnected) {
        espProvider.connectToDevice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final espProvider = Provider.of<ESPProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await espProvider.connectToDevice();
        },
        color: AppTheme.primaryRed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              const AnimatedDashboard(),
            ],
          ),
        ),
      ),
    );
  }
}
