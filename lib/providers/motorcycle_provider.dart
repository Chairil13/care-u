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

  /// Add a new motorcycle
  Future<bool> addMotorcycle({
    required String brand,
    required String model,
    required String plateNumber,
    int? year,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('motorcycles').insert({
        'user_id': user.id,
        'brand': brand,
        'model': model,
        'plate_number': plateNumber,
        'year': year,
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
  Future<bool> updateMotorcycle(MotorcycleModel motorcycle) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from('motorcycles')
          .update(motorcycle.toJson())
          .eq('id', motorcycle.id);
      
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
