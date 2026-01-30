import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../resume/models/resume_model.dart';
import '../Repository/resume_repository.dart';
import '../Repository/summary_repository.dart';

// Blocs
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
    final rid = resume.id!;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PersonalInfoBloc(repository: resumeRepo)..add(LoadPersonalInfo(rid))),
        BlocProvider(create: (_) => ExperienceBloc(repository: resumeRepo)..add(LoadExperiences(rid))),
        BlocProvider(create: (_) => EducationBloc(repository: resumeRepo)..add(LoadEducation(rid))),
        BlocProvider(create: (_) => SkillBloc(repository: resumeRepo)..add(LoadSkills(rid))),
        BlocProvider(create: (_) => SummaryBloc(summaryRepo)..add(LoadSummary(rid))),
      ],
      child: Builder( // ✅ توفير context جديد للوصول للـ Blocs
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFF525659),
              appBar: AppBar(
                title: const Text('Resume Preview'),
                backgroundColor: const Color(0xFF202124),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.print),
                    tooltip: 'Print or Save as PDF',
                    onPressed: () => _generateAndPrintPdf(context),
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
                },
                child: SingleChildScrollView(
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
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: isMobile
                          ? Column(
                        children: [
                          _buildSidebar(context, true),
                          _buildMainContent(context, true),
                        ],
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSidebar(context, false),
                          Expanded(child: _buildMainContent(context, false)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  /* ====================== PDF GENERATION ====================== */

  Future<void> _generateAndPrintPdf(BuildContext context) async {
    final pdf = pw.Document();

    final personalState = context.read<PersonalInfoBloc>().state;
    final summaryState = context.read<SummaryBloc>().state;
    final skillState = context.read<SkillBloc>().state;
    final expState = context.read<ExperienceBloc>().state;
    final eduState = context.read<EducationBloc>().state;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (personalState is PersonalInfoLoaded && personalState.info != null) ...[
                pw.Text(
                  personalState.info!.fullName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                ),
                pw.Text(
                  personalState.info!.jobTitle,
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey700),
                ),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Text(personalState.info!.email, style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(width: 10),
                  pw.Text(personalState.info!.phone, style: const pw.TextStyle(fontSize: 9)),
                ]),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 15),
              ],

              _pdfSectionTitle('Profile'),
              if (summaryState is SummaryLoaded && summaryState.summary != null)
                pw.Text(summaryState.summary!.content, style: const pw.TextStyle(fontSize: 10)),

              _pdfSectionTitle('Skills'),
              if (skillState is SkillLoaded && skillState.skills.isNotEmpty)
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: skillState.skills.map((s) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                    child: pw.Text(s.name, style: const pw.TextStyle(fontSize: 9)),
                  )).toList(),
                ),

              _pdfSectionTitle('Experience'),
              if (expState is ExperienceLoaded)
                ...expState.experiences.map((e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(e.position, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text('${e.startDate?.year ?? ""} - ${e.endDate?.year ?? "Present"}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                      pw.Text(e.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700)),
                    ],
                  ),
                )),

              _pdfSectionTitle('Education'),
              if (eduState is EducationLoaded)
                ...eduState.educations.map((e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${e.degree ?? "Degree"} - ${e.school}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('${e.startYear} - ${e.endYear ?? "Present"}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                )),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resume_${resume.title}.pdf',
    );
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        pw.Divider(thickness: 0.5, color: PdfColors.blueGrey900),
        pw.SizedBox(height: 5),
      ],
    );
  }

  /* ====================== UI WIDGETS ====================== */

  Widget _buildSidebar(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF2C3E50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CONTACT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
          const Divider(color: Colors.white24, thickness: 1, height: 20),
          BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
            builder: (context, state) {
              if (state is PersonalInfoLoaded && state.info != null) {
                final i = state.info!;
                return Column(
                  children: [
                    _sidebarItem(Icons.email, i.email),
                    _sidebarItem(Icons.phone, i.phone),
                    _sidebarItem(Icons.location_on, i.address),
                  ],
                );
              }
              return const Text('Loading...', style: TextStyle(color: Colors.white70));
            },
          ),
          const SizedBox(height: 30),
          const Text('SKILLS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
          const Divider(color: Colors.white24, thickness: 1, height: 20),
          BlocBuilder<SkillBloc, SkillState>(
            builder: (context, state) {
              if (state is SkillLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.skills.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${s.name}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  )).toList(),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
            builder: (context, state) {
              if (state is PersonalInfoLoaded && state.info != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.info!.fullName.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
                    Text(state.info!.jobTitle.toUpperCase(), style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle('PROFILE'),
          BlocBuilder<SummaryBloc, SummaryState>(
            builder: (_, state) => state is SummaryLoaded ? Text(state.summary?.content ?? '', style: const TextStyle(fontSize: 13, height: 1.5)) : const SizedBox(),
          ),
          const SizedBox(height: 30),
          _sectionTitle('EXPERIENCE'),
          BlocBuilder<ExperienceBloc, ExperienceState>(
            builder: (_, state) {
              if (state is ExperienceLoaded) {
                return Column(
                  children: state.experiences.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.position, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${e.startDate?.year ?? ""} - ${e.endDate?.year ?? "Present"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Text(e.company, style: const TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  )).toList(),
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 30),
          _sectionTitle('EDUCATION'),
          BlocBuilder<EducationBloc, EducationState>(
            builder: (_, state) {
              if (state is EducationLoaded) {
                return Column(
                  children: state.educations.map((e) => Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.school, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${e.startYear} - ${e.endYear ?? "Present"}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Text(e.degree ?? 'Degree', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            const SizedBox(height: 10),
                          ]
                      )
                  )).toList(),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const Divider(color: Color(0xFF2C3E50), thickness: 2),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _sidebarItem(IconData icon, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }
}