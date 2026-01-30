import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repository/resume_repository.dart';
import 'personal_info_event.dart';
import 'personal_info_state.dart';

class PersonalInfoBloc
    extends Bloc<PersonalInfoEvent, PersonalInfoState> {
  final ResumeRepository repository;

  PersonalInfoBloc({required this.repository})
      : super(PersonalInfoInitial()) {
    on<LoadPersonalInfo>(_load);
    on<SavePersonalInfo>(_save);
  }

  Future<void> _load(
      LoadPersonalInfo event,
      Emitter<PersonalInfoState> emit,
      ) async {
    emit(PersonalInfoLoading());
    try {
      final info = await repository.getPersonalInfo(event.resumeId);
      emit(PersonalInfoLoaded(info));
    } catch (e) {
      emit(PersonalInfoError(e.toString()));
    }
  }

  Future<void> _save(
      SavePersonalInfo event,
      Emitter<PersonalInfoState> emit,
      ) async {
    emit(PersonalInfoLoading());
    try {
      if (event.info.id == null) {
        await repository.addPersonalInfo(event.info);
      } else {
        await repository.updatePersonalInfo(event.info);
      }
      emit(PersonalInfoSuccess());
    } catch (e) {
      emit(PersonalInfoError(e.toString()));
    }
  }
}
