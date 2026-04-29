part of 'liveness_bloc.dart';

abstract class LivenessEvent extends Equatable {
  const LivenessEvent();
  @override
  List<Object?> get props => [];
}

class StartLivenessVerification extends LivenessEvent {}

class LivenessVerificationSuccess extends LivenessEvent {}

class LivenessVerificationFailure extends LivenessEvent {
  final String error;
  const LivenessVerificationFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class ResetLivenessState extends LivenessEvent {}