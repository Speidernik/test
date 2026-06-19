class AuthRepository {
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Replace with real API/backend call
    if (email.isEmpty || password.length < 6) {
      return AuthResult.failure('Invalid credentials. Please try again.');
    }
    return AuthResult.success();
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

class AuthResult {
  final bool isSuccess;
  final String? error;

  const AuthResult._({required this.isSuccess, this.error});

  factory AuthResult.success() => const AuthResult._(isSuccess: true);
  factory AuthResult.failure(String error) =>
      AuthResult._(isSuccess: false, error: error);
}
