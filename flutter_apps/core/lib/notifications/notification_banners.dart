import 'package:flutter/material.dart';

class NotificationBanners extends StatelessWidget {
  const NotificationBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Banners')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue[700]),
              title: const Text('Info'),
              subtitle: const Text('Your changes have been saved.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green[700]),
              title: const Text('Success'),
              subtitle: const Text('Payment completed successfully.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.orange.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.warning_amber_outlined, color: Colors.orange[700]),
              title: const Text('Warning'),
              subtitle: const Text('Your session will expire soon.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.error_outline, color: Colors.red[700]),
              title: const Text('Error'),
              subtitle: const Text('Something went wrong. Please try again.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }
}
