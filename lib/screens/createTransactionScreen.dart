import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/user.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';

class CreateTransactionPage extends StatefulWidget {
  final String groupID;
  const CreateTransactionPage({super.key, required this.groupID});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  
  late Future<GroupDetailed?> _groupFuture;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPayer = true;
  String? _selectedID;

  final TextEditingController _searchController = TextEditingController();

  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchGroup();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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

      final group = await _groupFuture;
      if (group == null) return;
      final allUsers = group.members;

      if (allUsers.isEmpty) return;

      if(!mounted) return;

      if (query.isEmpty) {
        setState(() {
          _filteredUsers = allUsers.where((user) => user.id != session.userID).toList();
        });
      } else {
        setState(() {
          _filteredUsers = allUsers
            .where((user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
            .where((user) => user.id != session.userID)
            .toList();
        });
      }
    });

  }

  bool get isValidForm {
    return _selectedID != null;
  }

  Future<void> _handleSubmit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final session = Provider.of<SessionProvider>(context, listen: false);
    if (!session.isLoggedIn) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      }
      return;
    }

    if (!mounted) return;

    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final amount = double.parse(double.parse(_amountController.text).toStringAsFixed(2));
    final fromUser = _isPayer ? session.userID : _selectedID;
    final toUser = _isPayer ? _selectedID : session.userID;
    final colorScheme = Theme.of(context).colorScheme;

    try {

      final api = ApiService();
      final responseData = await api.createTransaction(notes, amount, fromUser!, toUser!, widget.groupID, session.token);

      if(!mounted) return;

      if (responseData == null) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error while creating transaction!",
              style: TextStyle(
                color: colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Transaction Created Successfully!",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.inversePrimary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 2500));

        if (!mounted) return;

        context.go("/group/${widget.groupID}/transactions");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to create transaction. Error : $e!",
              style: TextStyle(
                color: colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
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
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(
        currentPage: "Create New Transaction",
      ),
      drawer: MySubDrawer(id: widget.groupID),
      body: FutureBuilder(
        future: _groupFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.secondary,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to Load Group Details. Unauthorized User or Invalid GroupID.",
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

          final group = snapshot.data!;
          final session = Provider.of<SessionProvider>(context, listen: false);
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group : ${group.name}",
                        style: textTheme.displayLarge,
                      ),
                      AppSpacing.verticalLg,
                      AppSpacing.verticalLg,
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
                                ],
                                
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  hintText: '0.00',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.currency_rupee),
                                  filled: true,
                                  fillColor: colorScheme.onSurface.withAlpha(50),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter amount';
                                  }
                                  try {
                                    double.parse(value);
                                    if (value.startsWith('.') && value.length == 1) return 'Invalid number';
                                    if (double.parse(double.parse(value).toStringAsFixed(2)) <= 0) return 'Amount can\'t be zero';
                                    return null;
                                  } catch (e) {
                                    return 'Invalid number';
                                  }
                                },
                                onFieldSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    final parsed = double.tryParse(value) ?? 0;
                                    _amountController.text = parsed.toStringAsFixed(2);
                                  }
                                },
                              ),
                            ),
                            AppSpacing.verticalLg,
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: TextFormField(
                                maxLength: 75,
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: "Notes (Optional)",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.notes),
                                  filled: true,
                                  fillColor: colorScheme.onSurface.withAlpha(50),
                                ),
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                                validator: (value) {
                                  if (value != null && value.length > 75) {
                                    return "Notes too long (Max 75 chars).";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            AppSpacing.verticalLg,
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runAlignment: WrapAlignment.spaceEvenly,
                              spacing: 24.0,
                              children: [
                                Text(
                                  "Who's Paying ? ",
                                  style: textTheme.displayMedium,
                                ),
                                ChoiceChip(
                                  label: Text(
                                    "I'm Paying",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight:
                                        _isPayer
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color:
                                        _isPayer
                                          ? colorScheme.onSecondary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface.withAlpha(50),
                                  selectedColor:
                                      isDarkMode
                                          ? colorScheme.secondary.withAlpha(200)
                                          : colorScheme.primary.withAlpha(150),
                                  selected: _isPayer,
                                  pressElevation: 3,
                                  shape: StadiumBorder(
                                    side:
                                        !_isPayer
                                            ? BorderSide(
                                              color:
                                                  !isDarkMode
                                                      ? colorScheme.secondary
                                                      : colorScheme.primary,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _isPayer = true;
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: Text(
                                    "Someone Else",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight:
                                          !_isPayer
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                      color:
                                          !_isPayer
                                              ? colorScheme.onSecondary
                                              : colorScheme.onSurface,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface.withAlpha(50),
                                  selectedColor:
                                      isDarkMode
                                          ? colorScheme.secondary.withAlpha(200)
                                          : colorScheme.primary.withAlpha(150),
                                  selected: !_isPayer,
                                  pressElevation: 3,
                                  shape: StadiumBorder(
                                    side:
                                        _isPayer
                                            ? BorderSide(
                                              color:
                                                  !isDarkMode
                                                      ? colorScheme.secondary
                                                      : colorScheme.primary,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _isPayer = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            AppSpacing.verticalLg,
                            Card(
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
                                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(isDarkMode ? 230 : 100),
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Member List :",
                                              style: textTheme.displayMedium,
                                            ),
                                            AppSpacing.horizontalLg,
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  labelText: _isPayer ? 'Search Recipient' : 'Search Payer',
                                                  prefixIcon: Icon(Icons.person_search),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AppSpacing.verticalLg,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32.0,
                                          ),
                                          child: (_searchController.text.isEmpty || _filteredUsers.isNotEmpty)
                                          ? ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: _searchController.text.isEmpty ? group.members.length - 1 : _filteredUsers.length,
                                            separatorBuilder: (context, index) => AppSpacing.verticalMd,
                                            itemBuilder: (context, index) {
                                              
                                              User member;
                                              if (_searchController.text.isEmpty && _filteredUsers.isEmpty) {
                                                member = group.members.where((user) => user.id != session.userID).toList()[index];
                                              } else {
                                                member = _filteredUsers[index];
                                              }

                                              final isSelected = _selectedID == member.id;

                                              return ListTile(
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                                    width: 3,
                                                  ),
                                                ),
                                                leading: CircleAvatar(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: colorScheme.primaryFixed,
                                                  child: Text(member.name[0]),
                                                ),
                                                title: Text(
                                                  member.name
                                                ),
                                                subtitle: Text(member.email),
                                                tileColor: isSelected ? colorScheme.inversePrimary.withAlpha(150) : isDarkMode ? Theme.of(context).scaffoldBackgroundColor.withAlpha(230) : colorScheme.onSurface.withAlpha(30),
                                                trailing: Checkbox(
                                                  value: isSelected,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      value! ? _selectedID = member.id : _selectedID = null;
                                                    });
                                                  },
                                                ),
                                              );

                                            },
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                                            child: Center(
                                              child: Text(
                                                "No Users Found",
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
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : !isValidForm ? () {

                                  if (!_formKey.currentState!.validate()) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isPayer ? "Please select a Recipient !" : "Please select a Payer !",
                                        style: TextStyle(
                                          color: colorScheme.onError,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } : () async {

                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      icon: Icon(Icons.error, color: colorScheme.error, size: 36,),
                                      title: Text('Add Transaction ?', style: textTheme.displayMedium,),
                                      content: Text('Please confirm the details in the Transaction', style: textTheme.titleLarge,),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: textTheme.bodyLarge)),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Create', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),))
                                      ],
                                    ),
                                  );

                                  if (confirmed == true){
                                    await _handleSubmit();
                                  }

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: colorScheme.onSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                ),
                                child: _isSubmitting
                                  ? const CircularProgressIndicator()
                                  : Text(
                                    "Add Transaction",
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

        },
      ),
    );

  }

}