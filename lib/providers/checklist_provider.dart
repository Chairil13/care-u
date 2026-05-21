import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/checklist_model.dart';
import '../main.dart';

class ChecklistProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<FormChecklistModel> _forms = [];
  List<ChecklistResultModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _formSubscription;
  StreamSubscription? _resultSubscription;
  bool _hasNewChecklist = false;
  bool _isFirstFormEmit = true;
  bool _isFirstResultEmit = true;
  final Set<String> _notifiedResultFeedbacks = {};
  final Map<String, String> _notifiedResultAnswers = {};

  bool get hasNewChecklist => _hasNewChecklist;

  ChecklistProvider() {
    initRealtimeListeners();
  }

  void initRealtimeListeners() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _subscribeToRealtime(session.user.id);
      } else {
        _unsubscribeRealtime();
      }
    });

    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      _subscribeToRealtime(currentUser.id);
    }
  }

  void clearNewChecklistIndicator() {
    _hasNewChecklist = false;
    notifyListeners();
  }

  Future<void> _subscribeToRealtime(String userId) async {
    _unsubscribeRealtime();
    _isFirstFormEmit = true;
    _isFirstResultEmit = true;
    _notifiedResultFeedbacks.clear();
    _notifiedResultAnswers.clear();

    try {
      final userData = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return;
      final role = userData['role'] as String?;

      if (role == 'user') {
        debugPrint('ChecklistProvider: Subscribing to form_checklist stream for user: $userId');
        _formSubscription = _supabase
            .from('form_checklist')
            .stream(primaryKey: ['id'])
            .listen((List<Map<String, dynamic>> maps) {
              debugPrint('ChecklistProvider: Form stream fired, items count: ${maps.length}');
              if (_isFirstFormEmit) {
                _isFirstFormEmit = false;
                return;
              }
              
              _hasNewChecklist = true;
              notifyListeners();

              _showInAppNotification(
                title: 'Checklist Baru',
                message: 'Teknisi merilis form checklist pengecekan motor baru!',
                icon: Icons.checklist_rounded,
              );
            });

        debugPrint('ChecklistProvider: Subscribing to checklist_results stream for user: $userId');
        _resultSubscription = _supabase
            .from('checklist_results')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .listen((List<Map<String, dynamic>> maps) {
              debugPrint('ChecklistProvider: User result stream fired, items count: ${maps.length}');
              if (_isFirstResultEmit) {
                // Populate initial feedback states so we don't alert for existing feedbacks
                for (final map in maps) {
                  final id = map['id'] as String;
                  final feedback = map['feedback'] as String?;
                  if (feedback != null && feedback.isNotEmpty) {
                    _notifiedResultFeedbacks.add(id);
                  }
                }
                _isFirstResultEmit = false;
                return;
              }

              for (final map in maps) {
                final id = map['id'] as String;
                final feedback = map['feedback'] as String?;
                final formId = map['form_id'] as String?;

                if (feedback != null && feedback.isNotEmpty && !_notifiedResultFeedbacks.contains(id)) {
                  _notifiedResultFeedbacks.add(id);
                  _hasNewChecklist = true;
                  notifyListeners();

                  final form = _forms.firstWhere(
                    (f) => f.id == formId,
                    orElse: () => FormChecklistModel(id: '', teknisiId: '', judul: 'Pengecekan Motor'),
                  );

                  _showInAppNotification(
                    title: 'Feedback Baru',
                    message: 'Teknisi memberikan feedback untuk "${form.judul}"!',
                    icon: Icons.feedback_rounded,
                  );

                  fetchResults(isTeknisi: false, silent: true);
                }
              }
            });
      } else if (role == 'teknisi') {
        debugPrint('ChecklistProvider: Subscribing to checklist_results stream for teknisi: $userId');
        _resultSubscription = _supabase
            .from('checklist_results')
            .stream(primaryKey: ['id'])
            .listen((List<Map<String, dynamic>> maps) async {
              debugPrint('ChecklistProvider: Result stream fired, items count: ${maps.length}');
              if (_isFirstResultEmit) {
                for (final map in maps) {
                  final id = map['id'] as String;
                  final jawaban = map['jawaban'];
                  _notifiedResultAnswers[id] = jawaban != null ? jawaban.toString() : '';
                }
                _isFirstResultEmit = false;
                return;
              }

              for (final map in maps) {
                final id = map['id'] as String;
                final jawaban = map['jawaban'];
                final jawabanStr = jawaban != null ? jawaban.toString() : '';
                final senderId = map['user_id'] as String?;

                final isNew = !_notifiedResultAnswers.containsKey(id);
                final isUpdated = !isNew && _notifiedResultAnswers[id] != jawabanStr;

                if (isNew || isUpdated) {
                  _notifiedResultAnswers[id] = jawabanStr;
                  _hasNewChecklist = true;
                  notifyListeners();

                  String userName = 'Mahasiswi';
                  if (senderId != null) {
                    try {
                      final userResponse = await _supabase
                          .from('users')
                          .select('name')
                          .eq('id', senderId)
                          .maybeSingle();
                      if (userResponse != null) {
                        userName = userResponse['name'] as String? ?? 'Mahasiswi';
                      }
                    } catch (_) {}
                  }

                  _showInAppNotification(
                    title: isNew ? 'Hasil Checklist Baru' : 'Checklist Diperbarui',
                    message: isNew 
                        ? 'Ada hasil checklist baru masuk dari $userName!'
                        : '$userName memperbarui hasil checklist-nya!',
                    icon: Icons.fact_check_rounded,
                  );

                  fetchResults(isTeknisi: true, silent: true);
                }
              }
            });
      }
    } catch (e) {
      debugPrint('ChecklistProvider subscription error: $e');
    }
  }

  void _unsubscribeRealtime() {
    _formSubscription?.cancel();
    _formSubscription = null;
    _resultSubscription?.cancel();
    _resultSubscription = null;
  }

  void _showInAppNotification({
    required String title,
    required String message,
    required IconData icon,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return ChecklistNotificationWidget(
          title: title,
          message: message,
          icon: icon,
          onDismiss: () {
            try {
              overlayEntry.remove();
            } catch (_) {}
          },
        );
      },
    );

    try {
      overlayState.insert(overlayEntry);
    } catch (_) {}
  }

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }

  List<FormChecklistModel> get forms => _forms;
  List<ChecklistResultModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch all checklist forms (includes their items)
  Future<void> fetchForms() async {
    _isLoading = true;
    _errorMessage = null;
    // We notify listeners early so UI can show loading
    Future.microtask(() => notifyListeners());

    try {
      final response = await _supabase
          .from('form_checklist')
          .select('*, checklist_items(*)')
          .order('created_at', ascending: false);

      _forms = (response as List)
          .map((json) => FormChecklistModel.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat form checklist: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new checklist form with items
  Future<bool> createForm({
    required String judul,
    required String deskripsi,
    required List<String> itemNames,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _setLoading(true);
    try {
      // 1. Insert form checklist
      final formResponse = await _supabase
          .from('form_checklist')
          .insert({
            'teknisi_id': user.id,
            'judul': judul,
            'deskripsi': deskripsi,
          })
          .select()
          .single();

      final String formId = formResponse['id'] as String;

      // 2. Insert items
      if (itemNames.isNotEmpty) {
        final List<Map<String, dynamic>> itemsToInsert = itemNames
            .map((name) => {
                  'form_id': formId,
                  'item_name': name,
                })
            .toList();

        await _supabase.from('checklist_items').insert(itemsToInsert);
      }

      await fetchForms();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat form: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a checklist form
  Future<bool> deleteForm(String formId) async {
    _setLoading(true);
    try {
      await _supabase.from('form_checklist').delete().eq('id', formId);
      await fetchForms();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus form: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing checklist form with items
  Future<bool> updateForm({
    required String formId,
    required String judul,
    required String deskripsi,
    required List<String> itemNames,
  }) async {
    _setLoading(true);
    try {
      // 1. Update form checklist
      await _supabase
          .from('form_checklist')
          .update({
            'judul': judul,
            'deskripsi': deskripsi,
          })
          .eq('id', formId);

      // 2. Delete existing items
      await _supabase.from('checklist_items').delete().eq('form_id', formId);

      // 3. Insert new items
      if (itemNames.isNotEmpty) {
        final List<Map<String, dynamic>> itemsToInsert = itemNames
            .map((name) => {
                  'form_id': formId,
                  'item_name': name,
                })
            .toList();

        await _supabase.from('checklist_items').insert(itemsToInsert);
      }

      await fetchForms();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui form: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch checklist results (all for technician, or own for user)
  Future<void> fetchResults({bool isTeknisi = false, bool silent = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      Future.microtask(() => notifyListeners());
    }

    try {
      var query = _supabase
          .from('checklist_results')
          .select('*, users(*), form_checklist(*)');

      if (!isTeknisi) {
        query = query.eq('user_id', user.id);
      }

      final response = await query.order('created_at', ascending: false);

      _results = (response as List)
          .map((json) => ChecklistResultModel.fromJson(json))
          .toList();
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Gagal memuat riwayat checklist: $e';
      }
      debugPrint('Error fetching results: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Submit checklist results
  Future<bool> submitResult({
    required String formId,
    required Map<String, dynamic> jawaban,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _setLoading(true);
    try {
      await _supabase.from('checklist_results').insert({
        'user_id': user.id,
        'form_id': formId,
        'jawaban': jawaban,
      });

      _hasNewChecklist = false;
      await fetchResults(isTeknisi: false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim hasil checklist: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing checklist result (User)
  Future<bool> updateResult({
    required String resultId,
    required Map<String, dynamic> jawaban,
  }) async {
    _setLoading(true);
    try {
      await _supabase
          .from('checklist_results')
          .update({
            'jawaban': jawaban,
            'feedback': null, // Clear feedback when user updates answers so technician can re-review
          })
          .eq('id', resultId);

      await fetchResults(isTeknisi: false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui hasil checklist: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an existing checklist result (User)
  Future<bool> deleteResult(String resultId) async {
    _setLoading(true);
    try {
      await _supabase
          .from('checklist_results')
          .delete()
          .eq('id', resultId);

      await fetchResults(isTeknisi: false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus hasil checklist: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Submit feedback on a checklist result (Technician)
  Future<bool> submitFeedback({
    required String resultId,
    required String feedback,
  }) async {
    _setLoading(true);
    try {
      await _supabase
          .from('checklist_results')
          .update({'feedback': feedback})
          .eq('id', resultId);

      await fetchResults(isTeknisi: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim feedback: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

class ChecklistNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;

  const ChecklistNotificationWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<ChecklistNotificationWidget> createState() => _ChecklistNotificationWidgetState();
}

class _ChecklistNotificationWidgetState extends State<ChecklistNotificationWidget> with SingleTickerProviderStateMixin {
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
                onTap: _dismiss,
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5B94C), // Retro Mustard
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                        ),
                        child: Icon(
                          widget.icon,
                          color: const Color(0xFF2C1810),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810),
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C1810).withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF2C1810),
                        size: 20,
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
