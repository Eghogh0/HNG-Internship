import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'liveness_repository.dart';

part 'liveness_event.dart';
part 'liveness_state.dart';

class LivenessBloc extends Bloc<LivenessEvent, LivenessState> {
  final LivenessRepository _repository;

  LivenessBloc({required LivenessRepository repository})
      : _repository = repository,
        super(LivenessInitial()) {
    on<StartLivenessVerification>(_onStartVerification);
    on<LivenessVerificationSuccess>(_onVerificationSuccess);
    on<LivenessVerificationFailure>(_onVerificationFailure);
    on<ResetLivenessState>(_onReset);
  }

  LivenessRepository get repository => _repository;

  Future<void> _onStartVerification(
    StartLivenessVerification event,
    Emitter<LivenessState> emit,
  ) async {
    emit(LivenessLoading());
    try {
      await _repository.initialize();
      await _repository.startVerification();
      emit(const LivenessVerifying('Position your face in the circle'));

      _repository.onVerificationComplete.listen((success) {
        if (success) {
          add(LivenessVerificationSuccess());
        } else {
          add(const LivenessVerificationFailure('Verification failed. Please try again.'));
        }
      });
    } catch (e) {
      emit(LivenessFailure(e.toString()));
    }
  }

  Future<void> _onVerificationSuccess(
    LivenessVerificationSuccess event,
    Emitter<LivenessState> emit,
  ) async {
    await _repository.stopVerification();
    emit(LivenessSuccess());
  }

  Future<void> _onVerificationFailure(
    LivenessVerificationFailure event,
    Emitter<LivenessState> emit,
  ) async {
    await _repository.stopVerification();
    emit(LivenessFailure(event.error));
  }

  void _onReset(ResetLivenessState event, Emitter<LivenessState> emit) {
    emit(LivenessInitial());
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}