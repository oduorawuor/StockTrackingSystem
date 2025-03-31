import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String email;
  User(this.email);
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  // Hardcoded credentials
  static const String validEmail = 'admin@example.com';
  static const String validPassword = 'password123';

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      if (email == validEmail && password == validPassword) {
        state = AsyncValue.data(User(email));
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createAccountWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      if (email == validEmail) {
        throw Exception('Account already exists');
      }
      
      // For demo purposes, we'll just sign in the user
      state = AsyncValue.data(User(email));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.data(null);
  }
}
