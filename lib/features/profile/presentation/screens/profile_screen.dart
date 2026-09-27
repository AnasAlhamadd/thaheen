import 'package:flutter/material.dart';
import '../widgets/profile_settings_section.dart';

/// Screen representing the student's profile, academic stats, and theme/language preferences.
class ProfileScreen extends StatelessWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [ProfileSettingsSection(), SizedBox(height: 16)],
      ),
    );
  }
}
