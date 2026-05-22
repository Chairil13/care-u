import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class StoryProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<StoryModel> _stories = [];
  List<StoryModel> _posts = [];
  List<String> _viewedStoryIds = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  RealtimeChannel? _storyChannel;

  // Like & comment state
  final Map<String, int> _likeCounts = {};
  final Map<String, bool> _likedByMe = {};
  final Map<String, int> _commentCounts = {};
  final Map<String, bool> _likedStories = {};

  // Bookmark state
  final Set<String> _bookmarkedPostIds = {};
  List<StoryModel> _bookmarkedPosts = [];

  Set<String> get bookmarkedPostIds => _bookmarkedPostIds;
  List<StoryModel> get bookmarkedPosts => _bookmarkedPosts;
  bool isBookmarked(String postId) => _bookmarkedPostIds.contains(postId);

  List<StoryModel> get stories => _stories;
  List<StoryModel> get posts => _posts;
  List<String> get viewedStoryIds => _viewedStoryIds;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  int getLikeCount(String storyId) => _likeCounts[storyId] ?? 0;
  bool isLikedByMe(String storyId) => _likedByMe[storyId] ?? false;
  int getCommentCount(String storyId) => _commentCounts[storyId] ?? 0;
  bool isStoryLiked(String storyId) => _likedStories[storyId] ?? false;

  void toggleStoryLike(String storyId) {
    _likedStories[storyId] = !(_likedStories[storyId] ?? false);
    notifyListeners();
  }

  StoryProvider() {
    fetchStories();
    fetchPosts();
    _subscribeToStoriesRealtime();
  }

  void clearData() {
    _stories = [];
    _posts = [];
    _viewedStoryIds = [];
    _likeCounts.clear();
    _likedByMe.clear();
    _commentCounts.clear();
    _likedStories.clear();
    _bookmarkedPostIds.clear();
    _bookmarkedPosts = [];
    notifyListeners();
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

      final allStories = (response as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      // Filter out posts from the stories list
      _stories = allStories.where((story) => !story.isPost).toList();

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

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    
    try {
      final response = await _supabase
          .from('stories')
          .select('*, users(*)')
          .order('created_at', ascending: false);

      final allRecords = (response as List)
          .map((json) => StoryModel.fromJson(json))
          .toList();

      // Only include posts
      _posts = allRecords.where((story) => story.isPost).toList();

      // Fetch like and comment counts for all posts
      await _fetchPostEngagementData();
    } catch (e) {
      _errorMessage = 'Gagal memuat posts: $e';
      debugPrint('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPostEngagementData() async {
    final user = _supabase.auth.currentUser;
    final postIds = _posts.map((p) => p.id).toList();
    if (postIds.isEmpty) return;

    try {
      // Fetch all likes for these posts
      final likesResponse = await _supabase
          .from('post_likes')
          .select('story_id, user_id')
          .inFilter('story_id', postIds);

      // Reset counts for fetched posts
      for (final id in postIds) {
        _likeCounts[id] = 0;
        _likedByMe[id] = false;
      }

      for (final like in (likesResponse as List)) {
        final storyId = like['story_id'] as String;
        _likeCounts[storyId] = (_likeCounts[storyId] ?? 0) + 1;
        if (user != null && like['user_id'] == user.id) {
          _likedByMe[storyId] = true;
        }
      }

      // Fetch comment counts
      final commentsResponse = await _supabase
          .from('post_comments')
          .select('story_id')
          .inFilter('story_id', postIds);

      for (final id in postIds) {
        _commentCounts[id] = 0;
      }

      for (final comment in (commentsResponse as List)) {
        final storyId = comment['story_id'] as String;
        _commentCounts[storyId] = (_commentCounts[storyId] ?? 0) + 1;
      }

      // Fetch bookmarks
      _bookmarkedPostIds.clear();
      if (user != null) {
        final bookmarksResponse = await _supabase
            .from('post_bookmarks')
            .select('story_id')
            .eq('user_id', user.id);
        for (final bookmark in (bookmarksResponse as List)) {
          _bookmarkedPostIds.add(bookmark['story_id'] as String);
        }
      }
    } catch (e) {
      debugPrint('Error fetching post engagement data: $e');
    }
  }

  // ===== LIKE METHODS =====

  Future<void> toggleLike(String storyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final currentlyLiked = _likedByMe[storyId] ?? false;

    // Optimistic update
    _likedByMe[storyId] = !currentlyLiked;
    _likeCounts[storyId] = (_likeCounts[storyId] ?? 0) + (currentlyLiked ? -1 : 1);
    notifyListeners();

    try {
      if (currentlyLiked) {
        // Unlike
        await _supabase
            .from('post_likes')
            .delete()
            .eq('story_id', storyId)
            .eq('user_id', user.id);
      } else {
        // Like
        await _supabase.from('post_likes').insert({
          'story_id': storyId,
          'user_id': user.id,
        });
      }
    } catch (e) {
      // Revert on failure
      _likedByMe[storyId] = currentlyLiked;
      _likeCounts[storyId] = (_likeCounts[storyId] ?? 0) + (currentlyLiked ? 1 : -1);
      notifyListeners();
      debugPrint('Error toggling like: $e');
    }
  }

  // ===== BOOKMARK METHODS =====

  Future<void> toggleBookmark(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final currentlyBookmarked = _bookmarkedPostIds.contains(postId);

    // Optimistic update
    if (currentlyBookmarked) {
      _bookmarkedPostIds.remove(postId);
    } else {
      _bookmarkedPostIds.add(postId);
    }
    notifyListeners();

    try {
      if (currentlyBookmarked) {
        // Remove bookmark
        await _supabase
            .from('post_bookmarks')
            .delete()
            .eq('story_id', postId)
            .eq('user_id', user.id);
      } else {
        // Add bookmark
        await _supabase.from('post_bookmarks').insert({
          'story_id': postId,
          'user_id': user.id,
        });
      }
    } catch (e) {
      // Revert on failure
      if (currentlyBookmarked) {
        _bookmarkedPostIds.add(postId);
      } else {
        _bookmarkedPostIds.remove(postId);
      }
      notifyListeners();
      debugPrint('Error toggling bookmark: $e');
    }
  }

  Future<void> fetchBookmarkedPosts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('post_bookmarks')
          .select('story_id, stories(*, users(*))')
          .eq('user_id', user.id);

      final list = response as List;
      final List<StoryModel> loaded = [];
      for (final item in list) {
        if (item['stories'] != null) {
          loaded.add(StoryModel.fromJson(item['stories']));
        }
      }
      _bookmarkedPosts = loaded;

      // Update local bookmarked IDs set
      _bookmarkedPostIds.clear();
      for (final post in _bookmarkedPosts) {
        _bookmarkedPostIds.add(post.id);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat postingan yang disimpan: $e';
      debugPrint('Error fetching bookmarked posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== COMMENT METHODS =====

  Future<List<CommentModel>> fetchComments(String storyId) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .select('*, users!post_comments_user_id_public_fkey(*)')
          .eq('story_id', storyId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

  Future<bool> addComment(String storyId, String content, {String? parentId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await _supabase.from('post_comments').insert({
        'story_id': storyId,
        'user_id': user.id,
        'content': content,
        'parent_id': parentId,
      });

      // Update local count
      _commentCounts[storyId] = (_commentCounts[storyId] ?? 0) + 1;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> editComment(String commentId, String newContent) async {
    try {
      await _supabase
          .from('post_comments')
          .update({'content': newContent})
          .eq('id', commentId);
      return true;
    } catch (e) {
      debugPrint('Error editing comment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(String commentId, String storyId, {int childCount = 0}) async {
    try {
      await _supabase.from('post_comments').delete().eq('id', commentId);

      // Update local count (parent + children cascade deleted)
      final toRemove = 1 + childCount;
      _commentCounts[storyId] = ((_commentCounts[storyId] ?? toRemove) - toRemove).clamp(0, 999999);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  // ===== POST EDIT =====

  Future<bool> updatePostCaption(String storyId, String newCaption) async {
    try {
      await _supabase
          .from('stories')
          .update({'caption': newCaption})
          .eq('id', storyId);

      // Update local data
      final index = _posts.indexWhere((p) => p.id == storyId);
      if (index != -1) {
        final old = _posts[index];
        _posts[index] = StoryModel(
          id: old.id,
          userId: old.userId,
          mediaUrl: old.mediaUrl,
          caption: newCaption,
          createdAt: old.createdAt,
          userName: old.userName,
          userAvatarUrl: old.userAvatarUrl,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating post caption: $e');
      return false;
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
            fetchPosts();
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

  Future<bool> uploadPost({
    required List<Uint8List> imagesBytes,
    required List<String> fileNames,
    required String description,
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
      final List<String> imageUrls = [];

      for (int i = 0; i < imagesBytes.length; i++) {
        final bytes = imagesBytes[i];
        final fileName = fileNames[i];
        final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
        final path = '${user.id}/posts/${DateTime.now().millisecondsSinceEpoch}_${i}_$cleanFileName';

        await _supabase.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

        final mediaUrl = _supabase.storage.from('avatars').getPublicUrl(path);
        imageUrls.add(mediaUrl);
      }

      final mediaUrlJson = json.encode(imageUrls);

      // Insert into public.stories table
      await _supabase.from('stories').insert({
        'user_id': user.id,
        'media_url': mediaUrlJson,
        'caption': description,
      });

      // Fetch immediately to update UI faster
      await fetchPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengunggah post: $e';
      debugPrint('Error uploading post: $e');
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

      // 2. Try to delete the file(s) from storage
      final List<String> urlsToDelete = [];
      if (mediaUrl.startsWith('[')) {
        try {
          final List<dynamic> decoded = json.decode(mediaUrl);
          urlsToDelete.addAll(decoded.map((e) => e.toString()));
        } catch (_) {}
      } else {
        urlsToDelete.add(mediaUrl);
      }

      for (final url in urlsToDelete) {
        try {
          final uri = Uri.parse(url);
          final pathSegments = uri.pathSegments;
          final avatarsIndex = pathSegments.indexOf('avatars');
          if (avatarsIndex != -1 && avatarsIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments.sublist(avatarsIndex + 1).join('/');
            await _supabase.storage.from('avatars').remove([storagePath]);
          }
        } catch (storageError) {
          debugPrint('Error removing content file from storage: $storageError');
        }
      }

      // Clean up local engagement data
      _likeCounts.remove(storyId);
      _likedByMe.remove(storyId);
      _commentCounts.remove(storyId);

      await fetchStories();
      await fetchPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus content: $e';
      debugPrint('Error deleting story/post: $e');
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
