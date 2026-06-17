import 'package:omkar_sale/core/app/all_import_file.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.userDetails, required this.jwtToken});
  final UserDetails userDetails;
  final String jwtToken;
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository = AuthRepository();

  void _checkAuthStatus() {
    final details = _authRepository.getLocalAuthDetails();
    if (details['isLogin'] == true) {
      emit(Authenticated(userDetails: UserDetails.fromJson(details['userData'] as Map<String, dynamic>), jwtToken: details['jwtToken'] as String));
    } else {
      emit(Unauthenticated());
    }
  }

  void setUnauthenticated() => emit(Unauthenticated());

  Future<void> updateAuthDetails({
    required String jwtToken,
    required Map<String, dynamic> userData,
  }) async {
    await _authRepository.setLocalAuthDetails(jwtToken: jwtToken, authStatus: true, userData: userData);
    emit(Authenticated(userDetails: UserDetails.fromJson(userData), jwtToken: jwtToken));
  }

  Future<void> signOut() async {
    await _authRepository.clearSessionData();
    emit(Unauthenticated());
  }
}
