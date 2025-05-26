import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/transaction.dart';
import 'package:split_ease/models/user.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';

class GroupTransactionsPage extends StatefulWidget {
  final String groupID;
  const GroupTransactionsPage({super.key, required this.groupID});

  @override
  State<GroupTransactionsPage> createState() => _GroupTransactionsPageState();
}

class _GroupTransactionsPageState extends State<GroupTransactionsPage> {

  late Future<GroupDetailed?> _groupFuture;
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchGroup();
    _transactionsFuture = _fetchTransactions();
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

  Future<List<Transaction>> _fetchTransactions() async {
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
      final transactions = await api.fetchTransactionsByGroupID(widget.groupID, token);
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<void> _removeTransaction(String transactionID) async {

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
    final ok = await api.removeTransactionFromGroup(widget.groupID, transactionID, token);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Transaction Deleted Successfully",
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
        _transactionsFuture = _fetchTransactions();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed To Remove Transaction",
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
        _transactionsFuture = _fetchTransactions();
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
      appBar: MyAppBar(currentPage: "Group Transactions"),
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
                            "Group Transactions :",
                            style: textTheme.displayMedium,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: showLabel
                              ? ElevatedButton.icon(
                                  key: const ValueKey('LabelButton'),
                                  onPressed: () {
                                    context.go('/group/${widget.groupID}/transactions/create');
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
                                      "Create New Transaction",
                                      style: textTheme.titleLarge?.copyWith(
                                        color: colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                )
                              : Tooltip(
                                message: "Create New Transaction",
                                  key: const ValueKey('noLabelButton'),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/groups/${widget.groupID}/transactions/create');
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
                          future: _transactionsFuture,
                          builder: (context, transactionsSnapshot) {

                            if (transactionsSnapshot.connectionState == ConnectionState.waiting || !transactionsSnapshot.hasData || transactionsSnapshot.data == null) {
                              return Center(
                                child: CircularProgressIndicator(color: colorScheme.secondary,),
                              );
                            }

                            if (transactionsSnapshot.hasError) {
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
                                          _transactionsFuture = _fetchTransactions();
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

                            final transactions = transactionsSnapshot.data!;
                            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                            if (transactions.isEmpty) {
                              return Center(
                                child: Text(
                                  "No Transactions Added Yet.",
                                  style: textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withAlpha(220),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: transactions.length,
                              separatorBuilder: (context, index) => AppSpacing.verticalMd,
                              itemBuilder: (context, index) {

                                final transaction = transactions[index];
                                final fromName = _getUserName(transaction.fromUser, group).name;
                                final toName = _getUserName(transaction.toUser, group).name;
                                final hasNotes = transaction.notes != null && (transaction.notes?.isNotEmpty ?? false);

                                final isInvolved = transaction.fromUser == session.userID || transaction.toUser == session.userID;
                                final isPayer = transaction.fromUser == session.userID;
                                final isPayee = transaction.toUser == session.userID;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                      isInvolved
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
                                            color: isInvolved
                                                    ? colorScheme.secondary.withAlpha(120)
                                                    : Theme.of(context).scaffoldBackgroundColor.withAlpha(isDarkMode ? 230 : 100),
                                            borderRadius: BorderRadius.circular(12)
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    isPayer ? 'Paid By : $fromName (You)' : 'Paid By : $fromName',
                                                    style: textTheme.displayLarge?.copyWith(
                                                      color: isInvolved ? colorScheme.onSecondary : colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '₹${transaction.amount.toStringAsFixed(2)}',
                                                  style: textTheme.displayLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isInvolved ? isDarkMode ? isPayer ? colorScheme.error : colorScheme.inversePrimary : isPayer ? colorScheme.error : colorScheme.inversePrimary : colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AppSpacing.verticalLg,
                                            if (!hasNotes)
                                              AppSpacing.verticalMd,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isPayee ? 'Paid To : $toName (You)' : 'Paid To : $toName',
                                                  style: textTheme.displayMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isInvolved ? colorScheme.onSecondary.withAlpha(200) : colorScheme.onSurface.withAlpha(200),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    if (!hasNotes && isInvolved) ...[
                                                      IconButton(
                                                        icon: Icon(Icons.remove_circle, size: 28,),
                                                        color: Color(0xFFB00020),
                                                        tooltip: 'Delete Transaction',
                                                        onPressed: () async {
                      
                                                          final confirmed = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              icon: Icon(Icons.warning, color: colorScheme.error, size: 36,),
                                                              title: Text('Confirm Deletion', style: textTheme.displayMedium,),
                                                              content: Text('This will permanently delete this transaction from the group', style: textTheme.titleLarge,),
                                                              actions: [
                                                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                                              ],
                                                            ),
                                                          );
                      
                                                          if (confirmed == true){
                                                            await _removeTransaction(transaction.id);
                                                          }
                      
                                                        },
                                                      ),
                                                      AppSpacing.horizontalMd,
                                                    ],
                                                    Text(
                                                      "Created ${_formatFullDate(transaction.createdAt)}",
                                                      style: textTheme.titleLarge?.copyWith(
                                                        color: isInvolved ? colorScheme.onSecondary.withAlpha(190) : colorScheme.onSurface.withAlpha(190),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if(hasNotes)
                                            AppSpacing.verticalLg,
                                            if (hasNotes)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Notes : ${transaction.notes!}',
                                                  style: textTheme.titleLarge?.copyWith(
                                                    fontSize: 20,
                                                    color: isInvolved ? colorScheme.onSecondary : colorScheme.onSurface,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (isInvolved)
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                      
                                                    final confirmed = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        icon: Icon(Icons.warning, color: colorScheme.error, size: 36,),
                                                        title: Text('Confirm Deletion', style: textTheme.displayMedium,),
                                                        content: Text('This will permanently delete this transaction from the group', style: textTheme.titleLarge,),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                                        ],
                                                      ),
                                                    );
                
                                                    if (confirmed == true){
                                                      await _removeTransaction(transaction.id);
                                                    }
                
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: colorScheme.error,
                                                    foregroundColor: colorScheme.onError,
                                                  ),
                                                  icon: Icon(Icons.remove_circle, size: 28, color: colorScheme.onError),
                                                  label: Text(
                                                    'Delete',
                                                    style: textTheme.titleLarge?.copyWith(
                                                      color: colorScheme.onError,
                                                    ),
                                                  ),
                                                ),
                                              ],
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

            },
          );

        },
      ),
    );

  }
}