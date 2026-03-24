import 'dart:async';

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_notifications_page.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> users = [];
  List<dynamic> complaints = [];
  List<dynamic> filteredComplaints = [];
  List<dynamic> _notifications = [];
  int _unreadNotificationCount = 0;
  final TextEditingController _complaintSearchController =
      TextEditingController();
  String _statusFilter = 'All';
  bool _isLoadingUsers = true;
  bool _isLoadingComplaints = true;
  Timer? _notificationTimer;

  bool get _isLoading => _isLoadingUsers || _isLoadingComplaints;

  @override
  void initState() {
    super.initState();
    _complaintSearchController.addListener(_applyComplaintFilters);
    _loadUsers();
    _loadComplaints();
    _loadNotifications();
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadNotifications(),
    );
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoadingUsers = true;
      _isLoadingComplaints = true;
    });
    await Future.wait([_loadUsers(), _loadComplaints(), _loadNotifications()]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard refreshed'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  Future<void> _loadUsers() async {
    final data = await ApiService.getAllUsers();

    if (mounted) {
      setState(() {
        users = data;
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _loadComplaints() async {
    final data = await ApiService.getComplaints();

    if (mounted) {
      setState(() {
        complaints = data;
        filteredComplaints = data;
        _isLoadingComplaints = false;
      });
      _applyComplaintFilters();
    }
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
      recipientType: 'Admin',
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
    await ApiService.markAllNotificationsRead(recipientType: 'Admin');
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
                        'Notifications',
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
                        ? const Center(child: Text('No notifications yet'))
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
                                      ? 'Status updated to $status'
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
                                        builder: (context) =>
                                            AdminNotificationsPage(
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

  void _applyComplaintFilters() {
    final query = _complaintSearchController.text.toLowerCase();

    setState(() {
      filteredComplaints = complaints.where((complaint) {
        final title = (complaint['title'] ?? '').toString().toLowerCase();
        final category = (complaint['category'] ?? '').toString().toLowerCase();
        final productCategory = (complaint['productCategory'] ?? '')
            .toString()
            .toLowerCase();
        final submittedBy = (complaint['submittedBy'] ?? '')
            .toString()
            .toLowerCase();
        final status = _normalizeStatus(
          (complaint['status'] ?? '').toString(),
        );

        final matchesQuery =
            query.isEmpty ||
            title.contains(query) ||
            category.contains(query) ||
            productCategory.contains(query) ||
            submittedBy.contains(query);
        final matchesStatus = _statusFilter == 'All' || status == _statusFilter;

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _addUser(String name, String email, String role) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adding user...'),
        backgroundColor: Color(0xFF6C63FF),
      ),
    );

    final response = await ApiService.addUser({
      'name': name,
      'email': email,
      'role': role,
      'password': 'temp123', // Default password
    });

    if (mounted) {
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to add user'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added successfully!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        _loadUsers(); // Reload the data
      }
    }
  }

  void _deleteUser(String userId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting user...'),
        backgroundColor: Color(0xFF6C63FF),
      ),
    );

    final success = await ApiService.deleteUser(userId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        _loadUsers(); // Reload the data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete user'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  void _updateUserStatus(String userId, String status) async {
    final response = await ApiService.updateUser(userId, {'status': status});

    if (mounted) {
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to update user'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User set to $status'),
            backgroundColor: const Color(0xFF00C853),
          ),
        );
        _loadUsers();
      }
    }
  }

  Future<void> _updateComplaint(
    String complaintId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.updateComplaint(complaintId, data);

    if (mounted) {
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to update complaint'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint updated'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        _loadComplaints();
      }
    }
  }

  Future<void> _assignComplaint(String complaintId, String assignee) async {
    await _updateComplaint(complaintId, {'assignedTo': assignee});
  }

  Future<void> _addCommentToComplaint(
    String complaintId,
    String comment,
  ) async {
    await _updateComplaint(complaintId, {
      'comment': comment,
      'commentAuthor': 'Admin',
    });
  }

  void _showAddCommentDialog(String complaintId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write internal update or note',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              _addCommentToComplaint(complaintId, text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showComplaintHistory(Map<String, dynamic> complaint) {
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
                  const Text('No history available')
                else
                  ...history.map((item) {
                    final from = (item['from'] ?? '').toString();
                    final to = (item['to'] ?? '').toString();
                    final changedBy = (item['changedBy'] ?? 'System')
                        .toString();
                    final changedAt = (item['changedAt'] ?? '').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('$from -> $to by $changedBy at $changedAt'),
                    );
                  }),
                const SizedBox(height: 16),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (comments.isEmpty)
                  const Text('No comments available')
                else
                  ...comments.map((item) {
                    final message = (item['message'] ?? '').toString();
                    final author = (item['author'] ?? 'Admin').toString();
                    final createdAt = (item['createdAt'] ?? '').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('$author: $message ($createdAt)'),
                    );
                  }),
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

  void _deleteComplaint(String complaintId) async {
    final success = await ApiService.deleteComplaint(complaintId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint deleted'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        _loadComplaints();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete complaint'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                const Icon(Icons.notifications_none),
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
            icon: const Icon(Icons.logout),
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
                              Icons.admin_panel_settings,
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
                                  'Admin Control Panel',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage users and system',
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
                      'System Overview',
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
                        _buildOverviewCard(
                          'Total Users',
                          users.length.toString(),
                          Icons.people,
                          const Color(0xFF6C63FF),
                        ),
                        _buildOverviewCard(
                          'Active Users',
                          users
                              .where((u) => u['status'] == 'Active')
                              .length
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
                        _buildOverviewCard(
                          'Agents',
                          users
                              .where((u) => u['role'] == 'Agent')
                              .length
                              .toString(),
                          Icons.person,
                          const Color(0xFFFFA500),
                        ),
                        _buildOverviewCard(
                          'Managers',
                          users
                              .where((u) => u['role'] == 'Manager')
                              .length
                              .toString(),
                          Icons.shield,
                          const Color(0xFF00D4FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddUserDialog();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add User'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserCard(user, index);
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Complaint Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _complaintSearchController,
                      decoration: const InputDecoration(
                        hintText:
                            'Search complaints, category, product category...',
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
                        _applyComplaintFilters();
                      },
                    ),
                    const SizedBox(height: 16),
                    filteredComplaints.isEmpty
                        ? const Text(
                            'No complaints found.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredComplaints.length,
                            itemBuilder: (context, index) {
                              final complaint = filteredComplaints[index];
                              return _buildComplaintCard(complaint, index);
                            },
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingOption(
                      'Backup Database',
                      'Create system backup',
                      Icons.backup,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Database backup initiated...'),
                            backgroundColor: Color(0xFF00C853),
                          ),
                        );
                      },
                    ),
                    _buildSettingOption(
                      'Security Settings',
                      'Configure security options',
                      Icons.security,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Security settings opened'),
                            backgroundColor: Color(0xFF6C63FF),
                          ),
                        );
                      },
                    ),
                    _buildSettingOption(
                      'Activity Logs',
                      'View system activity',
                      Icons.history,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Activity logs loaded'),
                            backgroundColor: Color(0xFF00D4FF),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
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

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user['role'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user['status'] == 'Active'
                            ? const Color(0xFF00C853).withValues(alpha: 0.2)
                            : const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user['status'],
                        style: TextStyle(
                          fontSize: 11,
                          color: user['status'] == 'Active'
                              ? const Color(0xFF00C853)
                              : const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit ${user['name']}'),
                      backgroundColor: const Color(0xFF6C63FF),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: Text(
                  user['status'] == 'Active' ? 'Deactivate' : 'Activate',
                ),
                onTap: () {
                  final nextStatus = user['status'] == 'Active'
                      ? 'Inactive'
                      : 'Active';
                  _updateUserStatus(user['_id'] ?? user['id'], nextStatus);
                },
              ),
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () {
                  _deleteUser(user['_id'] ?? user['id']);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint, int index) {
    final complaintId = complaint['_id'] ?? complaint['id'];
    final status = _normalizeStatus((complaint['status'] ?? 'Opened').toString());
    final priority = complaint['priority'] ?? 'Medium';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.report_problem, color: Color(0xFF00D4FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint['title'] ?? 'Untitled Complaint',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${complaint['category'] ?? 'Unknown'} • ${complaint['platform'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Product: ${complaint['productCategory'] ?? 'General'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submitted by: ${complaint['submittedBy'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Assigned to: ${(complaint['assignedTo'] ?? '').toString().isEmpty ? 'Unassigned' : complaint['assignedTo']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA500).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFFA500),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isSlaOverdue(complaint))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SLA Overdue',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (complaintId == null) return;

              if (value.startsWith('status:')) {
                final nextStatus = value.split(':')[1];
                _updateComplaint(complaintId, {
                  'status': nextStatus,
                  'changedBy': 'Admin',
                });
              } else if (value.startsWith('priority:')) {
                final nextPriority = value.split(':')[1];
                _updateComplaint(complaintId, {'priority': nextPriority});
              } else if (value.startsWith('assign:')) {
                final nextAssignee = value.split(':')[1];
                _assignComplaint(complaintId, nextAssignee);
              } else if (value == 'comment') {
                _showAddCommentDialog(complaintId);
              } else if (value == 'timeline') {
                _showComplaintHistory(complaint);
              } else if (value == 'delete') {
                _deleteComplaint(complaintId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'status:Opened',
                child: Text('Status: Opened'),
              ),
              const PopupMenuItem(
                value: 'status:In-progress',
                child: Text('Status: In-progress'),
              ),
              const PopupMenuItem(
                value: 'status:Solved',
                child: Text('Status: Solved'),
              ),
              const PopupMenuItem(
                value: 'status:Rejected',
                child: Text('Status: Rejected'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'priority:High',
                child: Text('Priority: High'),
              ),
              const PopupMenuItem(
                value: 'priority:Medium',
                child: Text('Priority: Medium'),
              ),
              const PopupMenuItem(
                value: 'priority:Low',
                child: Text('Priority: Low'),
              ),
              const PopupMenuDivider(),
              ...users
                  .where((user) {
                    final role = (user['role'] ?? '').toString();
                    return role == 'Agent' || role == 'Manager';
                  })
                  .map(
                    (user) => PopupMenuItem(
                      value: 'assign:${user['email']}',
                      child: Text('Assign: ${user['name']}'),
                    ),
                  ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'comment', child: Text('Add Comment')),
              const PopupMenuItem(
                value: 'timeline',
                child: Text('View Timeline'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSlaOverdue(Map<String, dynamic> complaint) {
    final status = _normalizeStatus((complaint['status'] ?? 'Opened').toString());
    if (status == 'Solved' || status == 'Rejected') {
      return false;
    }

    final createdRaw = complaint['createdAt'];
    if (createdRaw == null) {
      return false;
    }

    final createdAt = DateTime.tryParse(createdRaw.toString());
    if (createdAt == null) {
      return false;
    }

    final priority = (complaint['priority'] ?? 'Medium').toString();
    final slaHours = switch (priority) {
      'High' => 24,
      'Low' => 72,
      _ => 48,
    };

    final dueAt = createdAt.add(Duration(hours: slaHours));
    return DateTime.now().isAfter(dueAt);
  }

  Widget _buildSettingOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Agent';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['Agent', 'Manager', 'Admin']
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedRole = value ?? 'Agent';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                Navigator.pop(context);
                _addUser(
                  nameController.text,
                  emailController.text,
                  selectedRole,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Color(0xFFFF6B6B),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _complaintSearchController.dispose();
    super.dispose();
  }
}
