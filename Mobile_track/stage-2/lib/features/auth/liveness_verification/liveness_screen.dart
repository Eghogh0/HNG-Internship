import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'liveness_bloc/liveness_repository.dart';   // ✅ correct path

class LivenessScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailure;
  
  const LivenessScreen({super.key, required this.onSuccess, required this.onFailure});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  final LivenessRepository _livenessRepo = LivenessRepository();
  String _instruction = 'Position your face in the circle';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeLiveness();
  }

  Future<void> _initializeLiveness() async {
    await _livenessRepo.initialize();
    await _livenessRepo.startVerification();
    
    _livenessRepo.onVerificationComplete.listen((success) {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          widget.onSuccess();
        } else {
          widget.onFailure();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification'), centerTitle: true),
      body: Column(
        children: [
          if (_livenessRepo.detector?.cameraController != null)
            Expanded(
              flex: 3,
              child: CameraPreview(_livenessRepo.detector!.cameraController!),
            ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 32, color: Colors.indigo),
                const SizedBox(height: 12),
                Text(_instruction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _livenessRepo.dispose();
    super.dispose();
  }
}