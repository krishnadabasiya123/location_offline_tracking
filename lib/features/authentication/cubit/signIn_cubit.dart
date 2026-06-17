import 'package:omkar_sale/core/app/all_import_file.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInProgress extends SignInState {}

class SignInSuccess extends SignInState {
  SignInSuccess({required this.jwtToken, required this.userDetails});
  final String jwtToken;
  final UserDetails userDetails;
}

class SignInFailure extends SignInState {
  SignInFailure({required this.exception});
  final ApiException exception;
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());
  final AuthRepository _authRepository = AuthRepository();

  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    emit(SignInProgress());

    _authRepository
        .signUser(email: email, password: password)
        .then((result) {
          final (:userData, :jwtToken) = result;
          emit(SignInSuccess(jwtToken: jwtToken, userDetails: UserDetails.fromJson(userData)));
        })
        .catchError((Object e) {
          if (e is ApiException) {
            emit(SignInFailure(exception: e));
          } else {
            emit(SignInFailure(exception: ApiException(errorMessageKey: e.toString())));
          }
        });
  }
}
