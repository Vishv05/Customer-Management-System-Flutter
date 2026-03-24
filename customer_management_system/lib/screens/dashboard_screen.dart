import 'dart:async';

import 'package:flutter/material.dart';
import 'add_customer_screen.dart';
import 'add_complaint_screen.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart';
import 'complaint_status_screen.dart';
import 'login_screen.dart';
import 'user_notifications_page.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String userEmail;

  const DashboardScreen({super.key, required this.userEmail});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> customers = [];
  List<dynamic> complaints = [];
  List<dynamic> _notifications = [];

  List<dynamic> filteredCustomers = [];
  List<dynamic> filteredComplaints = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadNotificationCount = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterLists);
    _loadData();
    _loadNotifications();
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadNotifications(),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customerData = await ApiService.getCustomers();
      final complaintData = await ApiService.getComplaints();

      if (!mounted) return;
      setState(() {
        customers = customerData;
        complaints = complaintData;
        filteredCustomers = customers;
        filteredComplaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data. Please try again.';
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([_loadData(), _loadNotifications()]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard refreshed'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

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

  Future<void> _loadNotifications() async {
    final response = await ApiService.getNotifications(
      recipientType: 'User',
      recipientEmail: widget.userEmail,
      limit: 100,
    );

    if (!mounted) return;

    final notifications = (response['notifications'] as List<dynamic>?) ?? [];
    final unreadCount = (response['unreadCount'] as num?)?.toInt() ?? 0;

    setState(() {
      _notifications = notifications;
      _unreadNotificationCount = unreadCount;
    });
  }

  Future<void> _markAllNotificationsRead() async {
    await ApiService.markAllNotificationsRead(
      recipientType: 'User',
      recipientEmail: widget.userEmail,
    );
    await _loadNotifications();
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _markAllNotificationsRead();
                          if (mounted && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Mark all read'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _notifications.isEmpty
                        ? const Center(
                            child: Text('No complaint notifications yet'),
                          )
                        : ListView.separated(
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) =>
                              const Divider(),
                            itemBuilder: (context, index) {
                              final item = _notifications[index]
                                  as Map<String, dynamic>;
                              final isRead = item['read'] == true;
                              final title = (item['complaintTitle'] ?? '')
                                  .toString();
                              final message =
                                  (item['message'] ?? '').toString();
                              final status = _normalizeStatus(
                                (item['complaintStatus'] ?? '').toString(),
                              );

                              return ListTile(
                                leading: Icon(
                                  isRead
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: isRead
                                      ? Colors.grey
                                      : const Color(0xFF6C63FF),
                                ),
                                title: Text(
                                  title.isEmpty ? 'Complaint Update' : title,
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  message.isEmpty
                                      ? 'Current status: $status'
                                      : '$message\nStatus: $status',
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  final selected = Map<String, dynamic>.from(item);
                                  Navigator.pop(context);
                                  Future.delayed(const Duration(milliseconds: 120), () {
                                    if (!mounted) return;
                                    Navigator.push(
                                      this.context,
                                      MaterialPageRoute(
                                        builder: (context) => UserNotificationsPage(
                                          userEmail: widget.userEmail,
                                          initialNotification: selected,
                                        ),
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _filterLists() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredCustomers = customers.where((customer) {
        final name = _getCustomerName(customer).toLowerCase();
        final email = _getCustomerEmail(customer).toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
      filteredComplaints = complaints.where((complaint) {
        final title = _getComplaintTitle(complaint).toLowerCase();
        final platform = _getComplaintPlatform(complaint).toLowerCase();
        return title.contains(query) || platform.contains(query);
      }).toList();
    });
  }

  String _getCustomerName(dynamic customer) {
    if (customer is Map && customer['name'] != null) {
      return customer['name'].toString();
    }
    return customer?.toString() ?? '';
  }

  String _getCustomerEmail(dynamic customer) {
    if (customer is Map && customer['email'] != null) {
      return customer['email'].toString();
    }
    return '';
  }

  String _getComplaintTitle(dynamic complaint) {
    if (complaint is Map && complaint['title'] != null) {
      return complaint['title'].toString();
    }
    return complaint?.toString() ?? '';
  }

  String _getComplaintPlatform(dynamic complaint) {
    if (complaint is Map && complaint['platform'] != null) {
      return complaint['platform'].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Refresh Dashboard',
            onPressed: _refreshDashboard,
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () async {
              await _loadNotifications();
              if (!mounted) return;
              _showNotificationsSheet();
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, size: 28),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : _unreadNotificationCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(userEmail: widget.userEmail),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFFF6B6B),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C63FF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Customers',
                          customers.length.toString(),
                          Icons.people,
                          const Color(0xFF6C63FF),
                        ),
                        _buildStatCard(
                          'Complaints',
                          complaints.length.toString(),
                          Icons.warning_amber_rounded,
                          const Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          'Analytics',
                          Icons.analytics,
                          const Color(0xFF00D4FF),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AnalyticsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Status',
                          Icons.list_alt,
                          const Color(0xFFFFA500),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ComplaintStatusScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Search & Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search customers or complaints...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Customers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredCustomers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No customers found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0FF)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredCustomers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 0),
                          itemBuilder: (context, index) {
                            return Container(
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF5F5FF),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6C63FF,
                                    ).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF6C63FF),
                                  ),
                                ),
                                title: Text(
                                  _getCustomerName(filteredCustomers[index]),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      customers.remove(
                                        filteredCustomers[index],
                                      );
                                      _filterLists();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 28),
                    const Text(
                      'Complaints',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredComplaints.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.done_all,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No complaints found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0FF)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredComplaints.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 0),
                          itemBuilder: (context, index) {
                            return Container(
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF5F5FF),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                ),
                                title: Text(
                                  _getComplaintTitle(filteredComplaints[index]),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      complaints.remove(
                                        filteredComplaints[index],
                                      );
                                      _filterLists();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_complaint',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddComplaintScreen(userEmail: widget.userEmail),
                ),
              );
              if (result != null) {
                await _loadData();
              }
            },
            tooltip: 'Add Complaint',
            child: const Icon(Icons.warning_amber_rounded),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_customer',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddCustomerScreen(userEmail: widget.userEmail),
                ),
              );
              if (result != null) {
                await _loadData();
              }
            },
            tooltip: 'Add Customer',
            child: const Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
