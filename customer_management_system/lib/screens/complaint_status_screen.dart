import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ComplaintStatusScreen extends StatefulWidget {
  const ComplaintStatusScreen({super.key});

  @override
  State<ComplaintStatusScreen> createState() => _ComplaintStatusScreenState();
}

class _ComplaintStatusScreenState extends State<ComplaintStatusScreen> {
  List<dynamic> complaints = [];
  List<dynamic> filteredComplaints = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  String _normalizeStatus(String status) {
    switch (status) {
      case 'Open':
        return 'Opened';
      case 'In Progress':
        return 'In-progress';
      case 'Resolved':
        return 'Solved';
      case 'Closed':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final data = await ApiService.getComplaints();

    if (mounted) {
      setState(() {
        complaints = data;
        filteredComplaints = data;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  Future<void> _refreshComplaints() async {
    setState(() {
      _isLoading = true;
    });
    await _loadComplaints();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint list refreshed'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredComplaints = complaints.where((complaint) {
        final title = (complaint['title'] ?? '').toString().toLowerCase();
        final platform = (complaint['platform'] ?? '').toString().toLowerCase();
        final category = (complaint['category'] ?? '').toString().toLowerCase();
        final productCategory = (complaint['productCategory'] ?? '')
            .toString()
            .toLowerCase();
        final status = _normalizeStatus((complaint['status'] ?? '').toString());

        final matchesQuery =
            query.isEmpty ||
            title.contains(query) ||
            platform.contains(query) ||
            category.contains(query) ||
            productCategory.contains(query);
        final matchesStatus = _statusFilter == 'All' || status == _statusFilter;

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _updateComplaintStatus(dynamic complaint, String newStatus) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Updating status...'),
        backgroundColor: Color(0xFF6C63FF),
      ),
    );

    final response = await ApiService.updateComplaint(
      complaint['_id'] ?? complaint['id'],
      {'status': newStatus},
    );

    if (mounted) {
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to update status'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        _loadComplaints(); // Reload the data
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Status'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshComplaints,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
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
                              Icons.list_alt,
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
                                  'Track All Complaints',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Monitor resolution progress',
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
                      'Status Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip(
                            'Opened',
                            10,
                            const Color(0xFF6C63FF),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusChip(
                            'In-progress',
                            15,
                            const Color(0xFFFFA500),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusChip(
                            'Solved',
                            18,
                            const Color(0xFF00C853),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusChip(
                            'Rejected',
                            2,
                            const Color(0xFF909090),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by title, platform or category...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status Filter',
                        prefixIcon: Icon(Icons.filter_alt_outlined),
                      ),
                      items:
                          const [
                                'All',
                                'Opened',
                                'In-progress',
                                'Solved',
                                'Rejected',
                              ]
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value ?? 'All';
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'All Complaints',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) {
                        final complaint = filteredComplaints[index];
                        return _buildComplaintCard(context, complaint, index);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusChip(String status, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    Map<String, dynamic> complaint,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0FF)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  complaint['status'],
                ).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(complaint['status']),
                color: _getStatusColor(complaint['status']),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['id'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  complaint['status'],
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                complaint['status'],
                style: TextStyle(
                  color: _getStatusColor(complaint['status']),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Platform / Product',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${complaint['platform']} / ${complaint['productCategory'] ?? 'General'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              complaint['priority'],
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            complaint['priority'],
                            style: TextStyle(
                              color: _getPriorityColor(complaint['priority']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint['date'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint['description'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showStatusUpdateDialog(context, complaint, index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                        ),
                        child: const Text('Update Status'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showComplaintTimeline(complaint);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00D4FF)),
                        ),
                        child: const Text(
                          'Timeline',
                          style: TextStyle(color: Color(0xFF00D4FF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            complaints.removeWhere(
                              (item) =>
                                  (item['_id'] ?? item['id']) ==
                                  (complaint['_id'] ?? complaint['id']),
                            );
                            _applyFilters();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComplaintTimeline(Map<String, dynamic> complaint) {
    final history = complaint['statusHistory'] as List<dynamic>? ?? [];
    final comments = complaint['comments'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complaint Timeline'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Text('No status history available')
                else
                  ...history.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${event['from']} -> ${event['to']} by ${event['changedBy'] ?? 'System'}',
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (comments.isEmpty)
                  const Text('No comments available')
                else
                  ...comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${comment['author'] ?? 'Admin'}: ${comment['message'] ?? ''}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(
    BuildContext context,
    Map<String, dynamic> complaint,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ..._getStatusOptions(complaint['status']).map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateComplaintStatus(complaint, status);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(status),
                    ),
                    child: Text(status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getStatusOptions(String currentStatus) {
    return [
      'Opened',
      'In-progress',
      'Solved',
      'Rejected',
    ].where((status) => status != currentStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'Opened':
        return const Color(0xFF6C63FF);
      case 'In-progress':
        return const Color(0xFFFFA500);
      case 'Solved':
        return const Color(0xFF00C853);
      case 'Rejected':
        return const Color(0xFF909090);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (_normalizeStatus(status)) {
      case 'Opened':
        return Icons.radio_button_unchecked;
      case 'In-progress':
        return Icons.schedule;
      case 'Solved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF6B6B);
      case 'Medium':
        return const Color(0xFFFFA500);
      case 'Low':
        return const Color(0xFF00C853);
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
