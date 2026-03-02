import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildSection(
              context,
              title: 'Personal Information',
              isDark: isDark,
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Name, bio, photo',
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'john.doe@email.com',
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  subtitle: '+1 234 567 8900',
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Preferences',
              isDark: isDark,
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  isDark: isDark,
                  value: true,
                  onChanged: (v) {},
                ),
                _buildSwitchTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  isDark: isDark,
                  value: isDark,
                  onChanged: (v) {},
                ),
                _buildSwitchTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Language',
                  isDark: isDark,
                  value: false,
                  subtitle: 'English',
                  onChanged: (v) {},
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Connected Accounts',
              isDark: isDark,
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.link,
                  title: 'Google',
                  subtitle: 'Connected',
                  isDark: isDark,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                  onTap: () {},
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.link_off,
                  title: 'Facebook',
                  subtitle: 'Not connected',
                  isDark: isDark,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Connect',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white30 : Colors.grey[400],
          ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required bool value,
    String? subtitle,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue,
      ),
    );
  }
}
