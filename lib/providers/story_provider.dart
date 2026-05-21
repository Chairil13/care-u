import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<StoryModel> _stories = [];
  List<String> _viewedStoryIds = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  RealtimeChannel? _storyChannel;

  List<StoryModel> get stories => _stories;
  List<String> get viewedStoryIds => _viewedStoryIds;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  StoryProvider() {
    fetchStories();
    _subscribeToStoriesRealtime();
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = null;
    
    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24)).toUtc().toIso8601String();
      
      final response = await _supabase
          .from('stories')
          .select('*, users(*)')
          .gt('created_at', cutoff)
          .order('created_at', ascending: false);

      _stories = (response as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      final user = _supabase.auth.currentUser;
      if (user != null) {
        final viewsResponse = await _supabase
            .from('story_views')
            .select('story_id')
            .eq('user_id', user.id);
        _viewedStoryIds = (viewsResponse as List)
            .map((view) => view['story_id'] as String)
            .toList();
      } else {
        _viewedStoryIds = [];
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat stories: $e';
      debugPrint('Error fetching stories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToStoriesRealtime() {
    _storyChannel = _supabase
        .channel('public:stories')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stories',
          callback: (payload) {
            debugPrint('StoryProvider: Received stories change payload: ${payload.toString()}');
            fetchStories();
          },
        )
        .subscribe();
  }

  Future<bool> uploadStory({
    required Uint8List mediaBytes,
    required String fileName,
    String? caption,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _errorMessage = 'User belum login';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload to Supabase Storage in 'avatars' bucket, path: userId/stories/timestamp_filename
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
      final path = '${user.id}/stories/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

      await _supabase.storage.from('avatars').uploadBinary(
        path,
        mediaBytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      final mediaUrl = _supabase.storage.from('avatars').getPublicUrl(path);

      // 2. Insert into public.stories table
      await _supabase.from('stories').insert({
        'user_id': user.id,
        'media_url': mediaUrl,
        'caption': caption,
      });

      // Fetch immediately to update UI faster
      await fetchStories();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengunggah story: $e';
      debugPrint('Error uploading story: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStory(String storyId, String mediaUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Delete from public.stories table
      await _supabase.from('stories').delete().eq('id', storyId);

      // 2. Try to delete the file from storage
      try {
        final uri = Uri.parse(mediaUrl);
        final pathSegments = uri.pathSegments;
        final avatarsIndex = pathSegments.indexOf('avatars');
        if (avatarsIndex != -1 && avatarsIndex + 1 < pathSegments.length) {
          final storagePath = pathSegments.sublist(avatarsIndex + 1).join('/');
          await _supabase.storage.from('avatars').remove([storagePath]);
        }
      } catch (storageError) {
        debugPrint('Error removing story file from storage: $storageError');
      }

      await fetchStories();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus story: $e';
      debugPrint('Error deleting story: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markStoryAsViewed(String storyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Optimistic update
    if (!_viewedStoryIds.contains(storyId)) {
      _viewedStoryIds.add(storyId);
      notifyListeners();
    }

    try {
      await _supabase.from('story_views').upsert({
        'story_id': storyId,
        'user_id': user.id,
      });
    } catch (e) {
      debugPrint('Error marking story as viewed in database: $e');
      // If it failed and we added it optimistically, we could revert if needed,
      // but typically we can keep it local for immediate UX and let the next sync correct it.
    }
  }

  Future<List<UserModel>> fetchStoryViews(String storyId) async {
    try {
      final response = await _supabase
          .from('story_views')
          .select('users (*)')
          .eq('story_id', storyId);

      final List<dynamic> data = response as List<dynamic>;
      final List<UserModel> viewers = [];
      final currentUserId = _supabase.auth.currentUser?.id;
      for (final item in data) {
        if (item['users'] != null) {
          final viewer = UserModel.fromJson(item['users'] as Map<String, dynamic>);
          if (viewer.id != currentUserId) {
            viewers.add(viewer);
          }
        }
      }
      return viewers;
    } catch (e) {
      debugPrint('Error fetching story views: $e');
      return [];
    }
  }

  @override
  void dispose() {
    if (_storyChannel != null) {
      _supabase.removeChannel(_storyChannel!);
    }
    super.dispose();
  }
}
