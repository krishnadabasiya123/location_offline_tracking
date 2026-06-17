import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class UserDetailsState extends Equatable {}

class UserDetailsInitial extends UserDetailsState {
  @override
  List<Object?> get props => [];
}

class UserDetailsFetchProgress extends UserDetailsState {
  @override
  List<Object?> get props => [];
}

class UserDetailsFetchSuccess extends UserDetailsState {
  UserDetailsFetchSuccess({required this.userDetail});

  final UserDetails userDetail;

  UserDetailsFetchSuccess copyWith({UserDetails? newUserDetails}) {
    return UserDetailsFetchSuccess(userDetail: newUserDetails ?? userDetail);
  }

  @override
  List<Object?> get props => [userDetail];
}

class UserDetailsFetchFailure extends UserDetailsState {
  UserDetailsFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit() : super(UserDetailsInitial());
  final UserProfileRepository _generalRepository = UserProfileRepository();

  Future<void> fetchUserDetails() async {
    emit(UserDetailsFetchProgress());

    await _generalRepository
        .getUserProfile()
        .then((value) {
          emit(UserDetailsFetchSuccess(userDetail: value));
        })
        .catchError((Object e) {
          if (e is ApiException) {
            emit(UserDetailsFetchFailure(exception: e));
          } else {
            emit(UserDetailsFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
          }
        });
  }

  void updateUserDetails(UserDetails userDetails) {
    if (state is UserDetailsFetchSuccess) {
      final currentState = state as UserDetailsFetchSuccess;
      emit(currentState.copyWith(newUserDetails: userDetails));
    }
  }

  void updateUserDetailsLocally({required String name, required String number, required String imageUrl}) {
    if (state is UserDetailsFetchSuccess) {
      final currentState = state as UserDetailsFetchSuccess;
      final userDetail = currentState.userDetail;

      emit(
        currentState.copyWith(
          newUserDetails: userDetail.copyWith(
            name: name.trim().isEmpty ? null : name,
            phone: number.trim().isEmpty ? null : number,
            imageUrl: imageUrl.trim().isEmpty ? null : imageUrl,
          ),
        ),
      );
    }
  }

  void updateUserShiftStatus({required bool newStatus}) {
    if (state is UserDetailsFetchSuccess) {
      final currentState = state as UserDetailsFetchSuccess;
      final userDetail = currentState.userDetail;

      emit(currentState.copyWith(newUserDetails: userDetail.copyWith(hasClockedIn: newStatus)));
    }
  }

  UserDetails getCurrentUser() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userDetail;
    }
    return UserDetails.fromJson(const {});
  }

  UserRole getCurrentUserRole() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userDetail.role;
    }
    return UserRole.salesman;
  }

  bool isUserMerchant() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userDetail.role == UserRole.merchant;
    }
    return false;
  }

  bool isUserSalesman() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userDetail.role == UserRole.salesman;
    }
    return false;
  }
}
