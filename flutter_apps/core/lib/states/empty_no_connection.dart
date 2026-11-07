import 'package:flutter/material.dart';

class EmptyNoConnection extends StatefulWidget {
  const EmptyNoConnection({super.key});

  @override
  State<EmptyNoConnection> createState() => _EmptyNoConnectionState();
}

class _EmptyNoConnectionState extends State<EmptyNoConnection> {
  var _loading = false;

  // Simulated: replace the delay with a real request or connectivity check.
  Future<void> _retry() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No Connection')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'No internet connection',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _retry,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_loading ? 'Retrying...' : 'Retry'),
              ),
              const SizedBox(height: 16),
              Text(
                'Demo only: retry is simulated, no network check runs.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
