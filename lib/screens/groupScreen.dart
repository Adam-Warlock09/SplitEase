import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/group.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {

  List<Group>? groups;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      
      final session = Provider.of<SessionProvider>(context, listen: false);
      if (!session.isLoggedIn) {
        context.go('/home');
      }
      final token = session.token;

      final api = ApiService();
      final responseData = await api.fetchGroups(token);

      if (responseData == null) {
        setState(() {
          errorMessage = 'Failed to load groups. Please Reload.';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          groups = responseData;
        });
      }

    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load groups. Please Reload. Error $e';
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {

    final TextTheme = Theme.of(context)

    return const Placeholder();
  }
}