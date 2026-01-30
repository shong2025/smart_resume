

import '../models/education_model.dart';

abstract class EducationState {}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoaded extends EducationState {
  final List<Education> educations;
  EducationLoaded(this.educations);
}

class EducationError extends EducationState {
  final String message;
  EducationError(this.message);
}

class EducationActionSuccess extends EducationState {}
