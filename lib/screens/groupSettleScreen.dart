import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/settlement.dart';
import 'package:split_ease/models/user.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';

class GroupSettlePage extends StatefulWidget {
  final String groupID;
  const GroupSettlePage({super.key, required this.groupID});

  @override
  State<GroupSettlePage> createState() => _GroupSettlePageState();
}

class _GroupSettlePageState extends State<GroupSettlePage> {
  late Future<GroupDetailed?> _groupFuture;
  late Future<List<Settlement>> _settlementsFuture;
  final TextEditingController _searchController = TextEditingController();

  List<Settlement> _filteredSettlements = [];

  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchGroup();
    _settlementsFuture = _fetchSettlements();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<List<Settlement>> _fetchSettlements() async {
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
      final settlements = await api.fetchSettlementsByGroupID(
        widget.groupID,
        token,
      );
      return settlements;
    } catch (e) {
      return [];
    }
  }

  Future<void> _addTransaction(Settlement settlement, String groupName) async {

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
    final transaction = await api.createTransaction("Settlement for group $groupName", settlement.amount, settlement.fromID, settlement.toID, widget.groupID, token);
    if (!mounted) return;
    if (transaction != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Transaction Added Successfully",
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
        _searchController.clear();
        _filteredSettlements = [];
        _settlementsFuture = _fetchSettlements();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed To Add Transaction",
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
        _searchController.clear();
        _filteredSettlements = [];
        _settlementsFuture = _fetchSettlements();
      });
    }
  }

  User _getUserName(String userID, GroupDetailed group) {
    return group.members.firstWhere(
      (user) => user.id == userID,
      orElse: () => group.createdBy,
    );
  }

  String _formatFullDate(DateTime date) {
    final formatter = DateFormat('MMMM d, y');
    return formatter.format(date);
  }

  String _formatRelativeTime(DateTime date) {
    return timeago.format(date, allowFromNow: false);
  }

  void _onSearchChanged() async {
    final query = _searchController.text.toLowerCase().trim();

    final session = Provider.of<SessionProvider>(context, listen: false);
    if (!session.isLoggedIn) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final settlements = await _settlementsFuture;
      if (!mounted) return;
      if (settlements.isEmpty) return;

      final group = await _groupFuture;
      if (!mounted) return;
      if (group == null || group.members.isEmpty) return;

      final Map<String, Map<String, String>> userMap = Map.fromEntries(
        group.members.map(
          (member) =>
              MapEntry(member.id, {"name": member.name, "email": member.email}),
        ),
      );

      if (query.isEmpty) {
        setState(() {
          _filteredSettlements = settlements;
        });
      } else {
        setState(() {
          _filteredSettlements =
              settlements
                  .where(
                    (settlement) =>
                        userMap[settlement.fromID]!["name"]!
                            .toLowerCase()
                            .contains(query) ||
                        userMap[settlement.toID]!["email"]!
                            .toLowerCase()
                            .contains(query),
                  )
                  .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(currentPage: "Settle Up"),
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
      
          return SingleChildScrollView(
            child: LayoutBuilder(
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
                                            color: colorScheme.onSurface
                                                .withAlpha(170),
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
                                            color: colorScheme.onSurface
                                                .withAlpha(170),
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
                                        color: colorScheme.onSurface.withAlpha(
                                          170,
                                        ),
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
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              child:
                                  showLabel
                                      ? ElevatedButton.icon(
                                        key: const ValueKey('LabelButton'),
                                        onPressed: () {
                                          setState(() {
                                            _groupFuture = _fetchGroup();
                                            _settlementsFuture =
                                                _fetchSettlements();
                                            _searchController.text = "";
                                            _filteredSettlements = [];
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.secondary,
                                          foregroundColor:
                                              colorScheme.onSecondary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 3,
                                        ),
                                        icon: Icon(Icons.refresh, size: 24),
                                        label: Text(
                                          "Refresh Settlements",
                                          style: textTheme.titleLarge?.copyWith(
                                            color: colorScheme.onSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      : Tooltip(
                                        message: "Refresh Settlements",
                                        key: const ValueKey('noLabelButton'),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _groupFuture = _fetchGroup();
                                              _settlementsFuture =
                                                  _fetchSettlements();
                                              _searchController.text = "";
                                              _filteredSettlements = [];
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.secondary,
                                            foregroundColor:
                                                colorScheme.onSecondary,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            elevation: 3,
                                          ),
                                          child: Icon(Icons.add_box, size: 24),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder(
                          future: _settlementsFuture,
                          builder: (context, settlementsSnapshot) {
                            if (settlementsSnapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !settlementsSnapshot.hasData ||
                                settlementsSnapshot.data == null) {
                              return Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: colorScheme.secondary,
                                    ),
                                    Text(
                                      "Kindly wait, Settlements Loading...",
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurface.withAlpha(
                                          200,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                              
                            if (settlementsSnapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Failed to load Settlements. Unauthorized User or Invalid group.",
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
                                          _settlementsFuture =
                                              _fetchSettlements();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.secondary,
                                        foregroundColor:
                                            colorScheme.onSecondary,
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
                              
                            final settlements = settlementsSnapshot.data!;
                            final isDarkMode =
                                Theme.of(context).brightness == Brightness.dark;
                            final session = Provider.of<SessionProvider>(
                              context,
                              listen: false,
                            );
                              
                            if (settlements.isEmpty) {
                              return Center(
                                child: Text(
                                  "🎉 All dues are settled in this group!",
                                  style: textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withAlpha(220),
                                  ),
                                ),
                              );
                            }
                              
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 5,
                                ),
                              ),
                              elevation: 3,
                              color: Colors.white70,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withAlpha(isDarkMode ? 230 : 100),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppSpacing.verticalMd,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Settlement List :",
                                              style: textTheme.displayMedium,
                                            ),
                                            AppSpacing.horizontalLg,
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Search Settlement Payer',
                                                  prefixIcon: Icon(
                                                    Icons.manage_search,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AppSpacing.verticalLg,
                                        AppSpacing.verticalMd,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32.0,
                                          ),
                                          child: (_searchController.text.isEmpty || _filteredSettlements.isNotEmpty)
                                          ? ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: _searchController.text.isEmpty ? settlements.length : _filteredSettlements.length,
                                            separatorBuilder: (context, index) => AppSpacing.verticalMd,
                                            itemBuilder:(context, index) {
                                              
                                              Settlement settlement;
                                              if (_searchController.text.isEmpty && _filteredSettlements.isEmpty) {
                                                settlement = settlements[index];
                                              } else {
                                                settlement = _filteredSettlements[index];
                                              }
                              
                                              final isPayer = session.userID == settlement.fromID;
                                              final isPayee = session.userID == settlement.toID;
                                              final isInvolved = isPayee || isPayer;
                              
                                              final fromUser = _getUserName(settlement.fromID, group);
                                              final toUser = _getUserName(settlement.toID, group);
                              
                                              return ListTile(
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: isInvolved ? colorScheme.primary : colorScheme.outlineVariant,
                                                    width: 3,
                                                  ),
                                                ),
                                                leading: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: colorScheme.primaryFixed,
                                                      radius: 20.0,
                                                      child: Text(fromUser.name[0]),
                                                    ),
                                                    AppSpacing.horizontalSm,
                                                    Icon(Icons.arrow_forward, size: 30.0,),
                                                    AppSpacing.horizontalSm,
                                                    CircleAvatar(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: colorScheme.tertiary,
                                                      radius: 20.0,
                                                      child: Text(toUser.name[0]),
                                                    ),
                                                  ],
                                                ),
                                                title: Text(
                                                  '${fromUser.name} → ${toUser.name}',
                                                  style: textTheme.displayMedium,
                                                ),
                                                subtitle: Text(
                                                  '${fromUser.email} → ${toUser.email}',
                                                  style: textTheme.titleLarge,
                                                ),
                                                tileColor: isInvolved ? colorScheme.inversePrimary.withAlpha(150) : isDarkMode ? Theme.of(context).scaffoldBackgroundColor.withAlpha(230) : colorScheme.onSurface.withAlpha(30),
                                                trailing: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '₹${settlement.amount.toStringAsFixed(2)}',
                                                      style: textTheme.displayLarge?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: isInvolved ? isDarkMode ? isPayer ? colorScheme.error : Color.fromARGB(255, 7, 125, 58) : isPayer ? colorScheme.error : const Color.fromARGB(255, 29, 177, 34) : colorScheme.primary,
                                                      ),
                                                    ),
                                                    if (isInvolved) ...[
                                                      AppSpacing.horizontalMd,
                                                      IconButton(
                                                        icon: Icon(Icons.add_circle, size: 28,),
                                                        color: colorScheme.primary,
                                                        tooltip: 'Add Transaction',
                                                        onPressed: () async {
                      
                                                          final confirmed = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              icon: Icon(Icons.add_circle, color: colorScheme.inversePrimary, size: 36,),
                                                              title: Text('Confirm Transaction', style: textTheme.displayMedium,),
                                                              content: Text('This will add a transaction for this settlement to the group', style: textTheme.titleLarge,),
                                                              actions: [
                                                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Add', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                                              ],
                                                            ),
                                                          );
                      
                                                          if (confirmed == true){
                                                            await _addTransaction(settlement, group.name);
                                                          }
                      
                                                        },
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              );
                              
                                            },
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                                            child: Center(
                                              child: Text(
                                                "No Settlements Found",
                                                style: textTheme.displayMedium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
