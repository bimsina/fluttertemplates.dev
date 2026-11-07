import 'package:flutter/material.dart';

class SocialProfile extends StatelessWidget {
  const SocialProfile({super.key});

  static const _coverHeight = 200.0;
  static const _avatarRadius = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar(
            // The avatar lives in the header so it can straddle the cover's
            // lower edge and collapse with it.
            expandedHeight: _coverHeight + _avatarRadius,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      bottom: _avatarRadius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: _avatarRadius,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        child: Text(
                          'JD',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                children: [
                  Text(
                    'John Doe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '@johndoe',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Bio: Flutter developer'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatCell('120', 'Posts'),
                      _StatCell('1.2K', 'Followers'),
                      _StatCell('400', 'Following'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Grid'),
                  Tab(text: 'List'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemCount: 9,
                      itemBuilder: (_, i) => Container(
                        color: Colors.primaries[i % 9].withValues(alpha: 0.3),
                      ),
                    ),
                    ListView.builder(
                      itemCount: 5,
                      itemBuilder: (_, i) => ListTile(title: Text('Post $i')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
