import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/resume_repository.dart';
import '../resume/models/skill_model.dart';
import '../resume/skills_bloc/skill_bloc.dart';
import '../resume/skills_bloc/skill_event.dart';
import '../resume/skills_bloc/skill_state.dart';


class SkillsScreen extends StatefulWidget {
  final String resumeId;
  const SkillsScreen({super.key, required this.resumeId});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  int _level = 3;

  Skill? editingSkill;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _level = 3;
    editingSkill = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillBloc(
        repository: ResumeRepository(),
      )..add(LoadSkills(widget.resumeId)),
      child: BlocConsumer<SkillBloc, SkillState>(
        listener: (context, state) {
          if (state is SkillActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade400,
              ),
            );

            _clearForm();
            context.read<SkillBloc>().add(
              LoadSkills(widget.resumeId),
            );
          }

          if (state is SkillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade400,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SkillLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final skills =
          state is SkillLoaded ? state.skills : <Skill>[];

          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FC),
            appBar: AppBar(
              title: const Text('Skills'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
              actions: [
                if (editingSkill != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearForm,
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// =============================
                  /// FORM
                  /// =============================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            editingSkill == null
                                ? 'Add Skill'
                                : 'Edit Skill',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// Skill Name
                          TextFormField(
                            controller: _nameController,
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              labelText: 'Skill name',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Level
                          Text(
                            'Level: $_level / 5',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            value: _level.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            activeColor: Colors.blueAccent,
                            label: _level.toString(),
                            onChanged: (v) {
                              setState(() {
                                _level = v.toInt();
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) return;

                                final skill = Skill(
                                  id: editingSkill?.id,
                                  resumeId: widget.resumeId,
                                  name: _nameController.text.trim(),
                                  level: _level,
                                );

                                final bloc =
                                context.read<SkillBloc>();

                                if (editingSkill == null) {
                                  bloc.add(AddSkillEvent(skill));
                                } else {
                                  bloc.add(UpdateSkillEvent(skill));
                                }
                              },
                              child: Text(
                                editingSkill == null
                                    ? 'Add Skill'
                                    : 'Update Skill',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// =============================
                  /// LIST
                  /// =============================
                  Expanded(
                    child: skills.isEmpty
                        ? const Center(
                      child: Text('No skills added yet'),
                    )
                        : ListView.separated(
                      itemCount: skills.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final skill = skills[index];

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skill.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: skill.level / 5,
                                      backgroundColor:
                                      Colors.grey.shade200,
                                      color: Colors.blueAccent,
                                      minHeight: 6,
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    editingSkill = skill;
                                    _nameController.text = skill.name;
                                    _level = skill.level;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  context
                                      .read<SkillBloc>()
                                      .add(DeleteSkillEvent(skill.id!));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
