import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AdminProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _stats = {'user': 0, 'teknisi': 0, 'admin': 0};

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get stats => _stats;

  /// Fetch all users from public.users table
  Future<void> fetchAllUsers() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      _users = (response as List).map((json) => UserModel.fromJson(json)).toList();
      _calculateStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar user: $e';
      debugPrint('AdminProvider fetchAllUsers error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate stats locally from fetched users
  void _calculateStats() {
    final Map<String, int> newStats = {'user': 0, 'teknisi': 0, 'admin': 0};
    for (var user in _users) {
      if (newStats.containsKey(user.role)) {
        newStats[user.role] = (newStats[user.role] ?? 0) + 1;
      }
    }
    _stats = newStats;
  }

  /// Update user data (Name, Role, Phone, and optional Password)
  Future<bool> updateUser(UserModel user, {String? newPassword}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // 1. Update basic profile info in public.users
      await _supabase.from('users').update({
        'name': user.name,
        'role': user.role,
        'phone': user.phone,
      }).eq('id', user.id);

      // 2. Update password via Edge Function if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        final response = await _supabase.functions.invoke(
          'admin-manager',
          body: {
            'action': 'update-password',
            'targetUserId': user.id,
            'payload': {'password': newPassword},
          },
        );

        if (response.status != 200) {
          throw 'Gagal reset password: ${response.data['error'] ?? 'Unknown error'}';
        }
      }
      
      await fetchAllUsers(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Gagal update user: $e';
      debugPrint('AdminProvider updateUser error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user securely (Auth + Public DB)
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Call Edge Function to delete from auth.users (cascades to public.users)
      final response = await _supabase.functions.invoke(
        'admin-manager',
        body: {
          'action': 'delete-user',
          'targetUserId': userId,
          'payload': {},
        },
      );

      if (response.status != 200) {
        throw response.data['error'] ?? 'Gagal menghapus user dari sistem';
      }
      
      await fetchAllUsers(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Gagal hapus user: $e';
      debugPrint('AdminProvider deleteUser error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
