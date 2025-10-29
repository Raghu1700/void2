import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/esp_provider.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final espProvider = Provider.of<ESPProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
      ),
      body: espProvider.readingHistory.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: espProvider.readingHistory.length,
              itemBuilder: (context, index) {
                final reading = espProvider.readingHistory[index];
                return _buildHistoryCard(context, reading, index);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No readings yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to device to start recording',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    IOPReading reading,
    int index,
  ) {
    final isLatest = index == 0;
    final timeAgo = _getTimeAgo(reading.timestamp);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isLatest ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showReadingDetails(context, reading);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getIOPColor(reading.iop).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.remove_red_eye,
                    color: _getIOPColor(reading.iop),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${reading.iop.toStringAsFixed(1)} mmHg',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LATEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReadingDetails(BuildContext context, IOPReading reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reading Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildDetailItem(
                'Intraocular Pressure',
                '${reading.iop.toStringAsFixed(1)} mmHg',
                Icons.medical_services,
                _getIOPColor(reading.iop),
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                'ARF (Acoustic Radiation Force)',
                '${reading.arf.toStringAsFixed(3)} μN',
                Icons.speed,
                AppTheme.primaryGreen,
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                'Deformation',
                '${reading.deformation.toStringAsFixed(4)} mm',
                Icons.vertical_align_bottom,
                AppTheme.primaryPurple,
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                'Timestamp',
                DateFormat('MMM dd, yyyy HH:mm:ss').format(reading.timestamp),
                Icons.access_time,
                Colors.grey.shade600,
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildStatusIndicator(reading.iop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
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
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(double iop) {
    String status;
    Color statusColor;

    if (iop < 12) {
      status = 'Low';
      statusColor = AppTheme.primaryBlue;
    } else if (iop <= 21) {
      status = 'Normal';
      statusColor = AppTheme.successGreen;
    } else if (iop <= 30) {
      status = 'Elevated';
      statusColor = AppTheme.warningOrange;
    } else {
      status = 'High - Consult Doctor';
      statusColor = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 12),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIOPColor(double iop) {
    if (iop < 12) return AppTheme.primaryBlue;
    if (iop <= 21) return AppTheme.successGreen;
    if (iop <= 30) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

