import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final data = await ApiService.getAnalytics();
    
    if (mounted) {
      setState(() {
        _analytics = data.isNotEmpty ? data : {
          'totalComplaints': 0,
          'resolved': 0,
          'inProgress': 0,
          'open': 0,
          'platformCounts': [],
          'statusCounts': [],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          )
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Performance Analytics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Track your business metrics',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard(
                    'Total Complaints',
                    (_analytics['totalComplaints'] ?? 0).toString(),
                    Icons.warning_amber_rounded,
                    const Color(0xFFFF6B6B),
                  ),
                  _buildMetricCard(
                    'Solved',
                    (_analytics['solved'] ?? _analytics['resolved'] ?? 0)
                        .toString(),
                    Icons.check_circle,
                    const Color(0xFF00C853),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard(
                    'In Progress',
                    (_analytics['inProgress'] ?? 0).toString(),
                    Icons.hourglass_bottom,
                    const Color(0xFFFFA500),
                  ),
                  _buildMetricCard(
                    'Opened',
                    (_analytics['opened'] ?? _analytics['open'] ?? 0)
                        .toString(),
                    Icons.timer,
                    const Color(0xFF00D4FF),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Complaints by Platform',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0FF)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5FF),
                ),
                child: Column(
                  children: [
                    _buildPlatformBar('Amazon', 15, 0.6),
                    const SizedBox(height: 16),
                    _buildPlatformBar('Flipkart', 12, 0.5),
                    const SizedBox(height: 16),
                    _buildPlatformBar('Myntra', 10, 0.42),
                    const SizedBox(height: 16),
                    _buildPlatformBar('Ajio', 8, 0.35),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Complaint Status Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0FF)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5FF),
                ),
                child: Column(
                  children: [
                    _buildStatusDistribution(
                      'Opened',
                      ((_analytics['opened'] ?? _analytics['open'] ?? 0) as num)
                          .toInt(),
                      const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusDistribution(
                      'In-progress',
                      ((_analytics['inProgress'] ?? 0) as num).toInt(),
                      const Color(0xFFFFA500),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusDistribution(
                      'Solved',
                      ((_analytics['solved'] ?? _analytics['resolved'] ?? 0)
                              as num)
                          .toInt(),
                      const Color(0xFF00C853),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusDistribution(
                      'Rejected',
                      ((_analytics['rejected'] ?? _analytics['closed'] ?? 0)
                              as num)
                          .toInt(),
                      const Color(0xFF909090),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      const Color(0xFF00D4FF).withValues(alpha: 0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resolution Rate: 71%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.71,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00C853),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
            ),
          ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformBar(String platform, int count, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              platform,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$count complaints',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF6C63FF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution(String status, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
