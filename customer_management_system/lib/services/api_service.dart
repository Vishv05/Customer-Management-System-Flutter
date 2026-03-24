import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class ApiService {
  // ============ AUTH ENDPOINTS ============

  // Register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ============ USER ENDPOINTS ============

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to fetch profile'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
      String email, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/users/$email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to update profile'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Get all users (admin)
  static Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['users'] != null) {
          return data['users'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Add new user (admin)
  static Future<Map<String, dynamic>> addUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to add user'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Delete user
  static Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update user (admin)
  static Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Failed to update user'};
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // ============ CUSTOMER ENDPOINTS ============

  // Get all customers
  static Future<List<dynamic>> getCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true &&  data['customers'] != null) {
          return data['customers'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Add new customer
  static Future<Map<String, dynamic>> addCustomer(
      Map<String, dynamic> customerData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to add customer'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Update customer
  static Future<Map<String, dynamic>> updateCustomer(
      String customerId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/customers/$customerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to update customer'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Delete customer
  static Future<bool> deleteCustomer(String customerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/customers/$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ COMPLAINT ENDPOINTS ============

  // Get all complaints
  static Future<List<dynamic>> getComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/complaints'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['complaints'] != null) {
          return data['complaints'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getComplaintById(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/complaints/$complaintId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['complaint'] != null) {
          return data['complaint'] as Map<String, dynamic>;
        }
      }

      return {'error': 'Complaint not found'};
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Add new complaint
  static Future<Map<String, dynamic>> addComplaint(
      Map<String, dynamic> complaintData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/complaints'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(complaintData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        return {
          'error': data['message'] ?? 'Failed to add complaint',
        };
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Update complaint
  static Future<Map<String, dynamic>> updateComplaint(
      String complaintId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/complaints/$complaintId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to update complaint'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // Update complaint status
  static Future<Map<String, dynamic>> updateComplaintStatus(
      String complaintId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/complaints/$complaintId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Delete complaint
  static Future<bool> deleteComplaint(String complaintId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/complaints/$complaintId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get analytics data
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/complaints/analytics/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  // ============ NOTIFICATION ENDPOINTS ============

  static Future<Map<String, dynamic>> getNotifications({
    required String recipientType,
    String recipientEmail = '',
    bool onlyUnread = false,
    int limit = 50,
  }) async {
    try {
      final query = <String, String>{
        'recipientType': recipientType,
        'onlyUnread': onlyUnread.toString(),
        'limit': limit.toString(),
      };

      if (recipientType == 'User' && recipientEmail.trim().isNotEmpty) {
        query['recipientEmail'] = recipientEmail.trim().toLowerCase();
      }

      final uri = Uri.parse(
        '$apiBaseUrl/notifications',
      ).replace(queryParameters: query);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {'success': false, 'message': 'Failed to fetch notifications'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead(
    String notificationId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {'success': false, 'message': 'Failed to mark notification read'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead({
    required String recipientType,
    String recipientEmail = '',
  }) async {
    try {
      final body = <String, dynamic>{
        'recipientType': recipientType,
      };

      if (recipientType == 'User' && recipientEmail.trim().isNotEmpty) {
        body['recipientEmail'] = recipientEmail.trim().toLowerCase();
      }

      final response = await http.patch(
        Uri.parse('$apiBaseUrl/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Failed to mark all notifications as read',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
