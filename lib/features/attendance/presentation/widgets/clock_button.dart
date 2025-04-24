import 'package:flutter/material.dart';

class ClockButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  ClockButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}