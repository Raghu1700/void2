import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SonoSight'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.remove_red_eye,
                  size: 60,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Center(
              child: Text(
                'SonoSight',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Problem Section
            _buildSection(
              context,
              'The Problem',
              'Glaucoma is a leading cause of irreversible blindness worldwide. Existing IOP measurement methods are expensive, require specialized training, and are inaccessible to rural areas.',
              Icons.medical_information,
            ),
            const SizedBox(height: 24),

            // Solution Section
            _buildSection(
              context,
              'Our Solution',
              'SonoSight uses ultrasound-based acoustic radiation force (ARF) to measure intraocular pressure non-invasively. It\'s affordable, portable, and perfect for underserved regions.',
              Icons.lightbulb_outline,
            ),
            const SizedBox(height: 24),

            // Advantages
            Text(
              'Key Advantages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAdvantageItem('✓ Affordable', 'Cost-effective solution'),
            _buildAdvantageItem('✓ Accessible', 'Ideal for rural areas'),
            _buildAdvantageItem('✓ User-Friendly', 'Easy to use'),
            _buildAdvantageItem('✓ Early Detection', 'Detect risk early'),
            _buildAdvantageItem('✓ Scalable', 'Deploy widely'),
            const SizedBox(height: 32),

            // Technology
            _buildSection(
              context,
              'Technology',
              'ESP8266 microcontroller, ultrasonic sensors, real-time ARF calculation, deformation measurement, and AI-powered risk assessment.',
              Icons.science_outlined,
            ),
            const SizedBox(height: 32),

            // Contact
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.contact_support,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Contact & Support',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For questions or support, please contact our team.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            Center(
              child: Text(
                '© 2024 SonoSight. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

