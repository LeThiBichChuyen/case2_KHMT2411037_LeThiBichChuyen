import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // IP 10.0.2.2 giúp máy ảo Android truy cập localhost máy tính
  static const String baseUrl = 'http://10.0.2.2:3000/api/auth';
  static String? token;

  // 1. Đăng ký tài khoản
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  // 2. Đăng nhập
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        token = data['token'];
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  // 3. Xem thông tin cá nhân
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi tải thông tin cá nhân'};
    }
  }

  // 4. Cập nhật thông tin cá nhân
  static Future<Map<String, dynamic>> updateProfile({required String fullName}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fullName': fullName}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Cập nhật thất bại'};
    }
  }

  // 5. Đổi mật khẩu
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Đổi mật khẩu thất bại'};
    }
  }

  // 6. Đăng xuất
  static void logout() {
    token = null;
  }
}