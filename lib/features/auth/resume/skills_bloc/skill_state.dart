import '../models/skill_model.dart';

abstract class SkillState {}

class SkillInitial extends SkillState {}

class SkillLoading extends SkillState {}

class SkillLoaded extends SkillState {
  final List<Skill> skills;
  SkillLoaded(this.skills);
}

class SkillActionSuccess extends SkillState {
  final String message;
  SkillActionSuccess(this.message);
}

class SkillError extends SkillState {
  final String message;
  SkillError(this.message);
}
