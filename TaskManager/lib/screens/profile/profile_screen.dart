import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final res = await AuthService.getProfile();
    if (res['user'] != null) {
      setState(() {
        _nameController.text = res['user']['fullName'] ?? '';
        _email = res['user']['email'] ?? '';
        _isLoading = false;
      });
    }
  }

  void _updateProfile() async {
    final res = await AuthService.updateProfile(fullName: _nameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Cập nhật thành công!')),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
            ),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final res = await AuthService.changePassword(
                oldPassword: _oldPassController.text,
                newPassword: _newPassController.text,
              );
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Đổi mật khẩu hoàn tất')),
                );
                _oldPassController.clear();
                _newPassController.clear();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Email: $_email', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Cập nhật thông tin'),
            ),
            const Divider(height: 40),
            OutlinedButton(
              onPressed: _showChangePasswordDialog,
              child: const Text('Đổi mật khẩu'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}