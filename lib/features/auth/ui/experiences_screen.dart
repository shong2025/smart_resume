import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/resume_repository.dart';
import '../resume/experience/experience_bloc.dart';
import '../resume/experience/experience_event.dart';
import '../resume/experience/experience_state.dart';
import '../resume/models/experience_model.dart';

class ExperiencesScreen extends StatefulWidget {
  final String resumeId;
  const ExperiencesScreen({super.key, required this.resumeId});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExperienceBloc(repository: ResumeRepository())
        ..add(LoadExperiences(widget.resumeId)),
      child: BlocConsumer<ExperienceBloc, ExperienceState>(
        listener: (context, state) {
          if (state is ExperienceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is ExperienceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExperienceLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final experiences =
          state is ExperienceLoaded ? state.experiences : <Experience>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Experiences',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.grey[200],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// LIST + SCROLLBAR
                  Expanded(
                    child: experiences.isEmpty
                        ? const Center(
                      child: Text(
                        'No experiences added yet',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                        : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(12),
                      thickness: 6,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: experiences.length,
                        itemBuilder: (context, index) {
                          final exp = experiences[index];

                          return Card(
                            margin:
                            const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                exp.position,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${exp.company}\n'
                                    '${exp.startDate != null ? exp.startDate!.toLocal().toShortDate() : '-'}'
                                    ' - '
                                    '${exp.endDate != null ? exp.endDate!.toLocal().toShortDate() : '-'}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final updated =
                                      await showDialog<Experience>(
                                        context: context,
                                        builder: (_) =>
                                            ExperienceDialog(
                                              resumeId: widget.resumeId,
                                              experience: exp,
                                            ),
                                      );

                                      if (updated != null) {
                                        context
                                            .read<ExperienceBloc>()
                                            .add(
                                          UpdateExperienceEvent(
                                              updated),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<ExperienceBloc>()
                                          .add(
                                        DeleteExperienceEvent(
                                            exp.id!),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ADD BUTTON
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newExp = await showDialog<Experience>(
                        context: context,
                        builder: (_) => ExperienceDialog(
                          resumeId: widget.resumeId,
                        ),
                      );

                      if (newExp != null) {
                        context
                            .read<ExperienceBloc>()
                            .add(AddExperienceEvent(newExp));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Experience',
                      style: TextStyle(fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: Colors.grey[300],
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

/// =======================
/// Dialog Form
/// =======================
class ExperienceDialog extends StatefulWidget {
  final String resumeId;
  final Experience? experience;

  const ExperienceDialog({
    super.key,
    required this.resumeId,
    this.experience,
  });

  @override
  State<ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<ExperienceDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.experience?.company ?? '');
    _positionController =
        TextEditingController(text: widget.experience?.position ?? '');
    _descriptionController =
        TextEditingController(text: widget.experience?.description ?? '');
    _startDate = widget.experience?.startDate;
    _endDate = widget.experience?.endDate;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? _startDate ?? DateTime.now()
        : _endDate ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experience != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Experience' : 'Add Experience'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      child: InputDecorator(
                        decoration:
                        const InputDecoration(labelText: 'Start Date'),
                        child: Text(
                          _startDate != null
                              ? _startDate!.toLocal().toShortDate()
                              : 'Select',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration:
                        const InputDecoration(labelText: 'End Date'),
                        child: Text(
                          _endDate != null
                              ? _endDate!.toLocal().toShortDate()
                              : 'Select',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration:
                const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final exp = Experience(
              id: widget.experience?.id,
              resumeId: widget.resumeId,
              company: _companyController.text,
              position: _positionController.text,
              startDate: _startDate,
              endDate: _endDate,
              description: _descriptionController.text,
            );

            Navigator.pop(context, exp);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// =======================
/// Date Extension
/// =======================
extension DateFormatting on DateTime {
  String toShortDate() =>
      '${day.toString().padLeft(2, '0')}/'
          '${month.toString().padLeft(2, '0')}/'
          '$year';
}
