import 'package:flutter/material.dart';

class _Banner {
  final MaterialColor color;
  final IconData icon;
  final String title;
  final String message;

  const _Banner(this.color, this.icon, this.title, this.message);
}

const _banners = [
  _Banner(Colors.blue, Icons.info_outline, 'Info',
      'Your changes have been saved.'),
  _Banner(Colors.green, Icons.check_circle_outline, 'Success',
      'Payment completed successfully.'),
  _Banner(Colors.orange, Icons.warning_amber_outlined, 'Warning',
      'Your session will expire soon.'),
  _Banner(Colors.red, Icons.error_outline, 'Error',
      'Something went wrong. Please try again.'),
];

class NotificationBanners extends StatefulWidget {
  const NotificationBanners({super.key});

  @override
  State<NotificationBanners> createState() => _NotificationBannersState();
}

class _NotificationBannersState extends State<NotificationBanners> {
  final _visible = [..._banners];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Banners')),
      body: _visible.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () => setState(() => _visible.addAll(_banners)),
                child: const Text('Show banners again'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final banner in _visible)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: banner.color.withValues(alpha: 0.2),
                    child: ListTile(
                      leading: Icon(banner.icon, color: banner.color[700]),
                      title: Text(banner.title),
                      subtitle: Text(banner.message),
                      trailing: IconButton(
                        tooltip: 'Dismiss',
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setState(() => _visible.remove(banner)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
