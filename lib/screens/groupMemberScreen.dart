import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/user.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupID;

  const GroupMembersPage({super.key, required this.groupID});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> with SingleTickerProviderStateMixin {

  late Future<GroupDetailed?> _groupFuture;
  late Future<List<User>> _allUsersFuture;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();

    _groupFuture = _fetchGroup();
    _allUsersFuture = _fetchAllUsers();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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

  Future<List<User>> _fetchAllUsers() async {
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
      final users = await api.fetchSearchSpace(widget.groupID, token);
      return users;
    } catch (e) {
      return [];
    }
  }

  void _onSearchChanged() async {

    final query = _searchController.text.toLowerCase().trim();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final group = await _groupFuture;
      final allUsers = await _allUsersFuture;

      if (group == null || allUsers.isEmpty) return;

      if(!mounted) return;

      if (query.isEmpty) {
        setState(() {
          _filteredUsers = [];
        });
      } else {
        setState(() {
          _filteredUsers = allUsers
            .where((user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
            .where((user) => !group.members.any((m) => m.id == user.id))
            .toList();
        });
      }
    });

  }

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredUsers.clear();
      }
    });
  }

  Future<void> _addMember(String userID) async {

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
    final addedUser = await api.addMemberToGroup(widget.groupID, userID, token);
    if (!mounted) return;
    if (addedUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Member Added Successfully",
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
        _isSearching = false;
        _searchController.clear();
        _filteredUsers.clear();
        _allUsersFuture = _fetchAllUsers();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed To Add Member",
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
        _isSearching = false;
        _searchController.clear();
        _filteredUsers.clear();
        _allUsersFuture = _fetchAllUsers();
      });
    }
  }

  Future<void> _removeMember(String userID) async {

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
    final ok = await api.removeMemberFromGroup(widget.groupID, userID, token);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Member Removed Successfully",
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
        _isSearching = false;
        _searchController.clear();
        _filteredUsers.clear();
        _allUsersFuture = _fetchAllUsers();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed To Remove Member",
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
        _isSearching = false;
        _searchController.clear();
        _filteredUsers.clear();
        _allUsersFuture = _fetchAllUsers();
      });
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
      appBar: MyAppBar(currentPage: "Group Members"),
      drawer: MySubDrawer(id: widget.groupID),
      body: FutureBuilder<GroupDetailed?>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
                        _isSearching = false;
                        _searchController.clear();
                        _filteredUsers.clear();
                        _allUsersFuture = _fetchAllUsers();
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
          return FutureBuilder(
            future: _allUsersFuture,
            builder: (context, usersSnapshot) {

              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.secondary),
                );
              }

              if (usersSnapshot.hasError || !usersSnapshot.hasData || usersSnapshot.data == null){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Failed to load search space for Users. Unauthorized User or Invalid group.",
                        style: TextStyle(color: colorScheme.error, fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalLg,
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _groupFuture = _fetchGroup();
                            _isSearching = false;
                            _searchController.clear();
                            _filteredUsers.clear();
                            _allUsersFuture = _fetchAllUsers();
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

              final session = Provider.of<SessionProvider>(context);

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
                                          color: colorScheme.onSurface.withAlpha(170),
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
                                          color: colorScheme.onSurface.withAlpha(170),
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
                        Divider(height: 32.0,),
                        Expanded(
                          child: Stack(
                            children: [
                              Scrollbar(
                                thumbVisibility: false,
                                trackVisibility: false,
                                thickness: 0,
                                child: SingleChildScrollView(
                                  primary: true,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        switchInCurve: Curves.easeIn,
                                        switchOutCurve: Curves.easeOut,
                                        child: _isSearching
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _searchController,
                                                        autofocus: true,
                                                        decoration: InputDecoration(
                                                          labelText: 'Search Users',
                                                          prefixIcon: Icon(Icons.person_search),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                                                        ),
                                                      ),
                                                    ),
                                                    AppSpacing.horizontalMd,
                                                    IconButton(
                                                      icon: Icon(Icons.close),
                                                      tooltip: 'Cancel',
                                                      onPressed: () {
                                                        setState(() {
                                                          _isSearching = false;
                                                          _searchController.clear();
                                                          _filteredUsers.clear();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                AppSpacing.verticalMd,
                                                Container(
                                                  constraints: BoxConstraints(maxHeight: 200),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: colorScheme.outline),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: _filteredUsers.isEmpty
                                                    ? Padding(
                                                        padding: const EdgeInsets.all(16),
                                                        child: Text(
                                                          _searchController.text.isEmpty
                                                            ? 'Start Typing To Search Users'
                                                            : 'No Users Found',
                                                          style: textTheme.displayMedium?.copyWith(
                                                            color: colorScheme.onSurface.withAlpha(170),
                                                          ),
                                                        ),
                                                      )
                                                    : Scrollbar(
                                                      child: ListView.separated(
                                                        shrinkWrap: true,
                                                        itemCount: _filteredUsers.length,
                                                        separatorBuilder: (context, index) => AppSpacing.verticalSm,
                                                        itemBuilder:(context, index) {
                                                          
                                                          final user = _filteredUsers[index];
                                      
                                                          return ListTile(
                                                            leading: CircleAvatar(
                                                              foregroundColor: Colors.white,
                                                              backgroundColor: colorScheme.primaryFixedDim,
                                                              child: Text(user.name[0]),
                                                            ),
                                                            title: Text(user.name),
                                                            subtitle: Text(user.email),
                                                            trailing: IconButton(
                                                              icon: Icon(Icons.person_add, color: colorScheme.secondary,),
                                                              tooltip: 'Add Member',
                                                              onPressed: () => _addMember(user.id),
                                                            ),
                                                          );
                                      
                                                        },
                                                      ),
                                                    ),
                                                ),
                                                AppSpacing.verticalLg,
                                              ],
                                            ) 
                                          : group.createdBy.id == session.userID
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: ElevatedButton.icon(
                                                  icon: Icon(Icons.person_add, size: 32, color: colorScheme.onPrimary,),
                                                  label: Text('Add Users', style: textTheme.displayMedium?.copyWith(color: colorScheme.onPrimary),),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    backgroundColor: colorScheme.primary,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isSearching = true;
                                                      _searchController.clear();
                                                      _filteredUsers.clear();
                                                    });
                                                  },
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                      if (group.createdBy.id == session.userID)
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
                                            group.members.map((member) {
                                              final session = Provider.of<SessionProvider>(context, listen: false);
                                              var isCreator = member.id == group.createdBy.id;
                                              final isUserCreator = group.createdBy.id == session.userID;
                                              var isCurrentUser = member.id == session.userID;
                                              var canRemove = !isCurrentUser && isUserCreator;
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
                                                              : canRemove
                                                                ? IconButton(
                                                                    icon: Icon(Icons.remove_circle, color: colorScheme.error,),
                                                                    tooltip: 'Remove Member',
                                                                    onPressed: () async {
                                  
                                                                      final confirmed = await showDialog<bool>(
                                                                        context: context,
                                                                        builder: (context) => AlertDialog(
                                                                          icon: Icon(Icons.warning, color: colorScheme.error, size: 36,),
                                                                          title: Text('Confirm Removal', style: textTheme.displayMedium,),
                                                                          content: Text('This will permanently remove ${member.name} from the group', style: textTheme.titleLarge,),
                                                                          actions: [
                                                                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                                                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Remove', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                                                          ],
                                                                        ),
                                                                      );
                                  
                                                                      if (confirmed == true){
                                                                        await _removeMember(member.id);
                                                                      }
                                  
                                                                    },
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
                                    ],
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
          );

        },
      ),
    );

  }

}