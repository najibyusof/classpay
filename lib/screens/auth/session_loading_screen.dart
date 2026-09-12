import 'package:classpay/core/widgets/async_states.dart';
import 'package:flutter/material.dart';

class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: AppLoadingIndicator(message: 'Restoring your session...'),
  );
}
