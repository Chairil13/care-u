import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../screens/chat/chat_detail_screen.dart';

class ChatProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? activeChatPartnerId;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesStreamSubscription;
  final Set<String> _notifiedMessageIds = {};
  bool _isFirstEmit = true;
  bool _hasUnreadMessages = false;

  bool get hasUnreadMessages => _hasUnreadMessages;

  void clearUnreadIndicator() {
    if (_hasUnreadMessages) {
      _hasUnreadMessages = false;
      notifyListeners();
    }
  }

  ChatProvider() {
    _initGlobalMessageListener();
    final initialUser = _supabase.auth.currentUser;
    if (initialUser != null) {
      _subscribeToIncomingMessages(initialUser.id);
      _registerFCMToken(initialUser.id);
    }
  }

  void _initGlobalMessageListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _subscribeToIncomingMessages(session.user.id);
        _registerFCMToken(session.user.id);
      } else {
        _unsubscribeFromIncomingMessages();
      }
    });
  }

  Future<void> _registerFCMToken(String userId) async {
    try {
      if (kIsWeb) return;
      if (!Platform.isAndroid && !Platform.isIOS) return;

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('ChatProvider: FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        final token = await messaging.getToken();
        if (token != null) {
          debugPrint('ChatProvider: FCM Token obtained: $token');
          
          await _supabase
              .from('users')
              .update({'fcm_token': token})
              .eq('id', userId);
              
          debugPrint('ChatProvider: FCM Token successfully registered in Supabase for user: $userId');
        } else {
          debugPrint('ChatProvider: FCM Token returned null');
        }
      } else {
        debugPrint('ChatProvider: User declined notification permissions');
      }
    } catch (e) {
      debugPrint('ChatProvider: Error registering FCM Token: $e');
    }
  }

  void _subscribeToIncomingMessages(String currentUserId) {
    debugPrint('ChatProvider: Subscribing to incoming messages for user: $currentUserId');
    _unsubscribeFromIncomingMessages();
    _isFirstEmit = true;
    _notifiedMessageIds.clear();

    _messagesStreamSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', currentUserId)
        .listen((List<Map<String, dynamic>> maps) async {
          debugPrint('ChatProvider: Received stream event with ${maps.length} messages. First emit: $_isFirstEmit');
          if (_isFirstEmit) {
            // Pre-populate with all existing messages so we don't notify for past history
            for (final map in maps) {
              final id = map['id'] as String;
              _notifiedMessageIds.add(id);
            }
            debugPrint('ChatProvider: Pre-populated ${_notifiedMessageIds.length} existing message IDs.');
            _isFirstEmit = false;
            return;
          }

          for (final map in maps) {
            final id = map['id'] as String;
            final receiverId = map['receiver_id'] as String?;
            final senderId = map['sender_id'] as String?;
            final message = map['message'] as String? ?? '';

            debugPrint('ChatProvider: Checking message ID: $id from sender: $senderId. Active partner: $activeChatPartnerId. Already notified: ${_notifiedMessageIds.contains(id)}');

            if (receiverId == currentUserId && 
                senderId != null && 
                senderId != activeChatPartnerId && 
                !_notifiedMessageIds.contains(id)) {
              
              _notifiedMessageIds.add(id);
              _hasUnreadMessages = true;
              notifyListeners();
              debugPrint('ChatProvider: Message qualifies for notification! Fetching sender details...');

              // Fetch sender info
              try {
                final senderData = await _supabase
                    .from('users')
                    .select()
                    .eq('id', senderId)
                    .maybeSingle();

                if (senderData != null) {
                  final sender = UserModel.fromJson(senderData);
                  final messageText = map['message'] as String? ?? '';
                  final imageUrl = map['image_url'] as String?;

                  debugPrint('ChatProvider: Sender found: ${sender.name}. Showing notification...');
                  _showInAppNotification(sender, messageText, imageUrl);
                } else {
                  debugPrint('ChatProvider: Sender data was null for ID: $senderId');
                }
              } catch (e) {
                debugPrint('ChatProvider: error fetching sender info: $e');
              }
            }
          }
        });
  }

  void _unsubscribeFromIncomingMessages() {
    _messagesStreamSubscription?.cancel();
    _messagesStreamSubscription = null;
  }

  void _showInAppNotification(UserModel sender, String messageText, String? imageUrl) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint('ChatProvider: Navigator overlay state is null, cannot show notification');
      return;
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return InAppNotificationWidget(
          sender: sender,
          message: messageText,
          imageUrl: imageUrl,
          onDismiss: () {
            try {
              overlayEntry.remove();
              debugPrint('ChatProvider: Notification overlay dismissed and removed');
            } catch (_) {}
          },
        );
      },
    );

    try {
      overlayState.insert(overlayEntry);
      debugPrint('ChatProvider: In-app notification overlay entry inserted successfully');
    } catch (e) {
      debugPrint('ChatProvider: show notification error inserting overlay: $e');
    }
  }

  List<UserModel> _technicians = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get technicians => _technicians;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all users with role 'teknisi'
  Future<void> fetchTechnicians() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'teknisi')
          .order('name', ascending: true);

      _technicians = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar teknisi: $e';
      debugPrint('ChatProvider fetchTechnicians error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all users with role 'user'
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'user')
          .order('name', ascending: true);

      _users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar user: $e';
      debugPrint('ChatProvider fetchUsers error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get real-time stream of messages between the current user and [partnerId]
  Stream<List<MessageModel>> getMessageStream(String partnerId) {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return const Stream.empty();

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((maps) {
          return maps
              .map((map) => MessageModel.fromJson(map))
              .where((m) =>
                  (m.senderId == myId && m.receiverId == partnerId) ||
                  (m.senderId == partnerId && m.receiverId == myId))
              .toList();
        });
  }

  /// Send a message
  Future<bool> sendMessage(String receiverId, String messageText) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
      notifyListeners();
      return false;
    }

    if (messageText.trim().isEmpty) return false;

    try {
      await _supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': receiverId,
        'message': messageText.trim(),
      });
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim pesan: $e';
      debugPrint('ChatProvider sendMessage error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Upload a chat image to Supabase storage bucket 'avatars'
  /// Path will be: ${myId}/chat_images/${timestamp}_${fileName}
  Future<String?> uploadChatImage(Uint8List fileBytes, String fileName) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
      notifyListeners();
      return null;
    }

    try {
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
      final path = '$myId/chat_images/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

      await _supabase.storage.from('avatars').uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      _errorMessage = 'Gagal mengunggah gambar: $e';
      debugPrint('ChatProvider uploadChatImage error: $e');
      notifyListeners();
      return null;
    }
  }

  /// Send an image message
  Future<bool> sendImageMessage(String receiverId, String imageUrl, [String? caption]) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
      notifyListeners();
      return false;
    }

    try {
      await _supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': receiverId,
        'message': caption?.trim() ?? '',
        'image_url': imageUrl,
      });
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim gambar: $e';
      debugPrint('ChatProvider sendImageMessage error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Edit an existing message
  Future<bool> editMessage(String messageId, String newText) async {
    if (newText.trim().isEmpty) return false;
    try {
      await _supabase
          .from('messages')
          .update({'message': newText.trim()})
          .eq('id', messageId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah pesan: $e';
      debugPrint('ChatProvider editMessage error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('id', messageId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus pesan: $e';
      debugPrint('ChatProvider deleteMessage error: $e');
      notifyListeners();
      return false;
    }
  }
}

class InAppNotificationWidget extends StatefulWidget {
  final UserModel sender;
  final String message;
  final String? imageUrl;
  final VoidCallback onDismiss;

  const InAppNotificationWidget({
    super.key,
    required this.sender,
    required this.message,
    this.imageUrl,
    required this.onDismiss,
  });

  @override
  State<InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<InAppNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null;
    final displayMessage = hasImage 
        ? (widget.message.isNotEmpty ? '📷 ${widget.message}' : '📷 Mengirim gambar')
        : widget.message;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _dismiss();
                  // Navigate to Chat Detail Screen with the sender!
                  final context = navigatorKey.currentContext;
                  if (context != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(partner: widget.sender),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBD0), // Vintage paper
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar or Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.sender.role == 'teknisi' 
                              ? const Color(0xFFE5B94C) 
                              : const Color(0xFF4A90D9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                        ),
                        child: widget.sender.avatarUrl != null && widget.sender.avatarUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(widget.sender.avatarUrl!, fit: BoxFit.cover),
                              )
                            : Icon(
                                widget.sender.role == 'teknisi' 
                                    ? Icons.build_rounded 
                                    : Icons.person_rounded,
                                color: const Color(0xFF2C1810),
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.sender.name.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2C1810),
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C1810),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.sender.role.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFF4EBD0),
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C1810).withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF2C1810),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
