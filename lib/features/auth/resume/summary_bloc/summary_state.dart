import '../models/summary_model.dart';

abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final Summary? summary;
  SummaryLoaded(this.summary);
}

class SummarySaved extends SummaryState {}

class SummaryError extends SummaryState {
  final String message;
  SummaryError(this.message);
}
