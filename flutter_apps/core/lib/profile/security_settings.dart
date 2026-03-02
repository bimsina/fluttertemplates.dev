import 'package:flutter/material.dart';

class SecuritySettings extends StatelessWidget {
  const SecuritySettings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sessions = [
      {
        'device': 'iPhone 14 Pro',
        'location': 'San Francisco, CA',
        'lastActive': 'Active now',
        'isCurrent': true,
      },
      {
        'device': 'MacBook Pro',
        'location': 'San Francisco, CA',
        'lastActive': '2 hours ago',
        'isCurrent': false,
      },
      {
        'device': 'iPad Air',
        'location': 'San Francisco, CA',
        'lastActive': 'Yesterday',
        'isCurrent': false,
      },
    ];

    final loginHistory = [
      {
        'device': 'iPhone 14 Pro',
        'location': 'San Francisco, CA',
        'time': 'Today, 2:30 PM',
        'status': 'Success',
      },
      {
        'device': 'iPhone 14 Pro',
        'location': 'San Francisco, CA',
        'time': 'Today, 10:15 AM',
        'status': 'Success',
      },
      {
        'device': 'MacBook Pro',
        'location': 'San Francisco, CA',
        'time': 'Yesterday, 6:45 PM',
        'status': 'Success',
      },
      {
        'device': 'Unknown Device',
        'location': 'New York, NY',
        'time': 'Mar 1, 2024',
        'status': 'Failed',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Password',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Last changed 30 days ago',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.password,
                title: 'Forgot Password',
                subtitle: 'Reset your password',
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Two-Factor Authentication',
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user, color: Colors.green),
                ),
                title: const Text('2FA is enabled'),
                subtitle: Text(
                  'Using authenticator app',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Manage'),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Active Sessions',
            isDark: isDark,
            children: [
              ...sessions.map(
                (session) => _buildSessionTile(context, session, isDark),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign Out All Devices',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Login History',
            isDark: isDark,
            children: [
              ...loginHistory.map(
                (login) => _buildLoginHistoryTile(context, login, isDark),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Additional Security',
            isDark: isDark,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.security,
                title: 'Security Questions',
                subtitle: 'Add recovery questions',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.email_outlined,
                title: 'Recovery Email',
                subtitle: 'john.doe@email.com',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Recovery Phone',
                subtitle: '+1 *** *** **90',
                isDark: isDark,
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

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
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
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white30 : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    Map<String, dynamic> session,
    bool isDark,
  ) {
    final isCurrent = session['isCurrent'] as bool;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCurrent
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.devices,
          color: isCurrent ? Colors.green : Colors.blue,
        ),
      ),
      title: Row(
        children: [
          Text(session['device']),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${session['location']} • ${session['lastActive']}',
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: isCurrent
          ? null
          : IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {},
            ),
    );
  }

  Widget _buildLoginHistoryTile(
    BuildContext context,
    Map<String, dynamic> login,
    bool isDark,
  ) {
    final status = login['status'] as String;
    final isFailed = status == 'Failed';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isFailed ? Colors.red : Colors.green).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isFailed ? Icons.error_outline : Icons.check_circle_outline,
          color: isFailed ? Colors.red : Colors.green,
        ),
      ),
      title: Text(login['device']),
      subtitle: Text(
        '${login['location']} • ${login['time']}',
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (isFailed ? Colors.red : Colors.green).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isFailed ? Colors.red : Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
