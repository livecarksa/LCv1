import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../../domain/models/auth_state.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final SupabaseClient _supabase;

  @override
  Future<AuthState> build() async {
    _supabase = Supabase.instance.client;
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final workshopId = await _getWorkshopId(session.user.id);
      return AuthState(
        status: AuthStatus.authenticated,
        userId: session.user.id,
        workshopId: workshopId,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<String?> _getWorkshopId(String userId) async {
    try {
      final result = await _supabase
          .from('workshops')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
      return result?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> sendOtp(String phone) async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signInWithOtp(phone: '+966$phone');
      state = AsyncData(const AuthState(status: AuthStatus.unauthenticated));
    } on AuthException catch (e) {
      state = AsyncData(AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
      throw AppException(e.message);
    }
  }

  Future<void> verifyOtp({required String phone, required String token}) async {
    state = const AsyncLoading();
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: '+966$phone',
        token: token,
        type: OtpType.sms,
      );
      final userId = res.user?.id;
      if (userId == null) throw const AuthException('فشل التحقق من الرمز');
      final workshopId = await _getWorkshopId(userId);
      state = AsyncData(AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        workshopId: workshopId,
        isNewUser: workshopId == null,
      ));
    } on AuthException catch (e) {
      state = AsyncData(AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
      throw AppException(e.message);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = AsyncData(const AuthState(status: AuthStatus.unauthenticated));
  }
}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';
import '../models/auth_state.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final SupabaseClient _supabase;

  @override
  Future<AuthState> build() async {
    _supabase = Supabase.instance.client;
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final workshopId = await _getWorkshopId(session.user.id);
      return AuthState(
        status: AuthStatus.authenticated,
        userId: session.user.id,
        workshopId: workshopId,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<String?> _getWorkshopId(String userId) async {
    try {
      final result = await _supabase
          .from('workshops')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
      return result?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> sendOtp(String phone) async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signInWithOtp(phone: '+966$phone');
      state = AsyncData(const AuthState(status: AuthStatus.unauthenticated));
    } on AuthException catch (e) {
      state = AsyncData(AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
      throw AppException(e.message);
    }
  }

  Future<void> verifyOtp({required String phone, required String token}) async {
    state = const AsyncLoading();
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: '+966$phone',
        token: token,
        type: OtpType.sms,
      );
      final userId = res.user?.id;
      if (userId == null) throw const AuthException('فشل التحقق من الرمز');
      final workshopId = await _getWorkshopId(userId);
      state = AsyncData(AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        workshopId: workshopId,
        isNewUser: workshopId == null,
      ));
    } on AuthException catch (e) {
      state = AsyncData(AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
      throw AppException(e.message);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = AsyncData(const AuthState(status: AuthStatus.unauthenticated));
  }
}
