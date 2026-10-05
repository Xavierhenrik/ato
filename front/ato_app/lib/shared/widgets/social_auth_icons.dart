import 'package:flutter/material.dart';

class GoogleAuthIcon extends StatelessWidget {
  const GoogleAuthIcon({super.key});

  static const _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: _googleBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

class AppleAuthIcon extends StatelessWidget {
  const AppleAuthIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.white, size: 20);
  }
}
