import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory AppUser.fromSupabase(User user) => AppUser(
    id: user.id,
    email: user.email ?? '',
    displayName:
        (user.userMetadata?['display_name'] as String?)?.trim().isNotEmpty ==
            true
        ? user.userMetadata!['display_name'] as String
        : (user.email ?? 'User').split('@').first,
  );

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}
