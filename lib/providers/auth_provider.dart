import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        try {
          await _fetchUserProfile(session.user.id);
        } catch (e) {
          debugPrint('Auth listener: error fetching profile: $e');
          _currentUser = null;
          notifyListeners();
        }
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      } else {
        // If profile doesn't exist in public.users, create it from auth metadata
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final metadata = user.userMetadata ?? {};
          _currentUser = UserModel(
            id: user.id,
            name: metadata['name'] ?? 'User',
            email: user.email ?? '',
            role: metadata['role'] ?? 'user',
            phone: metadata['phone'] ?? '',
          );

          // Try to sync to public.users in the background
          _supabase.from('users').upsert({
            'id': _currentUser!.id,
            'name': _currentUser!.name,
            'email': _currentUser!.email,
            'role': _currentUser!.role,
            'phone': _currentUser!.phone,
            'avatar_url': _currentUser!.avatarUrl,
          }).then((_) => debugPrint('Profile synced to public.users'));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Cek apakah user sudah login sebelumnya (persistent session)
  Future<void> checkCurrentSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        await _fetchUserProfile(session.user.id);
      } catch (e) {
        debugPrint('checkCurrentSession: error fetching profile: $e');
        // Session ada tapi profil tidak bisa diambil, abaikan
        _currentUser = null;
        notifyListeners();
      }
    }
  }

  /// Register user (role: user | teknisi)
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'user',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role, 'phone': phone ?? ''},
      );

      if (authResponse.user == null) {
        _errorMessage = 'Registrasi gagal. Coba lagi.';
        return false;
      }

      _currentUser = UserModel(
        id: authResponse.user!.id,
        name: name,
        email: email,
        role: role,
        phone: phone,
      );

      // Sync to public.users table immediately
      await _supabase.from('users').upsert({
        'id': _currentUser!.id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone ?? '',
        'avatar_url': null,
      });

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      return false;
    } on PostgrestException catch (e) {
      _errorMessage = 'Gagal menyimpan profil: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login semua role
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        _errorMessage = 'Login gagal. Periksa email dan password.';
        return false;
      }

      await _fetchUserProfile(authResponse.user!.id);
      if (_currentUser == null) {
        _errorMessage = 'Profil pengguna tidak ditemukan. Hubungi admin.';
        // Logout agar session tidak menggantung
        await _supabase.auth.signOut();
        return false;
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      return false;
    } on PostgrestException catch (e) {
      _errorMessage = 'Gagal memuat profil: ${e.message}';
      // Logout agar session tidak menggantung
      await _supabase.auth.signOut();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> signOut() async {
    _setLoading(true);
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        try {
          // Hapus FCM token dari database Supabase sebelum logout (agar RLS masih mengizinkan update)
          await _supabase
              .from('users')
              .update({'fcm_token': null})
              .eq('id', currentUserId);
          
          // Hapus token lokal dari Firebase
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            await FirebaseMessaging.instance.deleteToken();
          }
          debugPrint('FCM Token cleared successfully during logout');
        } catch (e) {
          debugPrint('Error clearing FCM Token during logout: $e');
        }
      }

      await _supabase.auth.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _parseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    } else if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox email Anda.';
    } else if (message.contains('User already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (message.contains('Password should be at least')) {
      return 'Password minimal 6 karakter.';
    } else if (message.contains('Unable to validate email address')) {
      return 'Format email tidak valid.';
    }
    return message;
  }

  /// Update Profile (Name, Email, Phone)
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. Update Auth Email if changed
      if (email != _currentUser!.email) {
        await _supabase.auth.updateUser(UserAttributes(email: email));
      }

      // 2. Update Auth Metadata
      await _supabase.auth.updateUser(
        UserAttributes(data: {'name': name, 'phone': phone}),
      );

      // 3. Update public.users table (optional if handled by trigger, but just in case)
      await _supabase.from('users').upsert({
        'id': _currentUser!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': _currentUser!.role,
        'avatar_url': _currentUser!.avatarUrl,
      });

      // 4. Refresh Profile
      await _fetchUserProfile(_currentUser!.id);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      return false;
    } on PostgrestException catch (e) {
      _errorMessage = 'Gagal menyimpan profil: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat update profil.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update Password
  Future<bool> updatePassword({required String newPassword}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } on AuthException catch (e) {
      _errorMessage = _parseAuthError(e.message);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat update password.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload Avatar
  Future<bool> uploadAvatar(File imageFile) async {
    if (_currentUser == null) return false;
    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _currentUser!.id;
      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatar_$userId$fileExt';
      final filePath = '$userId/$fileName';

      // 1. Upload to Supabase Storage
      await _supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Get Public URL
      final avatarUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // 3. Update public.users table
      await _supabase.from('users').update({
        'avatar_url': avatarUrl,
      }).eq('id', userId);

      // 4. Refresh Profile
      await _fetchUserProfile(userId);
      return true;
    } on StorageException catch (e) {
      _errorMessage = 'Gagal upload file: ${e.message}';
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat upload foto.';
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
