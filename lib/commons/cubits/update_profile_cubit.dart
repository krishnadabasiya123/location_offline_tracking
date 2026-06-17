import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class UpdateProfileState extends Equatable {}

class UpdateProfileInitial extends UpdateProfileState {
  @override
  List<Object?> get props => [];
}

class UpdateProfileFetchProgress extends UpdateProfileState {
  @override
  List<Object?> get props => [];
}

class UpdateProfileFetchSuccess extends UpdateProfileState {
  UpdateProfileFetchSuccess({
    required this.UpdateProfile,
  });

  final UserDetails UpdateProfile;

  @override
  List<Object?> get props => [UpdateProfile];
}

class UpdateProfileFetchFailure extends UpdateProfileState {
  UpdateProfileFetchFailure({required this.errorMessage});

  final String errorMessage;
  @override
  List<Object?> get props => [errorMessage];
}

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit() : super(UpdateProfileInitial());
  final GeneralRepository _generalRepository = GeneralRepository();

  Future<void> updateUserDetails({
    required String firstName,
    required String number,
    required String imageUrl,
  }) async {
    emit(UpdateProfileFetchProgress());
    try {
      final result = await _generalRepository.updateProfile(name: firstName, imageUrl: imageUrl, number: number);
      emit(UpdateProfileFetchSuccess(UpdateProfile: result));
    } on ApiException catch (e) {
      emit(UpdateProfileFetchFailure(errorMessage: e.errorMessageKey));
    }
  }
}
