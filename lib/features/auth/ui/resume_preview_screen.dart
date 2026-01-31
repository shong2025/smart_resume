import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../Repository/attachment_repository.dart';
import '../resume/attachment_bloc/attachment_bloc.dart';
import '../resume/attachment_bloc/attachment_event.dart';
import '../resume/attachment_bloc/attachment_state.dart';
import '../resume/models/resume_model.dart';
import '../Repository/resume_repository.dart';
import '../Repository/summary_repository.dart';

// Resume blocs
import '../resume/person_bloc/personal_info_bloc.dart';
import '../resume/person_bloc/personal_info_event.dart';
import '../resume/person_bloc/personal_info_state.dart';

import '../resume/experience/experience_bloc.dart';
import '../resume/experience/experience_event.dart';
import '../resume/experience/experience_state.dart';

import '../resume/education/education_bloc.dart';
import '../resume/education/education_event.dart';
import '../resume/education/education_state.dart';

import '../resume/skills_bloc/skill_bloc.dart';
import '../resume/skills_bloc/skill_event.dart';
import '../resume/skills_bloc/skill_state.dart';

import '../resume/summary_bloc/summary_bloc.dart';
import '../resume/summary_bloc/summary_event.dart';
import '../resume/summary_bloc/summary_state.dart';

class ResumeFullPreviewScreen extends StatelessWidget {
  final Resume resume;

