import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedConnectionStatus extends StatefulWidget {
  final bool isConnected;

  const AnimatedConnectionStatus({
    super.key,
    required this.isConnected,
  });

  @override
  State<AnimatedConnectionStatus> createState() => _AnimatedConnectionStatusState();
}

class _AnimatedConnectionStatusState extends State<AnimatedConnectionStatus>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _colorController;
  
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.dangerRed,
      end: AppTheme.successGreen,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void didUpdateWidget(AnimatedConnectionStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isConnected ? _pulseAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorAnimation.value?.withOpacity(0.1) ?? AppTheme.dangerRed.withOpacity(0.1),
                    _colorAnimation.value?.withOpacity(0.05) ?? AppTheme.dangerRed.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _colorAnimation.value?.withOpacity(0.3) ?? AppTheme.dangerRed.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _colorAnimation.value?.withOpacity(0.2) ?? AppTheme.dangerRed.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated Status Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _colorAnimation.value?.withOpacity(0.1) ?? AppTheme.dangerRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        widget.isConnected ? Icons.wifi : Icons.wifi_off,
                        key: ValueKey(widget.isConnected),
                        color: _colorAnimation.value ?? AppTheme.dangerRed,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Status Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _colorAnimation.value ?? AppTheme.dangerRed,
                          ),
                          child: Text(
                            widget.isConnected ? 'Device Connected' : 'Device Disconnected',
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 14,
                            color: _colorAnimation.value?.withOpacity(0.7) ?? AppTheme.dangerRed.withOpacity(0.7),
                          ),
                          child: Text(
                            widget.isConnected 
                                ? 'ESP8266 sensor is active and transmitting data'
                                : 'Connect to ESP8266 device to start monitoring',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Animated Status Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value ?? AppTheme.dangerRed,
                      shape: BoxShape.circle,
                      boxShadow: widget.isConnected ? [
                        BoxShadow(
                          color: _colorAnimation.value?.withOpacity(0.5) ?? AppTheme.successGreen.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
