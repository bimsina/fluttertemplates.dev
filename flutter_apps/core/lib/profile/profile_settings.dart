import 'package:flutter/material.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  static const _languages = ['English', 'Español', 'Français', 'Deutsch'];

  var _pushNotifications = true;
  var _language = _languages.first;
  final _connected = {'Google'};

  // Null follows the app theme until the switch is used.
  bool? _darkMode;

  void _toggleAccount(String account) {
    setState(() {
      if (!_connected.add(account)) _connected.remove(account);
    });
  }

  // This only themes this page, so wire it to your app theme for the rest.
  ThemeData _pageTheme(ThemeData base, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    if (base.brightness == brightness) return base;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: base.colorScheme.primary,
        brightness: brightness,
      ),
    );
  }

  Widget _accountBadge(String account) {
    final connected = _connected.contains(account);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (connected ? Colors.green : Colors.grey).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        connected ? 'Connected' : 'Connect',
        style: TextStyle(
          color: connected ? Colors.green : Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _pickLanguage() async {
    final language = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Language'),
        children: [
          for (final option in _languages)
            ListTile(
              title: Text(option),
              trailing: option == _language ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, option),
            ),
        ],
      ),
    );
    if (language != null) setState(() => _language = language);
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final isDark = _darkMode ?? base.brightness == Brightness.dark;

    return Theme(
      data: _pageTheme(base, isDark),
      child: Scaffold(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                    onTap: () => _showDemo(context, 'Edit Profile (demo)'),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'john.doe@email.com',
                    isDark: isDark,
                    onTap: () => _showDemo(context, 'Email (demo)'),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    subtitle: '+1 234 567 8900',
                    isDark: isDark,
                    onTap: () => _showDemo(context, 'Phone (demo)'),
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
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                  _buildSwitchTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    isDark: isDark,
                    value: isDark,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: _language,
                    isDark: isDark,
                    onTap: _pickLanguage,
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
                    icon: _connected.contains('Google')
                        ? Icons.link
                        : Icons.link_off,
                    title: 'Google',
                    subtitle: _connected.contains('Google')
                        ? 'Connected'
                        : 'Not connected',
                    isDark: isDark,
                    trailing: _accountBadge('Google'),
                    onTap: () => _toggleAccount('Google'),
                  ),
                  _buildSettingTile(
                    context,
                    icon: _connected.contains('Facebook')
                        ? Icons.link
                        : Icons.link_off,
                    title: 'Facebook',
                    subtitle: _connected.contains('Facebook')
                        ? 'Connected'
                        : 'Not connected',
                    isDark: isDark,
                    trailing: _accountBadge('Facebook'),
                    onTap: () => _toggleAccount('Facebook'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
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

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
