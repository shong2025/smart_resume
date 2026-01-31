import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Repository/resume_repository.dart';
import '../resume/bloc/resume_bloc.dart';
import '../resume/bloc/resume_event.dart';
import '../resume/bloc/resume_state.dart';
import '../resume/models/resume_model.dart';
import 'add_edit_resume_screen.dart';
import 'personal_info_screen.dart';
import 'experiences_screen.dart';
import 'education_screen.dart';
import 'resume_attachments_screen.dart';
import 'skills_screen.dart';
import 'summary_screen.dart';
import 'resume_preview_screen.dart';

/// ✅ DashboardScreen: Main Hub for All Resumes
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResumeBloc(repository: ResumeRepository())..add(LoadResumes()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          title: const Text(
            '📄 My Resumes',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: Color(0xFF1A237E), letterSpacing: 0.5),
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          surfaceTintColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF21CBF3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: IconButton.filledTonal(
                icon: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_circle_outline, size: 22),
                  SizedBox(width: 6),
                  Text('New', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ]),
                onPressed: () async {
                  final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddEditResumeScreen()));
                  if (result == true && context.mounted) context.read<ResumeBloc>().add(LoadResumes());
                },
                style: IconButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 16)),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ResumeBloc, ResumeState>(
          listener: (context, state) {
            if (state is ResumeActionSuccess) {
              context.read<ResumeBloc>().add(LoadResumes());
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 8), Text('Operation completed successfully')]),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ));
            }
            if (state is ResumeError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 20), const SizedBox(width: 8), Expanded(child: Text(state.message))]),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ));
            }
          },
          builder: (context, state) {
            if (state is ResumeLoading) {
              return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF2196F3).withValues(alpha: 0.8)), backgroundColor: Colors.blue.withValues(alpha: 0.1))),
                  const SizedBox(height: 20),
                  Text('Loading Your Resumes', style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                ]),
              );
            }

            if (state is ResumeLoaded) {
              if (state.resumes.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.description_outlined, size: 80, color: Colors.blue.withValues(alpha: 0.2)),
                    const SizedBox(height: 20),
                    const Text('📝 No Resumes Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddEditResumeScreen()));
                        if (result == true && context.mounted) context.read<ResumeBloc>().add(LoadResumes());
                      },
                      child: const Text('Create First Resume'),
                    )
                  ]),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: crossAxisCount == 1 ? 1.4 : 0.72),
                      itemCount: state.resumes.length,
                      itemBuilder: (context, index) {
                        return _AnimatedResumeCard(resume: state.resumes[index]);
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _AnimatedResumeCard extends StatefulWidget {
  final Resume resume;
  const _AnimatedResumeCard({required this.resume});
  @override
  State<_AnimatedResumeCard> createState() => _AnimatedResumeCardState();
}

class _AnimatedResumeCardState extends State<_AnimatedResumeCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0)..scale(_isHovered ? 1.01 : 1.0),
        curve: Curves.easeInOut,
        child: ResumeCard(resume: widget.resume),
      ),
    );
  }
}

class ResumeCard extends StatelessWidget {
  final Resume resume;
  const ResumeCard({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    final resumeBloc = context.read<ResumeBloc>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1.5)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF21CBF3)]), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(resume.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('T${resume.templateId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionButton(context, Icons.person_outline, 'Personal', PersonalInfoScreen(resumeId: resume.id!)),
                      _actionButton(context, Icons.work_outline, 'Experience', ExperiencesScreen(resumeId: resume.id!)),
                      _actionButton(context, Icons.school_outlined, 'Education', EducationScreen(resumeId: resume.id!)),
                      _actionButton(context, Icons.star_outline, 'Skills', SkillsScreen(resumeId: resume.id!)),
                      _actionButton(context, Icons.summarize_outlined, 'Summary', SummaryScreen(resumeId: resume.id!)),
                      /// ✅ الربط بشاشة المعاينة الاحترافية
                      _actionButton(context, Icons.visibility_outlined, 'Preview', ResumeFullPreviewScreen(resume: resume)),
                      _actionButton(
                        context,
                        Icons.image_outlined,
                        'Attachments',
                        ResumeAttachmentsScreen(resumeId: resume.id!),
                      ),

                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddEditResumeScreen(resume: resume)));
                          if (result == true) resumeBloc.add(LoadResumes());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, resumeBloc),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withValues(alpha: 0.15))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 16, color: Colors.blue), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue))],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ResumeBloc resumeBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.delete_outline, color: Colors.red, size: 28), SizedBox(width: 12), Text('Delete Resume', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))],
        ),
        content: Text('Are you sure you want to delete "${resume.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              resumeBloc.add(DeleteResumeEvent(resume.id!));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
