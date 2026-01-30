import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Repository/summary_repository.dart';
import 'summary_event.dart';
import 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final SummaryRepository repository;

  SummaryBloc(this.repository) : super(SummaryInitial()) {
    on<LoadSummary>((event, emit) async {
      emit(SummaryLoading());
      try {
        final summary = await repository.getSummary(event.resumeId);
        emit(SummaryLoaded(summary));
      } catch (e) {
        emit(SummaryError(e.toString()));
      }
    });

    on<SaveSummary>((event, emit) async {
      final currentState = state;
      emit(SummaryLoading());
      try {
        if (event.summary.id == null) {
          await repository.addSummary(event.summary);
        } else {
          await repository.updateSummary(event.summary);
        }
        
        // إعادة تحميل البيانات لضمان الحصول على الـ id الجديد في حال الإضافة
        final updatedSummary = await repository.getSummary(event.summary.resumeId);
        emit(SummarySaved());
        emit(SummaryLoaded(updatedSummary));
      } catch (e) {
        emit(SummaryError(e.toString()));
        if (currentState is SummaryLoaded) {
          emit(currentState); // العودة للحالة السابقة في حال الخطأ
        }
      }
    });
  }
}
