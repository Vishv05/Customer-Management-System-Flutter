import 'package:flutter/material.dart';

import '../services/api_service.dart';

class UserNotificationsPage extends StatefulWidget {
  final String userEmail;
  final Map<String, dynamic>? initialNotification;

  const UserNotificationsPage({
    super.key,
    required this.userEmail,
    this.initialNotification,
  });

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedNotification;
  Map<String, dynamic>? _selectedComplaint;
  bool _isSelectingNotification = false;
  bool _initialNotificationHandled = false;

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
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_notifications.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    final response = await ApiService.getNotifications(
      recipientType: 'User',
      recipientEmail: widget.userEmail,
      limit: 200,
    );

    if (!mounted) return;

    final notifications = (response['notifications'] as List<dynamic>?) ?? [];

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });

    final initial = widget.initialNotification;
    if (!_initialNotificationHandled && initial != null) {
      _initialNotificationHandled = true;
      final initialId = (initial['_id'] ?? '').toString();
      Map<String, dynamic> target = initial;
      if (initialId.isNotEmpty) {
        for (final item in _notifications) {
          final map = item as Map<String, dynamic>;
          if ((map['_id'] ?? '').toString() == initialId) {
            target = map;
            break;
          }
        }
      }
      await _selectNotification(target);
      return;
    }

    if (_selectedNotification != null) {
      final selectedId = (_selectedNotification!['_id'] ?? '').toString();
      if (selectedId.isNotEmpty) {
        for (final item in _notifications) {
          final map = item as Map<String, dynamic>;
          if ((map['_id'] ?? '').toString() == selectedId) {
            _selectedNotification = map;
            break;
          }
        }
      }
    }

    if (_notifications.isNotEmpty && _selectedNotification == null) {
      await _selectNotification(_notifications.first as Map<String, dynamic>);
    }
  }

  Future<void> _selectNotification(Map<String, dynamic> notification) async {
    if (_isSelectingNotification) return;

    final complaintId = (notification['complaintId'] ?? '').toString();
    final notificationId = (notification['_id'] ?? '').toString();
    final selectedId = (_selectedNotification?['_id'] ?? '').toString();
    if (selectedId.isNotEmpty && selectedId == notificationId && _selectedComplaint != null) {
      return;
    }

    final shouldMarkRead =
        notificationId.isNotEmpty && notification['read'] != true;

    _isSelectingNotification = true;

    setState(() {
      _selectedNotification = notification;
    });

    if (shouldMarkRead) {
      await ApiService.markNotificationRead(notificationId);
      if (!mounted) return;
      setState(() {
        _notifications = _notifications.map((item) {
          final map = item as Map<String, dynamic>;
          if ((map['_id'] ?? '').toString() == notificationId) {
            return {
              ...map,
              'read': true,
            };
          }
          return map;
        }).toList();
        _selectedNotification = {
          ...notification,
          'read': true,
        };
      });
    }

    if (complaintId.isEmpty) {
      setState(() {
        _selectedComplaint = {'error': 'Complaint id not found for this item'};
      });
      _isSelectingNotification = false;
      return;
    }

    final complaint = await ApiService.getComplaintById(complaintId);

    if (!mounted) {
      _isSelectingNotification = false;
      return;
    }

    setState(() {
      _selectedComplaint = complaint;
    });

    _isSelectingNotification = false;
  }

  Future<void> _markAllRead() async {
    await ApiService.markAllNotificationsRead(
      recipientType: 'User',
      recipientEmail: widget.userEmail,
    );
    await _loadNotifications();
  }

  Widget _buildComplaintDetail() {
    final complaint = _selectedComplaint;
    final notification = _selectedNotification;
    final metadata = (notification?['metadata'] is Map<String, dynamic>)
        ? notification!['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};
    if (complaint == null) {
      return const Center(
        child: Text('Select a notification to view complaint details'),
      );
    }

    if (complaint.containsKey('error')) {
      return Center(
        child: Text(
          complaint['error'].toString(),
          style: const TextStyle(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    final customerName = ((complaint['customerName'] ?? metadata['customerName']) ?? '')
      .toString();
    final customerEmail = ((complaint['customerEmail'] ?? metadata['customerEmail']) ?? widget.userEmail)
      .toString();
    final customerPhone = ((complaint['customerPhone'] ?? metadata['customerPhone']) ?? '')
      .toString();
    final customerAddress = ((complaint['customerAddress'] ?? metadata['customerAddress']) ?? '')
      .toString();
    final previousStatus = (metadata['previousStatus'] ?? '-').toString();
    final changedBy = (metadata['changedBy'] ?? 'Admin').toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (complaint['title'] ?? 'Complaint Details').toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Status: ${_normalizeStatus((complaint['status'] ?? '-').toString())}'),
          Text('Previous Status: ${_normalizeStatus(previousStatus)}'),
          Text('Changed By: $changedBy'),
          Text('Category: ${(complaint['category'] ?? '-').toString()}'),
          Text('Platform: ${(complaint['platform'] ?? '-').toString()}'),
          const SizedBox(height: 12),
          const Text(
            'Customer Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Name: ${customerName.isEmpty ? '-' : customerName}'),
          Text('Email: ${customerEmail.isEmpty ? '-' : customerEmail}'),
          Text('Phone: ${customerPhone.isEmpty ? '-' : customerPhone}'),
          Text('Address: ${customerAddress.isEmpty ? '-' : customerAddress}'),
          const SizedBox(height: 12),
          Text(
            'Description: ${(complaint['description'] ?? '').toString()}',
          ),
          const SizedBox(height: 12),
          const Text(
            'Status Timeline',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...((complaint['statusHistory'] as List<dynamic>? ?? [])
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${_normalizeStatus((item['from'] ?? '-').toString())} -> ${_normalizeStatus((item['to'] ?? '-').toString())} by ${(item['changedBy'] ?? 'System').toString()}',
                  ),
                ),
              )
              .toList()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notifications'),
        actions: [
          IconButton(
            onPressed: _markAllRead,
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
          ),
          IconButton(
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _notifications.isEmpty
                      ? const Center(child: Text('No notifications found'))
                      : ListView.separated(
                          itemCount: _notifications.length,
                            separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _notifications[index]
                                as Map<String, dynamic>;
                            final selected =
                                (_selectedNotification?['_id']?.toString() ?? '') ==
                                    (item['_id']?.toString() ?? '');

                            return ListTile(
                              selected: selected,
                              leading: Icon(
                                item['read'] == true
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: item['read'] == true
                                    ? Colors.grey
                                    : const Color(0xFF6C63FF),
                              ),
                              title: Text(
                                (item['complaintTitle'] ?? 'Complaint Update')
                                    .toString(),
                              ),
                              subtitle: Text((item['message'] ?? '').toString()),
                              trailing: Text(
                                _normalizeStatus(
                                  (item['complaintStatus'] ?? '').toString(),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => _selectNotification(item),
                            );
                          },
                        ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildComplaintDetail(),
                  ),
                ),
              ],
            ),
    );
  }
}
