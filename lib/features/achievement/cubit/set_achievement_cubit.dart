import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/achievement/model/achievement.dart';
import 'package:omkar_sale/features/achievement/repository/achievement_repository.dart';


@immutable
abstract class SetAchievementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetAchievementInitial extends SetAchievementState {}

class SetAchievementInProgress extends SetAchievementState {}

class SetAchievementFetchSuccess extends SetAchievementState {
  SetAchievementFetchSuccess({
    required this.achievement,
  });
  final Achievement achievement;

  SetAchievementFetchSuccess copyWith({
    Achievement? newAchievement,
  }) {
    return SetAchievementFetchSuccess(achievement: newAchievement ?? achievement);
  }

  @override
  List<Object?> get props => [achievement];
}

class SetAchievementFetchFailure extends SetAchievementState {
  SetAchievementFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class SetAchievementCubit extends Cubit<SetAchievementState> {
  SetAchievementCubit() : super(SetAchievementInitial());
  final AchievementRepository _achievementRepository = AchievementRepository();

  Future<void> setAchievement({required String achievementTitle}) async {
    emit(SetAchievementInProgress());

    try {
      final value = await _achievementRepository.requestAchievement(achievementTitle: achievementTitle);
      emit(SetAchievementFetchSuccess(achievement: value));
    } catch (e) {
      if (e is ApiException) {
        emit(SetAchievementFetchFailure(exception: e));
      } else {
        emit(SetAchievementFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
