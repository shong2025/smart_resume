

import '../models/education_model.dart';

abstract class EducationEvent {}

class LoadEducation extends EducationEvent {
  final String resumeId;
  LoadEducation(this.resumeId);
}

class AddEducationEvent extends EducationEvent {
  final Education education;
  AddEducationEvent(this.education);
}

class UpdateEducationEvent extends EducationEvent {
  final Education education;
  UpdateEducationEvent(this.education);
}

class DeleteEducationEvent extends EducationEvent {
  final String id;
  DeleteEducationEvent(this.id);
}
