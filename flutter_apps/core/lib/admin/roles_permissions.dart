import 'package:flutter/material.dart';

class RolesPermissions extends StatefulWidget {
  const RolesPermissions({super.key});

  @override
  State<RolesPermissions> createState() => _RolesPermissionsState();
}

class _RolesPermissionsState extends State<RolesPermissions> {
  static const _roles = ['Admin', 'Editor', 'Viewer'];
  static const _perms = [
    'View content',
    'Create content',
    'Edit content',
    'Delete content',
    'Manage users',
    'Manage billing',
  ];

  // grid[permIndex][roleIndex]
  final List<List<bool>> _grid = [
    [true, true, true],
    [true, true, false],
    [true, true, false],
    [true, false, false],
    [true, false, false],
    [true, false, false],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: scheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text('Permission',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                          )),
                      for (final r in _roles)
                        Expanded(
                          child: Center(
                            child: Text(r,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var p = 0; p < _perms.length; p++)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: scheme.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Text(_perms[p]),
                          ),
                        ),
                        for (var r = 0; r < _roles.length; r++)
                          Expanded(
                            child: Center(
                              child: Checkbox(
                                value: _grid[p][r],
                                onChanged: r == 0
                                    ? null
                                    : (v) => setState(
                                        () => _grid[p][r] = v ?? false),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Admin permissions are locked and cannot be changed.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
