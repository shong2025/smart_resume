import '../models/skill_model.dart';

abstract class SkillEvent {}

class LoadSkills extends SkillEvent {
  final String resumeId;
  LoadSkills(this.resumeId);
}

class AddSkillEvent extends SkillEvent {
  final Skill skill;
  AddSkillEvent(this.skill);
}

class UpdateSkillEvent extends SkillEvent {
  final Skill skill;
  UpdateSkillEvent(this.skill);
}

class DeleteSkillEvent extends SkillEvent {
  final String id;
  DeleteSkillEvent(this.id);
}
