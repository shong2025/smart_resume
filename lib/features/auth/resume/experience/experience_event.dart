import 'package:equatable/equatable.dart';
import '../models/experience_model.dart';

abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

class LoadExperiences extends ExperienceEvent {
  final String resumeId;
  const LoadExperiences(this.resumeId);

  @override
  List<Object?> get props => [resumeId];
}

class AddExperienceEvent extends ExperienceEvent {
  final Experience experience;
  const AddExperienceEvent(this.experience);

  @override
  List<Object?> get props => [experience];
}

class UpdateExperienceEvent extends ExperienceEvent {
  final Experience experience;
  const UpdateExperienceEvent(this.experience);

  @override
  List<Object?> get props => [experience];
}

class DeleteExperienceEvent extends ExperienceEvent {
  final String id;
  const DeleteExperienceEvent(this.id);

  @override
  List<Object?> get props => [id];
}
