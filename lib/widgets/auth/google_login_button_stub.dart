import 'package:flutter/material.dart';

class GoogleLoginWebButton extends StatelessWidget {
  final VoidCallback onSuccess;
  final void Function(String erro) onError;

  const GoogleLoginWebButton({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}