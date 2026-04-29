import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'dart:async';

class LivenessRepository {
  LivenessDetector? _detector;
  StreamSubscription? _stateSubscription;
  final StreamController<bool> _verificationCompleteController = StreamController.broadcast();

  Stream<bool> get onVerificationComplete => _verificationCompleteController.stream;

  Future<void> initialize() async {
    _detector = LivenessDetector(const LivenessConfig());
    await _detector?.initialize();
  }

  Future<void> startVerification() async {
    if (_detector == null) await initialize();
    await _detector?.start();

    _stateSubscription = _detector?.stateStream.listen((state) {
      if (state.type == LivenessStateType.completed) {
        _verificationCompleteController.add(true);
      } else if (state.type == LivenessStateType.error) {
        _verificationCompleteController.add(false);
      }
    });
  }

  LivenessDetector? get detector => _detector;

  // Assuming LivenessDetector has cameraController
  dynamic get cameraController => _detector?.cameraController;

  Future<void> stopVerification() async {
    await _stateSubscription?.cancel();
    await _detector?.stop();
  }

  Future<void> dispose() async {
    await _stateSubscription?.cancel();
    await _detector?.dispose();
    await _verificationCompleteController.close();
  }
}