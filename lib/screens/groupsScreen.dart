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

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

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
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
        }
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

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final session = Provider.of<SessionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(
        currentPage: "Groups",
      ),
      drawer: MyDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {

          final showLabel = constraints.maxWidth > 650;

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${session.name?.split(' ')[0] ?? 'User'}\'s Groups →',
                      style: textTheme.displayLarge,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: showLabel
                        ? ElevatedButton.icon(
                            key: const ValueKey('LabelButton'),
                            onPressed: () {
                              context.go('/groups/create');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 3,
                            ),
                            icon: Icon(Icons.group_add, size: 24,),
                            label:Text(
                                "Create New Group",
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          )
                        : Tooltip(
                          message: "Create New Group",
                            key: const ValueKey('noLabelButton'),
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/groups/create');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 3,
                              ),
                              child: Icon(Icons.group_add, size: 24,),
                            ),
                          ),
                    ),
                    
                  ],
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
                                itemCount: groups!.length,
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
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        }
      ),
    );

  }
}