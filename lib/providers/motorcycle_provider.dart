import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/motorcycle_model.dart';

class MotorcycleProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<MotorcycleModel> _motorcycles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MotorcycleModel> get motorcycles => _motorcycles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all motorcycles for the current user
  Future<void> fetchMotorcycles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('motorcycles')
          .select()
          .eq('user_id', user.id)
          .order('created_at');

      _motorcycles = (response as List)
          .map((json) => MotorcycleModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch motorcycles: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload motorcycle image helper
  Future<String?> uploadMotorcycleImage(File file) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final fileName = 'bike_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${user.id}/motorcycles/$fileName';
      
      await _supabase.storage.from('avatars').upload(
        path,
        file,
        fileOptions: const FileOptions(
          upsert: true,
        ),
      );

      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      _errorMessage = 'Failed to upload image: $e';
      debugPrint(_errorMessage);
      return null;
    }
  }

  /// Add a new motorcycle
  Future<bool> addMotorcycle({
    required String brand,
    required String model,
    required String plateNumber,
    int? year,
    File? imageFile,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadMotorcycleImage(imageFile);
      }

      await _supabase.from('motorcycles').insert({
        'user_id': user.id,
        'brand': brand,
        'model': model,
        'plate_number': plateNumber,
        'year': year,
        'image_url': imageUrl,
      });
      
      await fetchMotorcycles();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add motorcycle: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing motorcycle
  Future<bool> updateMotorcycle(MotorcycleModel motorcycle, {File? imageFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      MotorcycleModel updatedMotorcycle = motorcycle;
      if (imageFile != null) {
        final imageUrl = await uploadMotorcycleImage(imageFile);
        if (imageUrl != null) {
          updatedMotorcycle = motorcycle.copyWith(imageUrl: imageUrl);
        }
      }

      await _supabase
          .from('motorcycles')
          .update(updatedMotorcycle.toJson())
          .eq('id', updatedMotorcycle.id);
      
      await fetchMotorcycles();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update motorcycle: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a motorcycle
  Future<bool> deleteMotorcycle(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.from('motorcycles').delete().eq('id', id);
      await fetchMotorcycles();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete motorcycle: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
