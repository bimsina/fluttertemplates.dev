import 'package:flutter/material.dart';

class ToastDemo extends StatelessWidget {
  const ToastDemo({super.key});

  void _showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: behavior,
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast & Snackbar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Snackbars',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(context, message: 'This is a basic snackbar');
                  },
                  child: const Text('Basic Snackbar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'This is a floating snackbar',
                      behavior: SnackBarBehavior.floating,
                    );
                  },
                  child: const Text('Floating Snackbar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'This is a colored snackbar',
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                    );
                  },
                  child: const Text('Colored Snackbar'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Snackbars with Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'Item deleted',
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item restored'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('With Undo Action'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'Download started',
                      action: SnackBarAction(
                        label: 'CANCEL',
                        textColor: Colors.red,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download cancelled'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('With Cancel Action'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Custom Duration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'This will stay for 10 seconds',
                      duration: const Duration(seconds: 10),
                    );
                  },
                  child: const Text('Long Duration'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'This will stay for 2 seconds',
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: const Text('Short Duration'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Multiple Snackbars',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      message: 'First message',
                      duration: const Duration(seconds: 1),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (!context.mounted) return;
                      _showSnackBar(
                        context,
                        message: 'Second message',
                        duration: const Duration(seconds: 1),
                      );
                    });
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      if (!context.mounted) return;
                      _showSnackBar(
                        context,
                        message: 'Third message',
                        duration: const Duration(seconds: 1),
                      );
                    });
                  },
                  child: const Text('Show Multiple'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
