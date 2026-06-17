import 'package:omkar_sale/commons/models/agenda_details.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class SetAgendaNotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetAgendaNotesInitial extends SetAgendaNotesState {}

class SetAgendaNotesInProgress extends SetAgendaNotesState {}

class SetAgendaNotesFetchSuccess extends SetAgendaNotesState {
  SetAgendaNotesFetchSuccess({
    required this.agenda,
  });
  final AgendaDetails agenda;

  SetAgendaNotesFetchSuccess copyWith({AgendaDetails? agenda}) {
    return SetAgendaNotesFetchSuccess(agenda: agenda ?? this.agenda);
  }

  @override
  List<Object?> get props => [agenda];
}

class SetAgendaNotesFetchFailure extends SetAgendaNotesState {
  SetAgendaNotesFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class SetAgendaNotesCubit extends Cubit<SetAgendaNotesState> {
  SetAgendaNotesCubit() : super(SetAgendaNotesInitial());
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  Future<void> setAgendaNotes({required int agendaId, required String agendaTitle}) async {
    emit(SetAgendaNotesInProgress());
    try {
      final value = await _userProfileRepository.setAgendas(agendaId: agendaId, agendaTitle: agendaTitle);

      emit(SetAgendaNotesFetchSuccess(agenda: value));
    } catch (e) {
      if (e is ApiException) {
        emit(SetAgendaNotesFetchFailure(exception: e));
      } else {
        emit(SetAgendaNotesFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
