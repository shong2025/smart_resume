abstract class AttachmentEvent {}

class LoadAttachments extends AttachmentEvent {
  final String resumeId;
  LoadAttachments(this.resumeId);
}

class UploadAttachment extends AttachmentEvent {
  final String resumeId;
  final String imagePath;
  UploadAttachment(this.resumeId, this.imagePath);
}
