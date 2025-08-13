import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '''
**Privacy Policy for Travel Planner**

Last updated: August 12, 2025

This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.

**1. Data Storage**
All data created by you within the Travel Planner application, including but not limited to trip details, activities, and expenses, is stored exclusively on your local device. We do not collect, transmit, or store any of your personal or trip data on any external servers.

**2. Information We Do Not Collect**
We do not collect any personally identifiable information. Since the application operates entirely offline, we have no access to your name, email address, location, or any other personal data.

**3. Data Backup and Restore**
The application provides functionality to manually export your data to a JSON file for backup purposes. This process is initiated by you, and you are solely responsible for the security and storage of this backup file. The "Restore" feature allows you to import this data back into the application on any device. At no point during this process is your data transmitted to us.

**4. Permissions**
The application may request the following permissions:
- **Location:** To center the map on your current location when using the map picker feature. Your location is not stored or transmitted.
- **Photos/Gallery:** To allow you to select images to attach to activities. The application only accesses photos you explicitly select.
- **Notifications:** To schedule local reminders for upcoming activities.

**5. Changes to this Privacy Policy**
We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.

**6. Contact Us**
If you have any questions about this Privacy Policy, You can contact us.
          ''',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}