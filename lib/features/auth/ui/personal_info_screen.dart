import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/resume_repository.dart';
import '../resume/models/personal_info_model.dart';
import '../resume/person_bloc/personal_info_bloc.dart';
import '../resume/person_bloc/personal_info_event.dart';
import '../resume/person_bloc/personal_info_state.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String resumeId;
  const PersonalInfoScreen({super.key, required this.resumeId});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _job = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _summary = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _job.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalInfoBloc(
        repository: ResumeRepository(),
      )..add(LoadPersonalInfo(widget.resumeId)),
      child: BlocConsumer<PersonalInfoBloc, PersonalInfoState>(
        listener: (context, state) {
          if (state is PersonalInfoLoaded && state.info != null) {
            _name.text = state.info!.fullName;
            _job.text = state.info!.jobTitle;
            _email.text = state.info!.email;
            _phone.text = state.info!.phone;
            _address.text = state.info!.address;
            _summary.text = state.info!.summary;
          }

          if (state is PersonalInfoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Information saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is PersonalInfoError) {
            String errorMessage = state.message;
            if (errorMessage.contains('PGRST204')) {
              errorMessage = "Database error: 'address' column is missing in Supabase.";
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              title: const Text('Personal Information'),
              centerTitle: true,
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
            body: state is PersonalInfoLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _inputField(_name, 'Full Name', Icons.person),
                        _inputField(_job, 'Job Title', Icons.work),
                        _inputField(_email, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                        _inputField(_phone, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
                        _inputField(_address, 'Address', Icons.location_on),
                        _inputField(_summary, 'Professional Summary', Icons.description, maxLines: 4),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final info = PersonalInfo(
                                  id: state is PersonalInfoLoaded ? state.info?.id : null,
                                  resumeId: widget.resumeId,
                                  fullName: _name.text.trim(),
                                  jobTitle: _job.text.trim(),
                                  email: _email.text.trim(),
                                  phone: _phone.text.trim(),
                                  address: _address.text.trim(),
                                  summary: _summary.text.trim(),
                                );
                                context.read<PersonalInfoBloc>().add(SavePersonalInfo(info));
                              }
                            },
                            child: const Text('SAVE INFORMATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
