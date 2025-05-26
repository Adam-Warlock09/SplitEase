import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/expense.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';

class GroupExpensesPage extends StatefulWidget {
  final String groupID;

  const GroupExpensesPage({super.key, required this.groupID});

  @override
  State<GroupExpensesPage> createState() => _GroupExpensesPageState();
}

class _GroupExpensesPageState extends State<GroupExpensesPage> {
  late Future<GroupDetailed?> _groupFuture;
  late Future<List<Expense>> _expensesFuture;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchGroup();
    _expensesFuture = _fetchExpenses();
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
      if (token == null) {
        return null;
      }
      final api = ApiService();
      final group = await api.getGroupById(widget.groupID, token);
      return group;
    } catch (e) {
      return null;
    }
  }

  Future<List<Expense>> _fetchExpenses() async {
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
      if (token == null) {
        return [];
      }
      final api = ApiService();
      final expenses = await api.fetchExpensesByGroupID(widget.groupID, token);
      return expenses;
    } catch (e) {
      return [];
    }
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  Future<void> _removeExpense(String expenseID) async {

    final colorScheme = Theme.of(context).colorScheme;
    final session = Provider.of<SessionProvider>(context, listen: false);
    if (!session.isLoggedIn) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      }
    }
    final token = session.token;
    if (token == null) {
      return;
    }
    final api = ApiService();
    final ok = await api.removeExpenseFromGroup(widget.groupID, expenseID, token);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Expense Deleted Successfully",
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.inversePrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() {
        _groupFuture = _fetchGroup();
        _expensesFuture = _fetchExpenses();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed To Remove Expense",
            style: TextStyle(color: colorScheme.onError, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() {
        _groupFuture = _fetchGroup();
        _expensesFuture = _fetchExpenses();
      });
    }

  }

  User _getUserName(String userID, GroupDetailed group) {
    return group.members
        .firstWhere((user) => user.id == userID, orElse: () => group.createdBy);
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(currentPage: "Group Expenses"),
      drawer: MySubDrawer(id: widget.groupID),
      body: FutureBuilder(
        future: _groupFuture,
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            );
          }

          if (groupSnapshot.hasError ||
              !groupSnapshot.hasData ||
              groupSnapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load Group Details. Unauthorized User or Invalid group.",
                    style: TextStyle(color: colorScheme.error, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalLg,
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _groupFuture = _fetchGroup();
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

          final group = groupSnapshot.data!;
          final session = Provider.of<SessionProvider>(context, listen: false);

          return LayoutBuilder(
            builder: (context, constraints) {

              final showLabel = constraints.maxWidth > 1000;

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
                    AppSpacing.verticalLg,
                    AppSpacing.verticalSm,
              
                    group.description != null && group.description!.isNotEmpty
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Description : ${group.description!}",
                                style: textTheme.displayMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(220),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 22,
                                        color: colorScheme.onSurface,
                                      ),
                                      AppSpacing.horizontalSm,
                                      Text(
                                        "Created ${_formatFullDate(group.createdAt)}",
                                        style: textTheme.titleLarge?.copyWith(
                                          color: colorScheme.onSurface.withAlpha(
                                            170,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppSpacing.verticalMd,
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.update,
                                        size: 22,
                                        color: colorScheme.onSurface,
                                      ),
                                      AppSpacing.horizontalSm,
                                      Text(
                                        "Updated ${_formatRelativeTime(group.updatedAt)}",
                                        style: textTheme.titleLarge?.copyWith(
                                          color: colorScheme.onSurface.withAlpha(
                                            170,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                        : Row(
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Group Expenses :",
                            style: textTheme.displayMedium,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: showLabel
                              ? ElevatedButton.icon(
                                  key: const ValueKey('LabelButton'),
                                  onPressed: () {
                                    context.go('/group/${widget.groupID}/expenses/create');
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
                                  icon: Icon(Icons.add_box, size: 24,),
                                  label:Text(
                                      "Create New Expense",
                                      style: textTheme.titleLarge?.copyWith(
                                        color: colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                )
                              : Tooltip(
                                message: "Create New Expense",
                                  key: const ValueKey('noLabelButton'),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/groups/${widget.groupID}/expenses/create');
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
                                    child: Icon(Icons.add_box, size: 24,),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder(
                          future: _expensesFuture,
                          builder: (context, expensesSnapshot) {
                      
                            if (expensesSnapshot.connectionState == ConnectionState.waiting || !expensesSnapshot.hasData || expensesSnapshot.data == null) {
                      
                              return Center(
                                child: CircularProgressIndicator(color: colorScheme.secondary,),
                              );
                      
                            }
                      
                            if (expensesSnapshot.hasError) {
                      
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Failed to load Expenses. Unauthorized User or Invalid group.",
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontSize: 24,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    AppSpacing.verticalLg,
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _expensesFuture = _fetchExpenses();
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
                      
                            final expenses = expensesSnapshot.data!;
                            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      
                            if (expenses.isEmpty) {
                      
                              return Center(
                                child: Text(
                                  "No Expenses Added Yet.",
                                  style: textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withAlpha(220),
                                  ),
                                ),
                              );
                      
                            }
                      
                            return ListView.separated(
                              itemCount: expenses.length,
                              separatorBuilder: (context, index) => AppSpacing.verticalMd,
                              itemBuilder: (context, index) {
                      
                                final expense = expenses[index];
                                final expanded = _expandedIds.contains(expense.id);
                                final paidByName = _getUserName(expense.paidBy, group).name;
                      
                                final isCreator = expense.paidBy == session.userID;
                      
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                      isCreator
                                          ? BorderSide(color: colorScheme.primary, width: 5)
                                          : BorderSide(color: colorScheme.outlineVariant, width: 5),
                                  ),
                                  elevation: 3,
                                  color: Colors.white70,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: isCreator
                                                    ? colorScheme.secondary.withAlpha(120)
                                                    : Theme.of(context).scaffoldBackgroundColor.withAlpha(isDarkMode ? 230 : 100),
                                            borderRadius: BorderRadius.circular(12)
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    expense.title,
                                                    style: textTheme.displayLarge?.copyWith(
                                                      color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '₹${expense.amount.toStringAsFixed(2)}',
                                                  style: textTheme.displayLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isCreator ? isDarkMode ? Color(0xFF6200EE) : colorScheme.primary : colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AppSpacing.verticalLg,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Paid By : $paidByName',
                                                  style: textTheme.displayMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isCreator ? colorScheme.onSecondary.withAlpha(200) : colorScheme.onSurface.withAlpha(200),
                                                  ),
                                                ),
                                                Text(
                                                  '${expense.splitType.toUpperCase()} Split',
                                                  style: textTheme.displayMedium?.copyWith(
                                                      color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                    ),
                                                ),
                                                Text(
                                                  "Created ${_formatFullDate(expense.createdAt!)}",
                                                  style: textTheme.titleLarge?.copyWith(
                                                    color: isCreator ? colorScheme.onSecondary.withAlpha(190) : colorScheme.onSurface.withAlpha(190),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AppSpacing.verticalMd,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                                                  Text(
                                                    'Notes : ${expense.notes}',
                                                    style: textTheme.titleLarge?.copyWith(
                                                      fontSize: 20,
                                                      color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                AppSpacing.horizontalMd,
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    if (isCreator) ...[
                                                      IconButton(
                                                        icon: Icon(Icons.remove_circle, size: 28,),
                                                        color: Color(0xFFB00020),
                                                        tooltip: 'Delete Expense',
                                                        onPressed: () async {
                      
                                                          final confirmed = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              icon: Icon(Icons.warning, color: colorScheme.error, size: 36,),
                                                              title: Text('Confirm Deletion', style: textTheme.displayMedium,),
                                                              content: Text('This will permanently delete "${expense.title}" Expense from the group', style: textTheme.titleLarge,),
                                                              actions: [
                                                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                                              ],
                                                            ),
                                                          );
                      
                                                          if (confirmed == true){
                                                            await _removeExpense(expense.id!);
                                                          }
                      
                                                        },
                                                      ),
                                                      AppSpacing.horizontalMd,
                                                    ],
                                                    TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                                                        iconColor: colorScheme.onSecondary,
                                                        iconSize: 36,
                                                        backgroundColor: isCreator ? isDarkMode ? colorScheme.surfaceContainer.withAlpha(40) : colorScheme.surfaceContainer.withAlpha(150) : colorScheme.secondaryContainer.withAlpha(15),
                                                      ),
                                                      onPressed: () => _toggleExpanded(expense.id!),
                                                      icon: Icon(
                                                        expanded ? Icons.expand_less : Icons.expand_more,
                                                        color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                      ),
                                                      label: Text(
                                                        expanded ? 'Hide Splits' : 'View Splits',
                                                        style: textTheme.titleLarge?.copyWith(
                                                          fontSize: 20,
                                                          color: isCreator ? colorScheme.onSecondary : isDarkMode ? colorScheme.secondary : colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                                        
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              child: expanded
                                                ? Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 32.0,
                                                    vertical: 16.0
                                                  ),
                                                  child: Column(
                                                    key: ValueKey('expanded_${expense.id}'),
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: expense.splits.entries.map((entry) {
                                                      final member = _getUserName(entry.key, group);
                                                      final isPayer = expense.paidBy == member.id;
                                                      return ListTile(
                                                        contentPadding: const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                          side: isPayer
                                                            ? BorderSide(
                                                              color: Colors.black,
                                                              width: 5,
                                                            )
                                                            : BorderSide.none,
                                                        ),
                                                        leading: CircleAvatar(
                                                          foregroundColor: Colors.white,
                                                          backgroundColor: colorScheme.tertiary,
                                                          child: Text(member.name[0]),
                                                        ),
                                                        title: Text(
                                                          member.name,
                                                          style: TextStyle(
                                                            color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          member.email,
                                                          style: TextStyle(
                                                            color: isCreator ? colorScheme.onSecondary : colorScheme.onSurface,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 16, 
                                                          ),
                                                        ),
                                                        trailing: Text(
                                                          '₹${entry.value.toStringAsFixed(2)}',
                                                          style: textTheme.displayLarge?.copyWith(
                                                            fontWeight: FontWeight.w500,
                                                            color: isCreator ? Color(0xFF6200EE) : colorScheme.secondary,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                                : const SizedBox.shrink(key: ValueKey('collapsed')),
                                            ),
                                                        
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                      
                              },
                            );
                      
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }
}
