import 'package:flutter/material.dart';

import '../state/appearance_controller.dart';
import '../state/auth_navigation.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/form_parts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SubmitMixin {
  Future<void> _signOut() async {
    final auth = AuthScope.read(context).auth;
    await submit(auth.signOut);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final navigation = scope.navigation;
    final user = scope.auth.user;
    final scheme = Theme.of(context).colorScheme;
    final currentFailure = failure;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: navigation.back,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Account'),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (currentFailure != null)
                  FormBanner.failure(currentFailure, onRetry: _signOut),
                _Group(
                  title: 'Signed in as',
                  children: [
                    ListTile(
                      title: Text(user?.name ?? ''),
                      subtitle: Text(user?.email ?? ''),
                    ),
                  ],
                ),
                _Group(
                  title: 'Security',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => navigation.open(AuthRoute.changePassword),
                    ),
                  ],
                ),
                const _Group(
                  title: 'Theme',
                  children: [_ThemeChoice()],
                ),
                _Group(
                  title: 'Session',
                  children: [
                    ListTile(
                      enabled: !isBusy,
                      leading: isBusy
                          ? const SizedBox.square(
                              dimension: 24,
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                            )
                          : const Icon(Icons.logout),
                      title: Text(isBusy ? 'Signing out' : 'Sign out'),
                      onTap: _signOut,
                    ),
                    ListTile(
                      iconColor: scheme.error,
                      textColor: scheme.error,
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete account'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => navigation.open(AuthRoute.deleteAccount),
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

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice();

  @override
  Widget build(BuildContext context) {
    final appearance = AuthScope.of(context).appearance;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in ThemePreference.values)
            ChoiceChip(
              avatar: Icon(option.icon, size: 18),
              showCheckmark: false,
              label: Text(option.label),
              selected: appearance.preference == option,
              onSelected: (_) => appearance.preference = option,
            ),
        ],
      ),
    );
  }
}
