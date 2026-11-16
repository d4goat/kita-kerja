import 'package:flutter/material.dart';
import 'package:kita_kerja/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(initialTab: 0);
  }
}
