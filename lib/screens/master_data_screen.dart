import 'package:flutter/material.dart';
import 'package:kita_kerja/screens/settings_screen.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(initialTab: 1);
  }
}
