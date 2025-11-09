import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateProvider<AuthState>((ref) => AuthState.initial());

class AuthState {
  final String? userId;
  final String? token;
  AuthState({this.userId, this.token});
  factory AuthState.initial() => AuthState(userId: 'demo-user', token: null);
}
