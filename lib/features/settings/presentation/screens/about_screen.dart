import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Planner',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Version $_version',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              'This application helps you plan and organize your travel itineraries seamlessly. Built with Flutter for a beautiful and performant cross-platform experience.',
            ),
            const SizedBox(height: 24),
            Text(
              'Developed by:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('Lakshya Khetan'),
          ],
        ),
      ),
    );
  }
}