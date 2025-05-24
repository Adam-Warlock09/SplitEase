import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupID;

  const GroupDetailsPage({super.key, required this.groupID});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late Future<GroupDetailed?> _group;

  @override
  void initState() {
    super.initState();

    _group = _fetchGroup();
  }

  Future<GroupDetailed?> _fetchGroup() async {
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
      if (token == null) return null;
      final api = ApiService();

      return await api.getGroupById(widget.groupID, token);
    } catch (e) {
      return null;
    }
  }

  String _formatFullDate(DateTime date) {
    final formatter = DateFormat('MMMM d, y');
    return formatter.format(date);
  }

  String _formatRelativeTime(DateTime date) {
    return timeago.format(date, allowFromNow: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(currentPage: "Group Details"),
      drawer: MySubDrawer(id: widget.groupID),
      body: FutureBuilder<GroupDetailed?>(
        future: _group,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load Group Details. Unauthorized or Invalid group.",
                    style: TextStyle(color: colorScheme.error, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalLg,
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _group = _fetchGroup();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Retry',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final group = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    group.name,
                    style: textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (group.description != null && group.description!.isNotEmpty)
                  Column(
                    children: [
                      AppSpacing.verticalLg,
                      AppSpacing.verticalMd,
                      Text(
                        "Description : ${group.description!}",
                        style: textTheme.displayMedium,
                      ),
                    ],
                  ),

                AppSpacing.verticalLg,
                AppSpacing.verticalSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 24,
                            color: colorScheme.onSurface,
                          ),
                          AppSpacing.horizontalSm,
                          Text(
                            "Created ${_formatFullDate(group.createdAt)}",
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface.withAlpha(170),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.update,
                            size: 24,
                            color: colorScheme.onSurface,
                          ),
                          AppSpacing.horizontalSm,
                          Text(
                            "Updated ${_formatRelativeTime(group.updatedAt)}",
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface.withAlpha(170),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 32.0),
                Text(
                  "Members",
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalMd,
                Column(
                  children:
                      group.members.take(3).map((member) {
                        var isCreator = member.id == group.createdBy.id;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(12),
                                      border: BoxBorder.fromBorderSide(
                                        isCreator
                                            ? BorderSide(
                                              color: colorScheme.secondary,
                                              width: 5,
                                            )
                                            : BorderSide(
                                              color: colorScheme.outlineVariant,
                                              width: 5,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withAlpha(isDark ? 230 : 255),
                                      borderRadius: BorderRadius.circular(12),
                                      border: BoxBorder.fromBorderSide(
                                        isCreator
                                            ? BorderSide(
                                              color: colorScheme.secondary,
                                              width: 5,
                                            )
                                            : BorderSide(
                                              color: colorScheme.outlineVariant,
                                              width: 5,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                        isCreator
                                            ? BorderSide(
                                              color: colorScheme.secondary,
                                              width: 5,
                                            )
                                            : BorderSide(
                                              color: colorScheme.outlineVariant,
                                              width: 5,
                                            ),
                                  ),
                                  leading: CircleAvatar(
                                    foregroundColor: Colors.white,
                                    backgroundColor: colorScheme.primaryFixed,
                                    child: Text(member.name[0]),
                                  ),
                                  title: Text(member.name),
                                  subtitle: Text(member.email),
                                  trailing:
                                      isCreator
                                          ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary
                                                  .withAlpha(150),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Creator",
                                                  style: textTheme.bodyLarge
                                                      ?.copyWith(
                                                        color:
                                                            isDark
                                                                ? colorScheme
                                                                    .onSurface
                                                                : colorScheme
                                                                    .onSecondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                AppSpacing.horizontalSm,
                                                Icon(Icons.manage_accounts),
                                              ],
                                            ),
                                          )
                                          : null,
                                ),
                              ],
                            ),
                            AppSpacing.verticalSm,
                          ],
                        );
                      }).toList(),
                ),
                AppSpacing.verticalLg,
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      context.go("/group/${group.id}/members");
                    },
                    child: Text(
                      "View all members →",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
