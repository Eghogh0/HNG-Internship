part of 'liveness_bloc.dart';

abstract class LivenessState extends Equatable {
  const LivenessState();
  @override
  List<Object?> get props => [];
}

class LivenessInitial extends LivenessState {}

class LivenessLoading extends LivenessState {}

class LivenessVerifying extends LivenessState {
  final String instruction;
  const LivenessVerifying(this.instruction);
  @override
  List<Object?> get props => [instruction];
}

class LivenessSuccess extends LivenessState {}

class LivenessFailure extends LivenessState {
  final String message;
  const LivenessFailure(this.message);
  @override
  List<Object?> get props => [message];
}