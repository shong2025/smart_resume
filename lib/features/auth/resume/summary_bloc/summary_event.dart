import '../models/summary_model.dart';

abstract class SummaryEvent {}

class LoadSummary extends SummaryEvent {
  final String resumeId;
  LoadSummary(this.resumeId);
}

class SaveSummary extends SummaryEvent {
  final Summary summary;
  SaveSummary(this.summary);
}
