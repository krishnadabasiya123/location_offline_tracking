import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/achievement/model/achievement.dart';
import 'package:omkar_sale/features/achievement/repository/achievement_repository.dart';

@immutable
abstract class GetAchievementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAchievementInitial extends GetAchievementState {}

class GetAchievementInProgress extends GetAchievementState {}

class GetAchievementFetchSuccess extends GetAchievementState {
  GetAchievementFetchSuccess({
    required this.achievements,
    required this.total,
    this.isError = false,
    this.isLoading = false,
    this.exception,
  });
  final List<Achievement> achievements;
  final int total;

  final bool isLoading;
  final bool isError;
  final ApiException? exception;

  GetAchievementFetchSuccess copyWith({
    List<Achievement>? achievements,
    int? total,
    int? categoryId,
    bool? isLoading,
    bool? isError,
    // Use a Function that returns an ApiException? to allow passing null
    ApiException? Function()? exception,
  }) {
    return GetAchievementFetchSuccess(
      achievements: achievements ?? this.achievements,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      // Logic: If the function is provided, use it (even if it returns null)
      exception: exception != null ? exception() : this.exception,
    );
  }

  @override
  List<Object?> get props => [achievements, total, isLoading, isError, exception];
}

class GetAchievementFetchFailure extends GetAchievementState {
  GetAchievementFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetAchievementCubit extends Cubit<GetAchievementState> {
  GetAchievementCubit() : super(GetAchievementInitial());
  final AchievementRepository _achievementRepository = AchievementRepository();

  Future<void> fetchGetAchievement() async {
    emit(GetAchievementInProgress());

    try {
      final value = await _achievementRepository.getAchievements(limit: apiCallLimit);
      emit(GetAchievementFetchSuccess(achievements: value['achievements'] as List<Achievement>, total: value['total'] as int));
    } catch (e) {
      if (e is ApiException) {
        emit(GetAchievementFetchFailure(exception: e));
      } else {
        emit(GetAchievementFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }

  void addAchievement({required Achievement achievement}) {
    // Check if we are in the success state
    if (state is GetAchievementFetchSuccess) {
      final currentState = state as GetAchievementFetchSuccess;

      final updatedList = [achievement, ...currentState.achievements];

      emit(currentState.copyWith(achievements: updatedList));
    }
  }

  Future<void> fetchMoreAchievements() async {
    if (state is GetAchievementFetchSuccess) {
      final currentState = state as GetAchievementFetchSuccess;
      if (currentState.isLoading) return;

      emit(currentState.copyWith(isLoading: true));

      try {
        final value = await _achievementRepository.getAchievements(limit: apiCallLimit, offset: currentState.achievements.length);

        final newAchievements = value['achievements'] as List<Achievement>;

        emit(currentState.copyWith(achievements: [...currentState.achievements, ...newAchievements], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(currentState.copyWith(isError: true, exception: () => e));
        } else {
          emit(currentState.copyWith(isError: true, exception: () => ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreAchievements() {
    if (state is GetAchievementFetchSuccess) {
      final s = state as GetAchievementFetchSuccess;
      return s.total > s.achievements.length;
    }
    return false;
  }
}
