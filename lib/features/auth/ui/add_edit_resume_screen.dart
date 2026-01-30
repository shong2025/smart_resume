import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Repository/resume_repository.dart';
import '../resume/bloc/resume_bloc.dart';
import '../resume/bloc/resume_event.dart';
import '../resume/bloc/resume_state.dart';
import '../resume/models/resume_model.dart';
import 'dashboard_screen.dart';

class AddEditResumeScreen extends StatefulWidget {
  final Resume? resume;

  const AddEditResumeScreen({super.key, this.resume});

  @override
  State<AddEditResumeScreen> createState() => _AddEditResumeScreenState();
}

class _AddEditResumeScreenState extends State<AddEditResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.resume?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.resume != null;

    return BlocProvider(
      create: (_) => ResumeBloc(repository: ResumeRepository()),
      child: BlocListener<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? 'The resume has been successfully updated.'
                      : 'The resume was successfully added.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // بعد الحفظ نرجع إلى Dashboard ونعيد تحميل البيانات
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
            );
          }

          if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.grey[300],
            elevation: 0,
            title: Text(
              isEditing ? 'Edit CV': 'Add CV',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Card Form
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Title Field
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'title',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter the address'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          BlocBuilder<ResumeBloc, ResumeState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: state is ResumeLoading
                                      ? null
                                      : () {
                                    if (!_formKey.currentState!
                                        .validate()) return;

                                    final user = Supabase
                                        .instance.client.auth.currentUser;

                                    if (user == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'You must log in first.'),
                                        ),
                                      );
                                      return;
                                    }

                                    final resume = Resume(
                                      id: widget.resume?.id,
                                      userId: user.id,
                                      title: _titleController.text.trim(),
                                    );

                                    if (isEditing) {
                                      context.read<ResumeBloc>().add(
                                          UpdateResumeEvent(resume));
                                    } else {
                                      context
                                          .read<ResumeBloc>()
                                          .add(AddResumeEvent(resume));
                                    }
                                  },
                                  child: state is ResumeLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Text(
                                    isEditing ? 'update' : 'save',
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900 ,color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
