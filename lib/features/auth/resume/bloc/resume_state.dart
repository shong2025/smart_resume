import '../models/resume_model.dart';

abstract class ResumeState {}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumeLoaded extends ResumeState {
  final List<Resume> resumes;
  ResumeLoaded(this.resumes);
}

class ResumeActionSuccess extends ResumeState {}

class ResumeError extends ResumeState {
  final String message;
  ResumeError(this.message);
}
