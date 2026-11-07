import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage1 extends StatefulWidget {
  const SettingsPage1({super.key});

  @override
  State<SettingsPage1> createState() => _SettingsPage1State();
}

class _SettingsPage1State extends State<SettingsPage1> {
  var _wifi = true;
  var _bluetooth = false;

  // Null follows the app theme until the switch is used.
  bool? _darkMode;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final isDark = _darkMode ?? base.brightness == Brightness.dark;

    return Theme(
      // This only themes this page, so wire it to your app theme for the rest.
      data: isDark == (base.brightness == Brightness.dark)
          ? base
          : ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                const _SingleSection(
                  title: "General",
                  children: [
                    _CustomListTile(
                      title: "About Phone",
                      icon: CupertinoIcons.device_phone_portrait,
                    ),
                    _CustomListTile(
                      title: "System Apps Updater",
                      icon: CupertinoIcons.cloud_download,
                    ),
                    _CustomListTile(
                      title: "Multiple Users",
                      icon: CupertinoIcons.person_2,
                    ),
                  ],
                ),
                _SingleSection(
                  title: "Network",
                  children: [
                    const _CustomListTile(
                      title: "SIM Cards and Networks",
                      icon: Icons.sd_card_outlined,
                    ),
                    _CustomListTile(
                      title: "Wi-Fi",
                      icon: CupertinoIcons.wifi,
                      onTap: () => setState(() => _wifi = !_wifi),
                      trailing: CupertinoSwitch(
                        value: _wifi,
                        onChanged: (val) => setState(() => _wifi = val),
                      ),
                    ),
                    _CustomListTile(
                      title: "Bluetooth",
                      icon: CupertinoIcons.bluetooth,
                      onTap: () => setState(() => _bluetooth = !_bluetooth),
                      trailing: CupertinoSwitch(
                        value: _bluetooth,
                        onChanged: (val) => setState(() => _bluetooth = val),
                      ),
                    ),
                    const _CustomListTile(
                      title: "VPN",
                      icon: CupertinoIcons.desktopcomputer,
                    ),
                  ],
                ),
                const _SingleSection(
                  title: "Privacy and Security",
                  children: [
                    _CustomListTile(
                      title: "Lock Screen",
                      icon: CupertinoIcons.lock,
                    ),
                    _CustomListTile(
                      title: "Security Status",
                      icon: CupertinoIcons.lock_shield,
                    ),
                  ],
                ),
                _SingleSection(
                  title: "Display and Sound",
                  children: [
                    _CustomListTile(
                      title: "Dark Mode",
                      icon: CupertinoIcons.moon,
                      onTap: () => setState(() => _darkMode = !isDark),
                      trailing: CupertinoSwitch(
                        value: isDark,
                        onChanged: (value) => setState(() => _darkMode = value),
                      ),
                    ),
                    const _CustomListTile(
                      title: "Display",
                      icon: CupertinoIcons.brightness,
                    ),
                    const _CustomListTile(
                      title: "Sound and Vibration",
                      icon: CupertinoIcons.speaker_2,
                    ),
                    const _CustomListTile(
                      title: "Themes",
                      icon: CupertinoIcons.paintbrush,
                    ),
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
  final VoidCallback? onTap;
  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing ?? const Icon(CupertinoIcons.forward, size: 18),
      onTap: onTap ?? () => _showDemo(context, '$title selected (demo)'),
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SingleSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 16),
          ),
        ),
        // Material, not a colored Container, so the tiles' ink stays visible.
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
