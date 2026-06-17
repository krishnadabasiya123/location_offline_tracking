import 'package:flutter/widgets.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/model/notification.dart';
import 'package:omkar_sale/features/setting/repository/setting_repository.dart';

@immutable
abstract class GetNotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetNotificationInitial extends GetNotificationState {}

class GetNotificationInProgress extends GetNotificationState {}

class GetNotificationFetchSuccess extends GetNotificationState {
  GetNotificationFetchSuccess({
    required this.notifications,
    required this.total,
    this.isError = false,
    this.isLoading = false,
    this.exception,
  });
  final List<AppNotification> notifications;
  final int total;
  final bool isLoading;
  final bool isError;
  final ApiException? exception;

  GetNotificationFetchSuccess copyWith({
    List<AppNotification>? notifications,
    int? total,
    bool? isLoading,
    bool? isError,
    ApiException? exception,
  }) {
    return GetNotificationFetchSuccess(
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      exception: exception ?? this.exception,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [notifications, total, isLoading, isError, exception];
}

class GetNotificationFetchFailure extends GetNotificationState {
  GetNotificationFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetNotificationCubit extends Cubit<GetNotificationState> {
  GetNotificationCubit() : super(GetNotificationInitial());
  final SettingRepository _settingRepository = SettingRepository();

  Future<void> fetchGetNotification() async {
    emit(GetNotificationInProgress());

    try {
      final value = await _settingRepository.getNotificationsList(limit: apiCallLimit);
      emit(GetNotificationFetchSuccess(notifications: value['notifications'] as List<AppNotification>, total: value['total'] as int));
    } catch (e) {
      if (e is ApiException) {
        emit(GetNotificationFetchFailure(exception: e));
      } else {
        emit(GetNotificationFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }

  Future<void> fetchMoreNotifications() async {
    if (state is GetNotificationFetchSuccess) {
      final currentState = state as GetNotificationFetchSuccess;
      if (currentState.isLoading) return;

      emit(currentState.copyWith(isLoading: true));

      try {
        final value = await _settingRepository.getNotificationsList(limit: apiCallLimit, offset: currentState.notifications.length);
        final newNotification = value['notifications'] as List<AppNotification>;
        emit(currentState.copyWith(notifications: [...currentState.notifications, ...newNotification], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(currentState.copyWith(isError: true, exception: e));
        } else {
          emit(currentState.copyWith(isError: true, exception: ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreNotifications() {
    if (state is GetNotificationFetchSuccess) {
      final s = state as GetNotificationFetchSuccess;
      return s.total > s.notifications.length;
    }
    return false;
  }
}
