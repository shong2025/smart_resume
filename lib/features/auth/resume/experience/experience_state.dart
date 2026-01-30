import 'package:equatable/equatable.dart';
import '../models/experience_model.dart';

abstract class ExperienceState extends Equatable {
  const ExperienceState();

  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoaded extends ExperienceState {
  final List<Experience> experiences;
  const ExperienceLoaded(this.experiences);

  @override
  List<Object?> get props => [experiences];
}

class ExperienceSuccess extends ExperienceState {
  final String message;
  const ExperienceSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExperienceError extends ExperienceState {
  final String message;
  const ExperienceError(this.message);

  @override
  List<Object?> get props => [message];
}
