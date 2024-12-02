import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final bool isStreaming;
  final bool isProcessing;
  final VoidCallback onCapture;
  final VoidCallback onStreamToggle;

  const CameraControls({
    Key? key,
    required this.isStreaming,
    required this.isProcessing,
    required this.onCapture,
    required this.onStreamToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.camera,
              color: isProcessing ? Colors.grey : Colors.white,
              size: 32,
            ),
            onPressed: isProcessing ? null : onCapture,
          ),
          IconButton(
            icon: Icon(
              isStreaming ? Icons.stop : Icons.play_arrow,
              color: isStreaming ? Colors.red : Colors.white,
              size: 32,
            ),
            onPressed: onStreamToggle,
          ),
        ],
      ),
    );
  }
}
