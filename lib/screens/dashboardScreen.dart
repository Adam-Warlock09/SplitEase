import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    await session.DeleteSession();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {

    final session = Provider.of<SessionProvider>(context);
    final userId = session.userID ?? "No User Logged In";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'User ID: $userId',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );

  }
}