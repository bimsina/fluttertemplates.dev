import 'package:flutter/material.dart';

class CustomNavigationRail extends StatefulWidget {
  const CustomNavigationRail({super.key});

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail> {
  // An extended rail is 256px wide, which would crowd out the content pane.
  static const _minExtendedWidth = 600.0;

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.none;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
  bool isExtended = true;

  bool get _canExtend => MediaQuery.sizeOf(context).width >= _minExtendedWidth;
  bool get _extended => isExtended && _canExtend;

  void _updateExtended(bool value) {
    setState(() {
      isExtended = value;
      if (isExtended) {
        labelType = NavigationRailLabelType.none;
      }
    });
  }

  void _updateLabelType(Set<NavigationRailLabelType> newSelection) {
    if (!_extended) {
      setState(() {
        labelType = newSelection.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // An extended rail only allows `none`, even if a narrow window set another.
    final effectiveLabelType = _extended
        ? NavigationRailLabelType.none
        : labelType;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              extended: _extended,
              scrollable: true,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: effectiveLabelType,
              leading: showLeading
                  ? FloatingActionButton(
                      elevation: 0,
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox(),
              trailing: showTrailing
                  ? IconButton(
                      tooltip: 'More options',
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      icon: const Icon(Icons.more_horiz_rounded),
                    )
                  : const SizedBox(),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Badge(child: Icon(Icons.notifications_outlined)),
                  selectedIcon: Badge(child: Icon(Icons.notifications)),
                  label: Text('Notifications'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    label: Text('3'),
                    child: Icon(Icons.mail_outline),
                  ),
                  selectedIcon: Badge(
                    label: Text('3'),
                    child: Icon(Icons.mail),
                  ),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Team'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('selectedIndex: $_selectedIndex'),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: Text(_extended ? 'Collapse Rail' : 'Expand Rail'),
                        subtitle: _canExtend
                            ? null
                            : const Text('Needs a wider window'),
                        value: _extended,
                        onChanged: _canExtend ? _updateExtended : null,
                      ),
                      const SizedBox(height: 20),
                      Text('Label type: ${effectiveLabelType.name}'),
                      const SizedBox(height: 10),
                      // Scrolls sideways when the pane is narrower than the
                      // segments, which can't shrink below their labels.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Opacity(
                          opacity: _extended ? 0.5 : 1.0,
                          child: SegmentedButton<NavigationRailLabelType>(
                            showSelectedIcon: false,
                            segments:
                                const <ButtonSegment<NavigationRailLabelType>>[
                                  ButtonSegment<NavigationRailLabelType>(
                                    value: NavigationRailLabelType.none,
                                    label: Text('None'),
                                  ),
                                  ButtonSegment<NavigationRailLabelType>(
                                    value: NavigationRailLabelType.selected,
                                    label: Text('Selected'),
                                  ),
                                  ButtonSegment<NavigationRailLabelType>(
                                    value: NavigationRailLabelType.all,
                                    label: Text('All'),
                                  ),
                                ],
                            selected: <NavigationRailLabelType>{
                              effectiveLabelType,
                            },
                            onSelectionChanged: _updateLabelType,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Group alignment: $groupAlignment'),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SegmentedButton<double>(
                          showSelectedIcon: false,
                          segments: const <ButtonSegment<double>>[
                            ButtonSegment<double>(
                              value: -1.0,
                              label: Text('Top'),
                            ),
                            ButtonSegment<double>(
                              value: 0.0,
                              label: Text('Center'),
                            ),
                            ButtonSegment<double>(
                              value: 1.0,
                              label: Text('Bottom'),
                            ),
                          ],
                          selected: <double>{groupAlignment},
                          onSelectionChanged: (Set<double> newSelection) {
                            setState(() {
                              groupAlignment = newSelection.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: Text(
                          showLeading ? 'Hide Leading' : 'Show Leading',
                        ),
                        value: showLeading,
                        onChanged: (bool value) {
                          setState(() {
                            showLeading = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          showTrailing ? 'Hide Trailing' : 'Show Trailing',
                        ),
                        value: showTrailing,
                        onChanged: (bool value) {
                          setState(() {
                            showTrailing = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
