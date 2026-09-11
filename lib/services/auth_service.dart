import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  void configureFirebase({required bool available}) {
    _isFirebaseAvailable = available;
    if (available) {
      try {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        debugPrint('AuthService: Connected to Firebase Auth & Cloud Firestore.');
      } catch (e) {
        _isFirebaseAvailable = false;
        debugPrint('AuthService: Failed to connect to Firebase: $e');
      }
    }
  }

  /// Sign in employee or register if new account in Firebase
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (_isFirebaseAvailable && _auth != null) {
      UserCredential? credential;
      try {
        credential = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
      } on FirebaseAuthException catch (e) {
        // If user not registered yet in Firebase Auth, automatically create it
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'channel-error') {
          try {
            debugPrint('User not found, auto-registering in Firebase Auth...');
            credential = await _auth!.createUserWithEmailAndPassword(
              email: cleanEmail,
              password: cleanPassword,
            );
          } on FirebaseAuthException catch (regError) {
            debugPrint('Auto-register failed: ${regError.code} - ${regError.message}');
            // Fall back to clean error handling
            throw Exception(_getFirebaseAuthErrorMessage(regError));
          }
        } else {
          throw Exception(_getFirebaseAuthErrorMessage(e));
        }
      } catch (e) {
        debugPrint('Firebase signIn general error: $e');
      }

      if (credential != null && credential.user != null) {
        final uid = credential.user!.uid;

        // Fetch or create profile in Cloud Firestore users collection
        if (_firestore != null) {
          try {
            final docRef = _firestore!.collection(AppConstants.usersCollection).doc(uid);
            final doc = await docRef.get();

            if (doc.exists && doc.data() != null) {
              final user = UserModel.fromMap(doc.data()!, id: uid);
              await _saveLocalSession(user);
              return user;
            } else {
              // Create user document in Firestore
              final nameFromEmail = cleanEmail.split('@').first;
              final formattedName = nameFromEmail.toLowerCase() == 'abel'
                  ? 'Abel'
                  : nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1);

              final newUser = UserModel(
                id: uid,
                name: formattedName,
                employeeId: AppConstants.demoEmployeeId,
                email: cleanEmail,
                position: AppConstants.demoPosition,
                department: AppConstants.demoDepartment,
                officeName: AppConstants.defaultOfficeName,
                createdAt: DateTime.now(),
              );

              final userData = newUser.toMap();
              userData['createdAt'] = FieldValue.serverTimestamp();
              await docRef.set(userData);
              await _saveLocalSession(newUser);
              return newUser;
            }
          } catch (firestoreError) {
            debugPrint('Firestore user read/write error: $firestoreError');
          }
        }

        // Return authenticated model
        final user = UserModel(
          id: uid,
          name: AppConstants.demoName,
          employeeId: AppConstants.demoEmployeeId,
          email: cleanEmail,
          position: AppConstants.demoPosition,
          department: AppConstants.demoDepartment,
          officeName: AppConstants.defaultOfficeName,
          createdAt: DateTime.now(),
        );
        await _saveLocalSession(user);
        return user;
      }
    }

    // Local / Offline Fallback Mode
    await Future.delayed(const Duration(milliseconds: 500));
    final nameFromEmail = cleanEmail.split('@').first;
    final formattedName = nameFromEmail.toLowerCase() == 'abel'
        ? 'Abel'
        : nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1);

    final user = UserModel(
      id: 'usr_${nameFromEmail}_2026',
      name: formattedName,
      employeeId: AppConstants.demoEmployeeId,
      email: cleanEmail,
      position: AppConstants.demoPosition,
      department: AppConstants.demoDepartment,
      officeName: AppConstants.defaultOfficeName,
      createdAt: DateTime.now(),
    );
    await _saveLocalSession(user);
    return user;
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi tidak cocok. Silakan periksa kembali.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun karyawan Anda telah dinonaktifkan.';
      case 'weak-password':
        return 'Kata sandi minimal 6 karakter.';
      case 'network-request-failed':
        return 'Gagal terhubung ke server Firebase. Periksa koneksi internet Anda.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }

  /// Check active session on startup
  Future<UserModel?> getCurrentUser() async {
    if (_isFirebaseAvailable && _auth != null) {
      final currentFirebaseUser = _auth!.currentUser;
      if (currentFirebaseUser != null) {
        try {
          if (_firestore != null) {
            final doc = await _firestore!
                .collection(AppConstants.usersCollection)
                .doc(currentFirebaseUser.uid)
                .get();
            if (doc.exists && doc.data() != null) {
              return UserModel.fromMap(doc.data()!, id: currentFirebaseUser.uid);
            }
          }
        } catch (_) {}

        return UserModel(
          id: currentFirebaseUser.uid,
          name: currentFirebaseUser.displayName ?? AppConstants.demoName,
          employeeId: AppConstants.demoEmployeeId,
          email: currentFirebaseUser.email ?? AppConstants.demoEmail,
          position: AppConstants.demoPosition,
          department: AppConstants.demoDepartment,
          officeName: AppConstants.defaultOfficeName,
          createdAt: DateTime.now(),
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      return UserModel(
        id: prefs.getString('user_id') ?? 'usr_abel_2026',
        name: prefs.getString('user_name') ?? AppConstants.demoName,
        employeeId: prefs.getString('user_emp_id') ?? AppConstants.demoEmployeeId,
        email: prefs.getString('user_email') ?? AppConstants.demoEmail,
        position: prefs.getString('user_position') ?? AppConstants.demoPosition,
        department: prefs.getString('user_dept') ?? AppConstants.demoDepartment,
        officeName: prefs.getString('user_office') ?? AppConstants.defaultOfficeName,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Sign out employee
  Future<void> signOut() async {
    if (_isFirebaseAvailable && _auth != null) {
      try {
        await _auth!.signOut();
      } catch (e) {
        debugPrint('Firebase sign out error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveLocalSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_emp_id', user.employeeId);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_position', user.position);
    await prefs.setString('user_dept', user.department);
    await prefs.setString('user_office', user.officeName);
  }
}
