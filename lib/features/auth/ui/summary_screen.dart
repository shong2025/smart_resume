import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Repository/summary_repository.dart';
import '../resume/models/summary_model.dart';
import '../resume/summary_bloc/summary_bloc.dart';
import '../resume/summary_bloc/summary_event.dart';
import '../resume/summary_bloc/summary_state.dart';

class SummaryScreen extends StatefulWidget {
  final String resumeId;

  const SummaryScreen({super.key, required this.resumeId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? summaryId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SummaryBloc(SummaryRepository())..add(LoadSummary(widget.resumeId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Professional Summary'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: BlocConsumer<SummaryBloc, SummaryState>(
          listener: (context, state) {
            if (state is SummaryLoaded && state.summary != null) {
              summaryId = state.summary!.id;
              // فقط حدث النص إذا كان فارغاً لتجنب مسح كتابة المستخدم أثناء الحفظ
              if (_controller.text.isEmpty) {
                _controller.text = state.summary!.content;
              }
            }

            if (state is SummarySaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Summary saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (state is SummaryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tell us about yourself',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Write a short professional summary that highlights your experience, skills, and career goals.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _controller,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                hintText:
                                    'Example:\nFlutter Developer with 3+ years of experience building scalable mobile applications...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Save Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: state is SummaryLoading
                                ? null
                                : () {
                                    if (_controller.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Summary cannot be empty'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    final summary = Summary(
                                      id: summaryId,
                                      resumeId: widget.resumeId,
                                      content: _controller.text.trim(),
                                    );

                                    context
                                        .read<SummaryBloc>()
                                        .add(SaveSummary(summary));
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is SummaryLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}
