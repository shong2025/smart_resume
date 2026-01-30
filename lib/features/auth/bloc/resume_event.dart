import 'package:equatable/equatable.dart';
import '../resume/models/resume_model.dart';

abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

class LoadResumes extends ResumeEvent {}

class AddResumeEvent extends ResumeEvent {
  final Resume resume;
  const AddResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}

class UpdateResumeEvent extends ResumeEvent {
  final Resume resume;
  const UpdateResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}

class DeleteResumeEvent extends ResumeEvent {
  final String id;
  const DeleteResumeEvent(this.id);

  @override
  List<Object?> get props => [id];
}
