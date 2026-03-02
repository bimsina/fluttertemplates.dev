import 'package:flutter/material.dart';

const _users = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _users
        : _users.where((u) => u.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final u = filtered[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u[0])),
            title: Text(u),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Follow'),
            ),
          );
        },
      ),
    );
  }
}
