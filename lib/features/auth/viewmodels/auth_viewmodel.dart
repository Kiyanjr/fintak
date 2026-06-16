//First create a state class called AuthState at the top of this file. This represents
// everything the auth screens need to know
import 'package:fintak/core/providers/app_providers.dart';
import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/data/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final String email;
  final String password;
  final String name;
  final double monthlyBudget;
  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordVisible;

  static const _sentinel = Object(); //<----------- if errorMessage was null
  const AuthState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.monthlyBudget = 2500.0,
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordVisible = false,
  });

  AuthState copyWith({
    String? email,
    String? password,
    String? name,
    double? monthlyBudget,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    bool? isPasswordVisible,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

class AuthViewmodel extends StateNotifier<AuthState> {
  final LocalDatasource _localDatasource;
  AuthViewmodel(this._localDatasource) : super(const AuthState());

  void upadateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassWord(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateName(String value) {
    state = state.copyWith(name: value, errorMessage: null);
  }

  void updateMonthlyBudget(double value) {
    state = state.copyWith(monthlyBudget: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  bool validateEmail() {
    if (state.email.contains('@') && state.email.contains('.')) {
      state = state.copyWith(errorMessage: null);
      return true;
    } else {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }
  }

  bool validatePassword() {
    if (state.password.length >= 6) {
      return true;
    } else {
      state = state.copyWith(
        errorMessage: 'Password must be at least 6 Character!',
      );
      return false;
    }
  }

  bool validateName() {
    if (state.name.isNotEmpty) {
      return true;
    } else {
      state = state.copyWith(errorMessage: 'Please enter your name');
      return false;
    }
  }

  //  private helper
  void _setError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }

  bool _validateSignIn() {
    if (!state.email.trim().contains('@')) {
      _setError('Please Enter valid email.');
      return false;
    } else {
      if (state.password.length < 6) {
        _setError('Password must be at least 6 characters long.');
        return false;
      }
      return true;
    }
  }

  bool _validateSignUp() {
    if (state.name.trim().isEmpty) {
      _setError('Please enter your name');
      return false;
    }
    if (state.password.length < 6) {
      _setError('password must be 6 hcraacters long.');
      return false;
    }
    if (!state.email.trim().contains('@')) {
      _setError('Invalid emial');
      return false;
    }
    return true;
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email',
      'wrong-password' => 'Incorrect password',
      'invalid-credential' => 'Incorrect email or password',
      'email-already-in-use' => 'An account already exists with this email',
      'invalid-email' => 'Please enter a valid email',
      'weak-password' => 'Password must be at least 6 characters',
      'network-request-failed' => 'Check your internet connection',
      'too-many-requests' => 'Too many attempts. Please try again later',
      _ => 'Authentication failed. Please try again',
    };
  }

  Future<void> signIn(WidgetRef ref) async {
    if (!_validateSignIn()) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
      );
      final uid = credential.user!.uid;
      ref.read(appStateProvider.notifier).setUser(uid);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Somtheing went wrong. Please try again.');
    }
  }

  Future<void> singUp(WidgetRef ref) async {
    if (!_validateSignUp()) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: state.email.trim(),
            password: state.password,
          );
      final uid = credential.user!.uid;
      // create local user profile
      final usermodel = UserModel(
        id: uid,
        name: state.name.trim(),
        email: state.email.trim(),
        monthlyBudget: state.monthlyBudget,
        createdAt: DateTime.now(),
      );
      // save user locally
      await _localDatasource.saveUser(usermodel);
      ref.read(appStateProvider.notifier).setUser(uid);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut(WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _localDatasource.clearUser();
      ref.read(appStateProvider.notifier).clearUser();
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    }
  }
}

//    riverpod
 final authViewModelProvider=StateNotifierProvider<AuthViewmodel,AuthState>((ref){
final datasource=ref.watch(localDataSourceProvider).requireValue;
return AuthViewmodel(datasource);
 });