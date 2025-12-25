import 'dart:async';
import 'package:flutter/material.dart';

class FirstTimeHelper extends StatefulWidget {
  final VoidCallback onDismiss;

  const FirstTimeHelper({super.key, required this.onDismiss});

  @override
  State<FirstTimeHelper> createState() => _FirstTimeHelperState();
}

class _FirstTimeHelperState extends State<FirstTimeHelper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Icon or Illustration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF264796).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assistant_navigation,
                  size: 48,
                  color: Color(0xFF264796),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Welcome to Venue Finder',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),

              // Points
              _buildPoint(Icons.search, 'Search for a venue'),
              const SizedBox(height: 16),
              _buildPoint(Icons.directions, 'Follow step-by-step directions'),
              const SizedBox(height: 16),
              _buildPoint(Icons.wifi_off, 'Works offline across campus'),

              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF264796),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
