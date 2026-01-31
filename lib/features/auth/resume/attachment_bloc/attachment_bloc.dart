import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repository/attachment_repository.dart';
import 'attachment_event.dart';
import 'attachment_state.dart';

class AttachmentBloc
    extends Bloc<AttachmentEvent, AttachmentState> {
  final AttachmentRepository repository;

  AttachmentBloc(this.repository) : super(AttachmentInitial()) {
    on<LoadAttachments>(_onLoad);
    on<UploadAttachment>(_onUpload);
  }

  Future<void> _onLoad(
      LoadAttachments event,
      Emitter<AttachmentState> emit,
      ) async {
    emit(AttachmentLoading());
    try {
      final data =
      await repository.getAttachments(event.resumeId);
      emit(AttachmentLoaded(data));
    } catch (e) {
      emit(AttachmentError(e.toString()));
    }
  }

  Future<void> _onUpload(
      UploadAttachment event,
      Emitter<AttachmentState> emit,
      ) async {
    try {
      await repository.uploadAttachment(
        file: File(event.imagePath),
        resumeId: event.resumeId,
      );
      add(LoadAttachments(event.resumeId));
    } catch (e) {
      emit(AttachmentError(e.toString()));
    }
  }
}
