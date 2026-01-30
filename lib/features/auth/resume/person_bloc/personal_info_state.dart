import '../models/personal_info_model.dart';

abstract class PersonalInfoState {}

class PersonalInfoInitial extends PersonalInfoState {}

class PersonalInfoLoading extends PersonalInfoState {}

class PersonalInfoLoaded extends PersonalInfoState {
  final PersonalInfo? info;
  PersonalInfoLoaded(this.info);
}

class PersonalInfoSuccess extends PersonalInfoState {}

class PersonalInfoError extends PersonalInfoState {
  final String message;
  PersonalInfoError(this.message);
}
