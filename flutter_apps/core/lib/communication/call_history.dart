import 'package:flutter/material.dart';

class CallHistory extends StatelessWidget {
  const CallHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calls = [
      {
        'name': 'Sarah Johnson',
        'avatar': 'S',
        'type': 'incoming',
        'status': 'answered',
        'time': 'Today, 2:30 PM',
        'duration': '12:34',
      },
      {
        'name': 'Mike Chen',
        'avatar': 'M',
        'type': 'outgoing',
        'status': 'answered',
        'time': 'Today, 11:15 AM',
        'duration': '5:20',
      },
      {
        'name': 'Emma Wilson',
        'avatar': 'E',
        'type': 'missed',
        'status': 'unanswered',
        'time': 'Yesterday, 8:45 PM',
        'duration': '0:00',
      },
      {
        'name': 'James Brown',
        'avatar': 'J',
        'type': 'incoming',
        'status': 'answered',
        'time': 'Yesterday, 5:30 PM',
        'duration': '8:45',
      },
      {
        'name': 'Lisa Davis',
        'avatar': 'L',
        'type': 'outgoing',
        'status': 'answered',
        'time': 'Yesterday, 3:20 PM',
        'duration': '2:15',
      },
      {
        'name': 'David Lee',
        'avatar': 'D',
        'type': 'missed',
        'status': 'unanswered',
        'time': 'Mon, 9:00 PM',
        'duration': '0:00',
      },
      {
        'name': 'Alice Smith',
        'avatar': 'A',
        'type': 'incoming',
        'status': 'answered',
        'time': 'Mon, 4:30 PM',
        'duration': '15:00',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: calls.length,
        itemBuilder: (context, index) {
          final call = calls[index];
          return _buildCallTile(context, call, isDark);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }

  Widget _buildCallTile(
    BuildContext context,
    Map<String, dynamic> call,
    bool isDark,
  ) {
    final type = call['type'] as String;
    final status = call['status'] as String;

    IconData callIcon;
    Color iconColor;

    if (type == 'missed') {
      callIcon = Icons.call_missed;
      iconColor = Colors.red;
    } else if (type == 'outgoing') {
      callIcon = Icons.call_made;
      iconColor = isDark ? Colors.white : Colors.black54;
    } else {
      callIcon = Icons.call_received;
      iconColor = isDark ? Colors.white : Colors.black54;
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue[400],
            child: Text(
              call['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (status == 'unanswered')
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_missed,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        call['name'],
        style: TextStyle(
          fontWeight: status == 'unanswered'
              ? FontWeight.bold
              : FontWeight.w500,
          color: status == 'unanswered' ? Colors.red : null,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(callIcon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '${call['time']} • ${call['duration']}',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
