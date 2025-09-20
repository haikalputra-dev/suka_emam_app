import 'package:flutter/material.dart';

class SuccessPage extends StatefulWidget {
  final String title;
  final String message;
  final String imageAsset;
  final VoidCallback onClose;

  const SuccessPage({
    super.key,
    required this.title,
    required this.message,
    required this.imageAsset,
    required this.onClose,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    // Otomatis tutup setelah beberapa detik
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(widget.imageAsset, height: 200),
              const SizedBox(height: 32),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}