import '../models/personal_info_model.dart';

abstract class PersonalInfoEvent {}

class LoadPersonalInfo extends PersonalInfoEvent {
  final String resumeId;
  LoadPersonalInfo(this.resumeId);
}

class SavePersonalInfo extends PersonalInfoEvent {
  final PersonalInfo info;
  SavePersonalInfo(this.info);
}
