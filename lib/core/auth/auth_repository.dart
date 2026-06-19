import 'package:flutter/material.dart';
import 'package:starter_app/core/auth/app_user.dart';
import 'package:starter_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  AppUser? _user;
  bool _isOffline = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isOffline => _isOffline;

  /// True when the app has a usable identity (either auth'd or offline mode).
  bool get isReady => isLoggedIn || _isOffline;
  String? get error => _error;

  Future<void> init() async {
    // When Supabase isn't configured the user will see the auth screen and
    // choose "Continue Offline" — don't skip it by auto-setting offline here.
    if (!AppConfig.isConfigured) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _user = AppUser.fromSupabase(session.user);
      _isOffline = false;
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final u = data.session?.user;
      _user = u != null ? AppUser.fromSupabase(u) : null;
      if (_user != null) _isOffline = false;
      _error = null;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _error = null;
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _error = null;
    try {
      await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': displayName.trim()},
      );
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  void continueOffline() {
    _isOffline = true;
    _error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (AppConfig.isConfigured && _user != null) {
      await Supabase.instance.client.auth.signOut();
    }
    _user = null;
    _isOffline = false;
    _error = null;
    notifyListeners();
  }
}
