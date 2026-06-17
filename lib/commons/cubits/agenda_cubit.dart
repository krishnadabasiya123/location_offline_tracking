import 'package:omkar_sale/commons/models/agenda_details.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class GetAgendaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAgendaInitial extends GetAgendaState {}

class GetAgendaInProgress extends GetAgendaState {}

class GetAgendaFetchSuccess extends GetAgendaState {
  GetAgendaFetchSuccess({
    required this.agendas,
    required this.total,
    this.isError = false,
    this.isLoading = false,
    this.exception,
  });
  final List<AgendaDetails> agendas;
  final int total;

  final bool isLoading;
  final bool isError;
  final ApiException? exception;

  GetAgendaFetchSuccess copyWith({
    List<AgendaDetails>? agendas,
    int? total,
    int? categoryId,
    bool? isLoading,
    bool? isError,
    // Use a Function that returns an ApiException? to allow passing null
    ApiException? Function()? exception,
  }) {
    return GetAgendaFetchSuccess(
      agendas: agendas ?? this.agendas,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      // Logic: If the function is provided, use it (even if it returns null)
      exception: exception != null ? exception() : this.exception,
    );
  }

  @override
  List<Object?> get props => [agendas, total, isLoading, isError, exception];
}

class GetAgendaFetchFailure extends GetAgendaState {
  GetAgendaFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetAgendaCubit extends Cubit<GetAgendaState> {
  GetAgendaCubit() : super(GetAgendaInitial());
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  Future<void> fetchGetAgenda() async {
    emit(GetAgendaInProgress());

    try {
      final value = await _userProfileRepository.getAgendas(limit: apiCallLimit);

      emit(GetAgendaFetchSuccess(agendas: value['agendas'] as List<AgendaDetails>, total: value['total'] as int));
    } catch (e) {
      if (e is ApiException) {
        emit(GetAgendaFetchFailure(exception: e));
      } else {
        emit(GetAgendaFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }

  Future<void> updateCompletionNotes({required AgendaDetails updateAgendaDetails}) async {
    if (state is GetAgendaFetchSuccess) {
      final currentState = state as GetAgendaFetchSuccess;
      final updatedList = List<AgendaDetails>.from(currentState.agendas);
      final index = updatedList.indexWhere((element) => element.id == updateAgendaDetails.id);

      if (index != -1) {
        updatedList[index] = updateAgendaDetails;
        emit(currentState.copyWith(agendas: updatedList));
      }
    }
  }

  Future<void> fetchMoreAgendas() async {
    if (state is GetAgendaFetchSuccess) {
      final currentState = state as GetAgendaFetchSuccess;
      if (currentState.isLoading) return;

      emit(currentState.copyWith(isLoading: true));

      try {
        final value = await _userProfileRepository.getAgendas(limit: apiCallLimit, offset: currentState.agendas.length);

        final newAgendas = value['agendas'] as List<AgendaDetails>;

        emit(currentState.copyWith(agendas: [...currentState.agendas, ...newAgendas], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(currentState.copyWith(isError: true, exception: () => e));
        } else {
          emit(currentState.copyWith(isError: true, exception: () => ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreAgendas() {
    if (state is GetAgendaFetchSuccess) {
      final s = state as GetAgendaFetchSuccess;
      return s.total > s.agendas.length;
    }
    return false;
  }
}
