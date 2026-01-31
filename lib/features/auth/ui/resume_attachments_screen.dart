import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../Repository/attachment_repository.dart';
import '../resume/attachment_bloc/attachment_bloc.dart';
import '../resume/attachment_bloc/attachment_event.dart';
import '../resume/attachment_bloc/attachment_state.dart';

class ResumeAttachmentsScreen extends StatelessWidget {
  final String resumeId;

  const ResumeAttachmentsScreen({
    super.key,
    required this.resumeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttachmentBloc(AttachmentRepository())
        ..add(LoadAttachments(resumeId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              title: const Text(
                'Resume Attachments',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<AttachmentBloc>().add(LoadAttachments(resumeId)),
                )
              ],
            ),

            floatingActionButton: BlocBuilder<AttachmentBloc, AttachmentState>(
              builder: (context, state) {
                return FloatingActionButton(
                  backgroundColor: state is AttachmentLoading ? Colors.grey : const Color(0xFF5C6BC0),
                  onPressed: state is AttachmentLoading
                      ? null
                      : () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );

                    if (picked != null && context.mounted) {
                      context.read<AttachmentBloc>().add(UploadAttachment(resumeId, picked.path));
                    }
                  },
                  child: state is AttachmentLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add, color: Colors.white),
                );
              },
            ),

            body: BlocConsumer<AttachmentBloc, AttachmentState>(
              listener: (context, state) {
                if (state is AttachmentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('⚠️ ${state.message}'), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is AttachmentLoading && state is! AttachmentLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AttachmentLoaded) {
                  if (state.attachments.isEmpty) {
                    return const _EmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AttachmentBloc>().add(LoadAttachments(resumeId));
                    },
                    // ✅ تم تغيير GridView إلى ListView لعرض الصور تحت بعضها
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = state.attachments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _AttachmentCard(imageUrl: attachment.imageUrl),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No attachments yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54)),
          SizedBox(height: 8),
          Text('Tap + to upload a certificate or photo', style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String imageUrl;
  const _AttachmentCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // ✅ تم استخدام AspectRatio لضمان وضوح الصورة وتناسقها في العمود الواحد
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          key: ValueKey(imageUrl),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.broken_image, color: Colors.grey, size: 40),
                Text('Error loading image', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}