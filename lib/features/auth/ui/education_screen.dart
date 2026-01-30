import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/resume_repository.dart';
import '../resume/education/education_bloc.dart';
import '../resume/education/education_event.dart';
import '../resume/education/education_state.dart';
import '../resume/models/education_model.dart';

class EducationScreen extends StatefulWidget {
  final String resumeId;
  const EducationScreen({super.key, required this.resumeId});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _school = TextEditingController();
  final _degree = TextEditingController();
  final _startYear = TextEditingController();
  final _endYear = TextEditingController();

  Education? editingEducation;

  final Color primaryColor = const Color(0xFF4A90E2);
  final Color backgroundColor = const Color(0xFFF7F8FA);

  @override
  void dispose() {
    _school.dispose();
    _degree.dispose();
    _startYear.dispose();
    _endYear.dispose();
    super.dispose();
  }

  void _clearForm() {
    _school.clear();
    _degree.clear();
    _startYear.clear();
    _endYear.clear();
    setState(() {
      editingEducation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      EducationBloc(repository: ResumeRepository())
        ..add(LoadEducation(widget.resumeId)),
      child: BlocConsumer<EducationBloc, EducationState>(
        listener: (context, state) {
          if (state is EducationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _clearForm();
            context
                .read<EducationBloc>()
                .add(LoadEducation(widget.resumeId));
          }

          if (state is EducationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EducationLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final educations =
          state is EducationLoaded ? state.educations : <Education>[];

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: backgroundColor,
              centerTitle: true,
              title: const Text(
                'Education',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue,
                ),
              ),
              actions: [
                if (editingEducation != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: _clearForm,
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// ================= FORM CARD =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _field(_school, 'School'),
                          _field(_degree, 'Degree'),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  _startYear,
                                  'Start Year',
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field(
                                  _endYear,
                                  'End Year',
                                  isNumber: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) return;

                                final education = Education(
                                  id: editingEducation?.id,
                                  resumeId: widget.resumeId,
                                  school: _school.text.trim(),
                                  degree: _degree.text.trim(),
                                  startYear:
                                  int.tryParse(_startYear.text.trim()),
                                  endYear:
                                  int.tryParse(_endYear.text.trim()),
                                );

                                final bloc =
                                context.read<EducationBloc>();

                                if (editingEducation == null) {
                                  bloc.add(AddEducationEvent(education));
                                } else {
                                  bloc.add(UpdateEducationEvent(education));
                                }
                              },
                              child: Text(
                                editingEducation == null
                                    ? 'Add Education'
                                    : 'Update Education',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ================= LIST =================
                  Expanded(
                    child: educations.isEmpty
                        ? const Center(
                      child: Text(
                        'No education added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: educations.length,
                      itemBuilder: (context, index) {
                        final edu = educations[index];

                        return Container(
                          margin:
                          const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12),
                            title: Text(
                              edu.school,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.only(top: 4),
                              child: Text(
                                '${edu.degree ?? ''}\n'
                                    '${edu.startYear ?? ''} - ${edu.endYear ?? ''}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      editingEducation = edu;
                                      _school.text = edu.school;
                                      _degree.text =
                                          edu.degree ?? '';
                                      _startYear.text =
                                          edu.startYear
                                              ?.toString() ??
                                              '';
                                      _endYear.text =
                                          edu.endYear
                                              ?.toString() ??
                                              '';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<EducationBloc>()
                                        .add(
                                      DeleteEducationEvent(
                                          edu.id!),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool isNumber = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) =>
        v == null || v.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF2F4F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
