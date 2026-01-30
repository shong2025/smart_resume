import '../models/resume_model.dart';

abstract class ResumeEvent {}

class LoadResumes extends ResumeEvent {}

class AddResumeEvent extends ResumeEvent {
  final Resume resume;
  AddResumeEvent(this.resume);
}

class UpdateResumeEvent extends ResumeEvent {
  final Resume resume;
  UpdateResumeEvent(this.resume);
}

class DeleteResumeEvent extends ResumeEvent {
  final String id;
  DeleteResumeEvent(this.id);
}
