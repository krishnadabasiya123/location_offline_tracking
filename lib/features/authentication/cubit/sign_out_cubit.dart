import 'package:omkar_sale/core/app/all_import_file.dart';

abstract class LogOutState {}

class LogOutInitial extends LogOutState {}

class LogOutProgress extends LogOutState {}

class LogOutSuccess extends LogOutState {}

class LogOutFailure extends LogOutState {
  LogOutFailure(this.errorMessage);
  final String errorMessage;
}

class LogOutCubit extends Cubit<LogOutState> {
  LogOutCubit(this._authRepository) : super(LogOutInitial());
  final AuthRepository _authRepository;

  Future<void> logOutUser() async {
    emit(LogOutProgress());
    try {
      await _authRepository.signOut();

      emit(LogOutSuccess());
    } on ApiException catch (e) {
      emit(LogOutFailure(e.errorMessageKey));
    } catch (e) {
      emit(LogOutFailure(e.toString()));
    }
  }
}