  const ResumeFullPreviewScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    final resumeRepo = ResumeRepository();
    final summaryRepo = SummaryRepository();
    final attachmentRepo = AttachmentRepository();
    final rid = resume.id!;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PersonalInfoBloc(repository: resumeRepo)..add(LoadPersonalInfo(rid))),
        BlocProvider(create: (_) => ExperienceBloc(repository: resumeRepo)..add(LoadExperiences(rid))),
        BlocProvider(create: (_) => EducationBloc(repository: resumeRepo)..add(LoadEducation(rid))),
        BlocProvider(create: (_) => SkillBloc(repository: resumeRepo)..add(LoadSkills(rid))),
        BlocProvider(create: (_) => SummaryBloc(summaryRepo)..add(LoadSummary(rid))),
        BlocProvider(create: (_) => AttachmentBloc(attachmentRepo)..add(LoadAttachments(rid))),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF525659),
            appBar: AppBar(
              title: const Text('Resume Professional Preview'),
              backgroundColor: const Color(0xFF202124),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => _generateAndPrintPdf(context),
                  tooltip: 'Export to PDF',
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<PersonalInfoBloc>().add(LoadPersonalInfo(rid));
                context.read<ExperienceBloc>().add(LoadExperiences(rid));
                context.read<EducationBloc>().add(LoadEducation(rid));
                context.read<SkillBloc>().add(LoadSkills(rid));
                context.read<SummaryBloc>().add(LoadSummary(rid));
                context.read<AttachmentBloc>().add(LoadAttachments(rid));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12 : 30,
                  horizontal: isMobile ? 10 : 20,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 850),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isMobile
                        ? Column(
                      children: [
                        _buildSidebar(context, true),
                        _buildMainContent(context),
                      ],
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebar(context, false),
                        Expanded(child: _buildMainContent(context)),
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

  /* ====================== UI CONTENT ====================== */

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PROFILE'),
          BlocBuilder<SummaryBloc, SummaryState>(
            builder: (_, state) {
              if (state is SummaryLoaded && state.summary != null) {
                return Text(state.summary!.content, style: const TextStyle(fontSize: 13, height: 1.6));
              }
              return const Text('No summary available.');
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle('EXPERIENCE'),
          BlocBuilder<ExperienceBloc, ExperienceState>(
            builder: (_, state) {
              if (state is ExperienceLoaded && state.experiences.isNotEmpty) {
                return Column(
                  children: state.experiences.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.position, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(e.company, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                      ],
                    ),
                  )).toList(),
                );
              }
              return const Text('No experience added.');
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle('EDUCATION'),
          BlocBuilder<EducationBloc, EducationState>(
            builder: (_, state) {
              if (state is EducationLoaded && state.educations.isNotEmpty) {
                return Column(
                  children: state.educations.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.school, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(e.degree ?? '', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )).toList(),
                );
              }
              return const Text('No education added.');
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle('ATTACHMENTS '),
          BlocBuilder<AttachmentBloc, AttachmentState>(
            builder: (context, state) {
              if (state is AttachmentLoading) return const LinearProgressIndicator();
              if (state is AttachmentLoaded && state.attachments.isNotEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.attachments.length,
                  itemBuilder: (context, index) {
                    final url = state.attachments[index].imageUrl;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Text('No attachments added yet.', style: TextStyle(color: Colors.grey));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF2C3E50),
      child: BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
        builder: (_, state) {
          if (state is PersonalInfoLoaded && state.info != null) {
            final i = state.info!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.fullName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(i.jobTitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const Divider(color: Colors.white24, height: 30),
                _sidebarInfo(Icons.email, i.email),
                _sidebarInfo(Icons.phone, i.phone),
                _sidebarInfo(Icons.location_on, i.address),
                const SizedBox(height: 30),
                const Text('SKILLS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const Divider(color: Colors.white24),
                BlocBuilder<SkillBloc, SkillState>(
                  builder: (_, sState) {
                    if (sState is SkillLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sState.skills.map((s) => Text('• ${s.name}', style: const TextStyle(color: Colors.white70, fontSize: 12))).toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      ),
    );
  }

  /* ====================== PDF EXPORT ====================== */

  Future<void> _generateAndPrintPdf(BuildContext context) async {
    final pdf = pw.Document();

    // جلب البيانات الحالية من الحالات
    final personal = context.read<PersonalInfoBloc>().state;
    final summary = context.read<SummaryBloc>().state;
    final experience = context.read<ExperienceBloc>().state;
    final education = context.read<EducationBloc>().state;
    final skill = context.read<SkillBloc>().state;
    final attachment = context.read<AttachmentBloc>().state;

    // تحميل الصور مع تحديد جودة منخفضة لتجنب Loop الصفحات
    List<pw.ImageProvider> pdfImages = [];
    if (attachment is AttachmentLoaded) {
      for (var attr in attachment.attachments) {
        if (attr.imageUrl.isNotEmpty) {
          try {
            final img = await networkImage(attr.imageUrl);
            pdfImages.add(img);
          } catch (e) {
            debugPrint('PDF image load error: $e');
          }
        }
      }
    }

    // تحميل خط يدعم Unicode لتجنب أخطاء Helvetica
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context pdfCtx) => [
          // Header
          if (personal is PersonalInfoLoaded && personal.info != null) ...[
            pw.Text(personal.info!.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text(personal.info!.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            pw.SizedBox(height: 10),
            pw.Text('Email: ${personal.info!.email} | Phone: ${personal.info!.phone}', style: const pw.TextStyle(fontSize: 10)),
            pw.Divider(),
          ],
          
          // Content
          if (summary is SummaryLoaded && summary.summary != null) ...[
            _pdfHeader('PROFILE'),
            pw.Text(summary.summary!.content, style: const pw.TextStyle(fontSize: 11)),
          ],
          if (experience is ExperienceLoaded && experience.experiences.isNotEmpty) ...[
            _pdfHeader('EXPERIENCE'),
            ...experience.experiences.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.position, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(e.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey)),
                ],
              ),
            )),
          ],
          if (education is EducationLoaded && education.educations.isNotEmpty) ...[
            _pdfHeader('EDUCATION'),
            ...education.educations.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(e.degree ?? '', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            )),
          ],
          if (skill is SkillLoaded && skill.skills.isNotEmpty) ...[
            _pdfHeader('SKILLS'),
            pw.Text(skill.skills.map((s) => s.name).join(', '), style: const pw.TextStyle(fontSize: 11)),
          ],

          // Images (Fixed to avoid TooManyPagesException)
          if (pdfImages.isNotEmpty) ...[
            pw.NewPage(),
            _pdfHeader('CERTIFICATES & ATTACHMENTS'),
            pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: pdfImages.map((img) => pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Image(img, fit: pw.BoxFit.contain),
              )).toList(),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resume_${resume.title}.pdf',
    );
  }

  /* ====================== UTILS ====================== */

  Widget _sidebarInfo(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, color: Colors.white54, size: 14),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11))),
    ]),
  );

  Widget _sectionTitle(String title) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      const Divider(thickness: 1),
      const SizedBox(height: 8),
    ],
  );

  pw.Widget _pdfHeader(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 15),
      pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
      pw.Divider(thickness: 0.5),
      pw.SizedBox(height: 5),
    ],
  );
}
