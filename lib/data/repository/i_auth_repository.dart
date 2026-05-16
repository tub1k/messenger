abstract class IAuthRepository {
  Stream<String?> get authStateChanges;

  Future<String> signInWithEmail(String email, String password);

  Future<String> signUpWithEmail(String email, String password);

  Future<void> signOut();
}