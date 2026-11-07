import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage2 extends StatefulWidget {
  /// Called with the title of the tapped row. Without it the demo shows a
  /// SnackBar. The Dark Mode row isn't included, because it toggles its switch.
  final ValueChanged<String>? onRowTap;

  const SettingsPage2({super.key, this.onRowTap});

  @override
  State<SettingsPage2> createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  bool _isDark = false;

  void _openRow(String title) {
    final onRowTap = widget.onRowTap;
    if (onRowTap != null) {
      onRowTap(title);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$title selected (demo)')));
  }

  _CustomListTile _row(String title, IconData icon) =>
      _CustomListTile(title: title, icon: icon, onTap: () => _openRow(title));

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                _SingleSection(
                  title: "General",
                  children: [
                    _CustomListTile(
                      title: "Dark Mode",
                      icon: Icons.dark_mode_outlined,
                      onTap: () => setState(() => _isDark = !_isDark),
                      trailing: Switch(
                        value: _isDark,
                        onChanged: (value) {
                          setState(() {
                            _isDark = value;
                          });
                        },
                      ),
                    ),
                    _row("Notifications", Icons.notifications_none_rounded),
                    _row("Security Status", CupertinoIcons.lock_shield),
                  ],
                ),
                const Divider(),
                _SingleSection(
                  title: "Organization",
                  children: [
                    _row("Profile", Icons.person_outline_rounded),
                    _row("Messaging", Icons.message_outlined),
                    _row("Calling", Icons.phone_outlined),
                    _row("People", Icons.contacts_outlined),
                    _row("Calendar", Icons.calendar_today_rounded),
                  ],
                ),
                const Divider(),
                _SingleSection(
                  children: [
                    _row("Help & Feedback", Icons.help_outline_rounded),
                    _row("About", Icons.info_outline_rounded),
                    _row("Sign out", Icons.exit_to_app_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback onTap;
  const _CustomListTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(children: children),
      ],
    );
  }
}
