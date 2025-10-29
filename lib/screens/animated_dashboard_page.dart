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

class _AnimatedDashboardPageState extends State<AnimatedDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();
    
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _appBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeOutCubic,
    ));

    _appBarController.forward();

    // Auto-connect to device on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final espProvider = Provider.of<ESPProvider>(context, listen: false);
      if (!espProvider.isConnected) {
        espProvider.connectToDevice();
      }
    });
  }

  @override
  void dispose() {
    _appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espProvider = Provider.of<ESPProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeTransition(
          opacity: _appBarAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SonoSight',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                // Refresh data
                espProvider.connectToDevice();
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.primaryYellow,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await espProvider.connectToDevice();
        },
        color: AppTheme.primaryYellow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 60),
              const AnimatedDashboard(),
            ],
          ),
        ),
      ),
    );
  }
}
