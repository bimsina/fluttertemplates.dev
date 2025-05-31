import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage1 extends StatelessWidget {
  const SettingsPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "General",
                children: [
                  const _CustomListTile(
                    title: "About Phone",
                    icon: CupertinoIcons.device_phone_portrait,
                  ),
                  _CustomListTile(
                    title: "Dark Mode",
                    icon: CupertinoIcons.moon,
                    trailing: CupertinoSwitch(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  const _CustomListTile(
                    title: "System Apps Updater",
                    icon: CupertinoIcons.cloud_download,
                  ),
                  const _CustomListTile(
                    title: "Security Status",
                    icon: CupertinoIcons.lock_shield,
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
                    trailing: CupertinoSwitch(value: true, onChanged: (val) {}),
                  ),
                  _CustomListTile(
                    title: "Bluetooth",
                    icon: CupertinoIcons.bluetooth,
                    trailing: CupertinoSwitch(
                      value: false,
                      onChanged: (val) {},
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
                    title: "Multiple Users",
                    icon: CupertinoIcons.person_2,
                  ),
                  _CustomListTile(
                    title: "Lock Screen",
                    icon: CupertinoIcons.lock,
                  ),
                  _CustomListTile(
                    title: "Display",
                    icon: CupertinoIcons.brightness,
                  ),
                  _CustomListTile(
                    title: "Sound and Vibration",
                    icon: CupertinoIcons.speaker_2,
                  ),
                  _CustomListTile(
                    title: "Themes",
                    icon: CupertinoIcons.paintbrush,
                  ),
                ],
              ),
            ],
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
  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing ?? const Icon(CupertinoIcons.forward, size: 18),
      onTap: () {},
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
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          child: Column(children: children),
        ),
      ],
    );
  }
}
