import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/group.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/groupCard.dart';
import 'package:split_ease/widgets/navigationDrawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  List<Group>? groups;
  bool isLoading = true;
  String? errorMessage;

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
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
        }
      }
      final token = session.token;

      final api = ApiService();
      final responseData = await api.fetchGroups(token);

      if (!mounted) return;

      if (responseData == null) {
        setState(() {
          errorMessage = 'Failed to load Groups. Please Reload';
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
        errorMessage = 'Failed to load Groups. Please Reload. Error $e';
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final session = Provider.of<SessionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(
        currentPage: "Dashboard",
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, ${session.name?.split(' ')[0] ?? 'User'}!',
              style: textTheme.displayLarge,
            ),
            AppSpacing.verticalLg,
            Text(
              'Your Groups:',
              style: textTheme.bodyLarge,
            ),
            AppSpacing.verticalLg,
            Expanded(
              child: isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                )
                : errorMessage != null
                  ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.verticalLg,
                          ElevatedButton.icon(
                            onPressed: fetchGroups,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                            ),
                            icon: Icon(Icons.refresh),
                            label: Text(
                              'Retry',
                              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondary),
                            ),
                          ),
                        ],
                      ),
                  )
                  : groups == null || groups!.isEmpty
                    ? Center(
                        child: Text(
                          'You don\'t have any groups yet.',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(), // prevent nested scrolling
                            shrinkWrap: true, // take only needed space
                            itemCount: min(3, groups!.length),
                            separatorBuilder: (context, index) => AppSpacing.verticalMd,
                            itemBuilder: (context, index) {
                              final group = groups![index];
                              final currentUserId = session.userID;
                              return Center(
                                child: GroupCard(
                                  onTap: () {
                                    context.go("/group/${group.id}");
                                  },
                                   group: group,
                                  currentUserID: currentUserId!,
                                ),
                              );
                            },
                          ),
                          AppSpacing.verticalMd,
                          TextButton(
                            onPressed: () {
                              context.go('/groups');
                            },
                            child: Text(
                              "View all groups →",
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

  }
}