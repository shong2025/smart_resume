import '../models/resume_attachment_model.dart';

abstract class AttachmentState {}

class AttachmentInitial extends AttachmentState {}

class AttachmentLoading extends AttachmentState {}

class AttachmentLoaded extends AttachmentState {
  final List<ResumeAttachment> attachments;
  AttachmentLoaded(this.attachments);
}

class AttachmentError extends AttachmentState {
  final String message;
  AttachmentError(this.message);
}
