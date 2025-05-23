import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:split_ease/models/group.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/theme/themeNotifier.dart';

class GroupCard extends StatelessWidget {

  final Group group;
  final String currentUserID;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.currentUserID,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    context.watch<ThemeNotifier>();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isAdmin = group.createdBy == currentUserID;
    final onSurface = isAdmin ? colorScheme.onSecondary : colorScheme.onSurface;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isAdmin
                ? BorderSide(color: colorScheme.primary, width: 3)
                : BorderSide(color: colorScheme.outlineVariant, width: 3),
      ),
      color: Colors.white70,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isAdmin
                        ? colorScheme.secondary.withAlpha(160)
                        : Theme.of(context).scaffoldBackgroundColor.withAlpha(isDarkMode ? 230 : 255),
                borderRadius: BorderRadius.circular(12)
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          group.name,
                          style: textTheme.titleLarge?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode ? colorScheme.primaryFixed.withAlpha(175) : colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            'Admin',
                            style: textTheme.bodyLarge?.copyWith(
                              color: isDarkMode ? colorScheme.onPrimary : colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ],
                  ),
                  AppSpacing.verticalSm,
                  if (group.description != null && group.description!.isNotEmpty)
                    Text(
                      group.description!,
                      style: textTheme.bodyLarge?.copyWith(
                        color: onSurface,
                      ),
                    ),
                  AppSpacing.verticalMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${group.members.length} members',
                        style: textTheme.bodyMedium?.copyWith(
                          color: onSurface,
                          fontSize: 12,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Created on ${_formatFullDate(group.createdAt)}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: onSurface,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Updated ${_formatRelativeTime(group.updatedAt)}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    
  }

  String _formatFullDate(DateTime date) {
    final formatter = DateFormat('MMMM d, y');
    return formatter.format(date);
  }

  String _formatRelativeTime(DateTime date) {
    return timeago.format(date, allowFromNow: false);
  }

}