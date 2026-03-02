import 'package:flutter/material.dart';

class PrivacySettings extends StatefulWidget {
  const PrivacySettings({super.key});

  @override
  State<PrivacySettings> createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool _profileVisibility = true;
  bool _onlineStatus = true;
  bool _readReceipts = true;
  bool _typingStatus = true;
  bool _lastSeen = true;
  bool _storyVisibility = true;
  bool _locationSharing = false;
  bool _dataSync = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Profile',
            isDark: isDark,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.visibility,
                title: 'Profile Visibility',
                subtitle: 'Allow others to see your profile',
                isDark: isDark,
                value: _profileVisibility,
                onChanged: (v) => setState(() => _profileVisibility = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.access_time,
                title: 'Last Seen',
                subtitle: 'Show when you were last active',
                isDark: isDark,
                value: _lastSeen,
                onChanged: (v) => setState(() => _lastSeen = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.photo_library,
                title: 'Story Visibility',
                subtitle: 'Allow others to see your stories',
                isDark: isDark,
                value: _storyVisibility,
                onChanged: (v) => setState(() => _storyVisibility = v),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Activity',
            isDark: isDark,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.circle,
                title: 'Online Status',
                subtitle: 'Show when you\'re online',
                isDark: isDark,
                value: _onlineStatus,
                onChanged: (v) => setState(() => _onlineStatus = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.done_all,
                title: 'Read Receipts',
                subtitle: 'Send read receipts',
                isDark: isDark,
                value: _readReceipts,
                onChanged: (v) => setState(() => _readReceipts = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.edit_note,
                title: 'Typing Status',
                subtitle: 'Show when you\'re typing',
                isDark: isDark,
                value: _typingStatus,
                onChanged: (v) => setState(() => _typingStatus = v),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Data & Location',
            isDark: isDark,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.location_on,
                title: 'Location Sharing',
                subtitle: 'Share your location with contacts',
                isDark: isDark,
                value: _locationSharing,
                onChanged: (v) => setState(() => _locationSharing = v),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.sync,
                title: 'Data Sync',
                subtitle: 'Sync data across devices',
                isDark: isDark,
                value: _dataSync,
                onChanged: (v) => setState(() => _dataSync = v),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Blocked Users',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.block,
                title: 'Blocked Accounts',
                subtitle: '3 accounts',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.volume_off,
                title: 'Muted Accounts',
                subtitle: '5 accounts',
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Advanced',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.lock_outline,
                title: 'Archived Chats',
                subtitle: 'Show in profile',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.history,
                title: 'Download My Data',
                subtitle: 'Export your data',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.delete_outline,
                title: 'Delete All Chats',
                subtitle: 'Remove all chat history',
                isDark: isDark,
                textColor: Colors.red,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required bool value,
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

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? Colors.blue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? Colors.blue),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white30 : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
