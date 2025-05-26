// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/models/expense.dart';
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/user.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/subNavigationDrawer.dart';

enum SplitType { even, ratio, uneven }

class CreateExpensePage extends StatefulWidget {
  final String groupID;
  const CreateExpensePage({super.key, required this.groupID});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {

  late Future<GroupDetailed?> _groupFuture;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;

  SplitType _splitType = SplitType.even;
  Set<String> _selectedMembers = {};
  Map<String, double> _ratios = {};
  Map<String, double> _unevenAmounts = {};
  Map<String, double> _splits = {};

  double _calculatedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _groupFuture = _fetchGroup();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _amountController.dispose();
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

  bool get isValidForm {
    return _selectedMembers.isNotEmpty;
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

    final amount = double.parse(double.parse(_amountController.text).toStringAsFixed(2));
    _splits.removeWhere((key, value) => value <= 0);
    final String splitType = _splitType.name;
    final colorScheme = Theme.of(context).colorScheme;

    final Expense newExpense = Expense(
      groupID: widget.groupID,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim() == "" ? null : _notesController.text.trim(),
      amount: amount,
      createdAt: DateTime.now(),
      splits: _splits,
      splitType: splitType,
      paidBy: session.userID!,
    );

    try {

      final api = ApiService();
      final responseData = await api.createExpense(newExpense, widget.groupID, session.token);

      if(!mounted) return;

      if (responseData == null) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error while creating expense!",
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
              "Expense Created Successfully!",
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

        context.go("/group/${widget.groupID}/expenses");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error : $e!",
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MyAppBar(
        currentPage: "Create New Expense",
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
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                                controller: _titleController,
                                maxLength: 50,
                                decoration: InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.title),
                                  filled: true,
                                  fillColor: colorScheme.onSurface.withAlpha(50),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Expense Title Required";
                                  }
                                  if (value.length > 50) {
                                    return "Title too long (Max 50 chars).";
                                  }
                                  return null;
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
                                  "Split Type : ",
                                  style: textTheme.displayMedium,
                                ),
                                ChoiceChip(
                                  label: Text(
                                    "Even Split",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: _splitType == SplitType.even ? FontWeight.w700 : FontWeight.w500,
                                      color: _splitType == SplitType.even ? colorScheme.onSecondary : colorScheme.onSurface,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface.withAlpha(50),
                                  selectedColor: isDarkMode ? colorScheme.secondary.withAlpha(200) : colorScheme.primary.withAlpha(150),
                                  selected: _splitType == SplitType.even,
                                  pressElevation: 3,
                                  shape: StadiumBorder(
                                    side: _splitType != SplitType.even
                                    ? BorderSide(
                                      color: !isDarkMode ? colorScheme.secondary : colorScheme.primary,
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
                                      _splitType = SplitType.even;
                                      _ratios.clear();
                                      _selectedMembers.clear();
                                      _unevenAmounts.clear();
                                      _splits.clear();
                                      _calculatedAmount = 0.0;
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: Text(
                                    "Ratio Split",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: _splitType == SplitType.ratio ? FontWeight.w700 : FontWeight.w500,
                                      color: _splitType == SplitType.ratio ? colorScheme.onSecondary : colorScheme.onSurface,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface.withAlpha(50),
                                  selectedColor: isDarkMode ? colorScheme.secondary.withAlpha(200) : colorScheme.primary.withAlpha(150),
                                  selected: _splitType == SplitType.ratio,
                                  pressElevation: 3,
                                  shape: StadiumBorder(
                                    side: _splitType != SplitType.ratio
                                    ? BorderSide(
                                      color: !isDarkMode ? colorScheme.secondary : colorScheme.primary,
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
                                      _splitType = SplitType.ratio;
                                      _ratios.clear();
                                      _selectedMembers.clear();
                                      _unevenAmounts.clear();
                                      _splits.clear();
                                      _calculatedAmount = 0.0;
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: Text(
                                    "Uneven Split",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: _splitType == SplitType.uneven ? FontWeight.w700 : FontWeight.w500,
                                      color: _splitType == SplitType.uneven ? colorScheme.onSecondary : colorScheme.onSurface,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.onSurface.withAlpha(50),
                                  selectedColor: isDarkMode ? colorScheme.secondary.withAlpha(200) : colorScheme.primary.withAlpha(150),
                                  selected: _splitType == SplitType.uneven,
                                  pressElevation: 3,
                                  shape: StadiumBorder(
                                    side: _splitType != SplitType.uneven
                                    ? BorderSide(
                                      color: !isDarkMode ? colorScheme.secondary : colorScheme.primary,
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
                                      _splitType = SplitType.uneven;
                                      _ratios.clear();
                                      _selectedMembers.clear();
                                      _unevenAmounts.clear();
                                      _splits.clear();
                                      _calculatedAmount = 0.0;
                                      _amountController.text = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            AppSpacing.verticalLg,
                            AppSpacing.verticalLg,
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: TextFormField(
                                controller: _amountController,
                                enabled: _splitType != SplitType.uneven,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
                                ],
                                
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  hintText: '0.00',
                                  suffixText:
                                      _splitType == SplitType.uneven
                                          ? 'Auto: ₹${_calculatedAmount.toStringAsFixed(2)}'
                                          : null,
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.currency_rupee),
                                  filled: true,
                                  fillColor: colorScheme.onSurface.withAlpha(50),
                                ),
                                validator: (value) {
                                  if (_splitType == SplitType.uneven) return null;
                                  if (value == null || value.isEmpty) {
                                    return 'Enter amount';
                                  }
                                  try {
                                    double.parse(value);
                                    if (value.startsWith('.') && value.length == 1) return 'Invalid number';
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
                                onChanged: (value) {
                              
                                  double amount = double.parse((double.tryParse(value) ?? 0).toStringAsFixed(2));
                              
                                  if (_splitType == SplitType.even) {
                                    if (_selectedMembers.isNotEmpty) {
                                      double splitAmount = amount / _selectedMembers.length;
                                      Map<String, double> splits = {};
                                      for (final id in _selectedMembers) {
                                        splits[id] = double.parse(splitAmount.toStringAsFixed(2));
                                      }
                                      setState(() {
                                        _splits = splits;
                                      });
                                    }
                                  } else if(_splitType == SplitType.ratio) {
                                    if (_selectedMembers.isNotEmpty) {
                                      final Map<String, double> splits = {};
                                      double sum = _ratios.values.fold(0.0, (sum, value) => sum + value);
                                      double splitAmount;
                                      for (final id in _selectedMembers) {
                                        splitAmount = (amount * _ratios[id]!) / sum;
                                        splits[id] = double.parse(splitAmount.toStringAsFixed(2));
                                      }
                                      setState(() {
                                        _splits = splits;
                                      });
                                    }
                                  }
                                  
                                },
                              ),
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
                                            _splitType == SplitType.even
                                              ? TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: colorScheme.secondary.withAlpha(230),
                                                  animationDuration: Duration(milliseconds: 300),
                                                  elevation: 2,
                                                ),
                                                onPressed: () {
                                                  double amount = double.parse((double.tryParse(_amountController.text) ?? 0).toStringAsFixed(2));
                                                  double splitAmount = amount / group.members.length;
                                                  double splitAmountParsed = double.parse(splitAmount.toStringAsFixed(2));
                                                  setState(() {
                                                    _selectedMembers.addAll(group.members.map((member) => member.id));
                                                    _splits = Map.fromEntries(
                                                      group.members.map((member) => MapEntry(member.id, splitAmountParsed))
                                                    );
                                                  });
                                                },
                                                child: Text(
                                                  "Select All",
                                                  style: textTheme.titleLarge?.copyWith(
                                                    color: colorScheme.onSecondary,
                                                  ),
                                                ),
                                              )
                                              : SizedBox.shrink(),
                                          ],
                                        ),
                                        AppSpacing.verticalMd,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32.0,
                                          ),
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: group.members.length,
                                            separatorBuilder: (context, index) => AppSpacing.verticalMd,
                                            itemBuilder: (context, index) {
                                          
                                              final User member = group.members[index];
                                              final isYou = session.userID == member.id;
                                              final isSelected = _selectedMembers.contains(member.id);
                                              
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
                                                  isYou ? '${member.name} (You)' : member.name
                                                ),
                                                subtitle: Text(member.email),
                                                tileColor: isSelected ? colorScheme.inversePrimary.withAlpha(150) : isDarkMode ? Theme.of(context).scaffoldBackgroundColor.withAlpha(230) : colorScheme.onSurface.withAlpha(30),
                                                trailing: switch (_splitType) {
                                                  SplitType.even => Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Checkbox(
                                                        value: isSelected,
                                                        onChanged: (value) {
                                                          double amount = double.parse((double.tryParse(_amountController.text) ?? 0).toStringAsFixed(2));
                                                          setState(() {
                                                            value! ? _selectedMembers.add(member.id) : _selectedMembers.remove(member.id);
                                                            _splits = Map.fromEntries(
                                                              _selectedMembers.map((selectedMember) => MapEntry(selectedMember, double.parse((amount / _selectedMembers.length).toStringAsFixed(2))))
                                                            );
                                                          });
                                                        },
                                                      ),
                                                      AppSpacing.horizontalMd,
                                                      Text(
                                                        '₹${(_splits[member.id] ?? 0).toStringAsFixed(2)}',
                                                        style: textTheme.displayLarge?.copyWith(
                                                          fontWeight: FontWeight.w500,
                                                          color: colorScheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SplitType.ratio => Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 120),
                                                        child: TextFormField(
                                                          initialValue: (_ratios[member.id] ?? 0) > 0 ? (_ratios[member.id] ?? 0).toString() : '',
                                                          decoration: InputDecoration(
                                                            labelText: "Ratio",
                                                            hintText: "0",
                                                            border: OutlineInputBorder(),
                                                            prefixIcon: Icon(Icons.numbers),
                                                            filled: true,
                                                            fillColor: colorScheme.onSurface.withAlpha(50)
                                                          ),
                                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                          keyboardType: TextInputType.number,
                                                          validator: (value) {
                                                            if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                                                              return "Ratio has to be an integer";
                                                            }
                                                            if (value != null && value.isNotEmpty && (int.tryParse(value)! < 0)) {
                                                              return "Ratio can't be negative";
                                                            }
                                                            return null;
                                                          },
                                                          onChanged: (value) {
                                                            if (value.isEmpty) {
                                                              value = '0';
                                                            }
                                                            if (int.tryParse(value) == null) {
                                                              value = "0";
                                                            }
                                                            double ratioValue = double.tryParse(value) ?? 0;
                                                            if (ratioValue < 0) ratioValue = 0;
                                                            double amount = double.parse((double.tryParse(_amountController.text) ?? 0).toStringAsFixed(2));
                                                            double sum = _ratios.values.fold(0.0, (sum, value) => sum + value) + ratioValue - (_ratios[member.id] ?? 0);
                                                            setState(() {
                                                              _ratios[member.id] = ratioValue;
                                                              if (ratioValue == 0 && _selectedMembers.contains(member.id)){
                                                                _selectedMembers.remove(member.id);
                                                              }
                                                              if (ratioValue > 0 && !_selectedMembers.contains(member.id)){
                                                                _selectedMembers.add(member.id);
                                                              }
                                                              _splits = Map.fromEntries(
                                                                _selectedMembers.map((id) => MapEntry(
                                                                  id,
                                                                  double.parse(((amount * (_ratios[id] ?? 0)) / sum).toStringAsFixed(2))
                                                                ))
                                                              );
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      AppSpacing.horizontalMd,
                                                      Text(
                                                        '₹${(_splits[member.id] ?? 0).toStringAsFixed(2)}',
                                                        style: textTheme.displayLarge?.copyWith(
                                                          fontWeight: FontWeight.w500,
                                                          color: colorScheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SplitType.uneven => Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 150),
                                                        child: TextFormField(
                                                          initialValue: (_unevenAmounts[member.id] ?? 0) > 0 ? (_unevenAmounts[member.id] ?? 0).toString() : '',
                                                          decoration: InputDecoration(
                                                            labelText: "Amount",
                                                            hintText: '0.00',
                                                            border: OutlineInputBorder(),
                                                            prefixIcon: Icon(Icons.currency_rupee),
                                                            filled: true,
                                                            fillColor: colorScheme.onSurface.withAlpha(50)
                                                          ),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
                                                          ],
                                                          keyboardType: TextInputType.number,
                                                          validator: (value) {
                                                            if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                                              return "Amount has to be an integer";
                                                            }
                                                            if (value != null && value.isNotEmpty && (double.tryParse(value)! < 0)) {
                                                              return "Amount can't be negative";
                                                            }
                                                            return null;
                                                          },
                                                          onChanged: (value) {
                                                            if (value.isEmpty) {
                                                              value = '0.00';
                                                            }
                                                            double amountValue = double.tryParse(value) ?? 0;
                                                            if (amountValue < 0) amountValue = 0;
                                                            setState(() {
                                                              _unevenAmounts[member.id] = double.parse(amountValue.toStringAsFixed(2));
                                                              if (amountValue == 0 && _selectedMembers.contains(member.id)){
                                                                _selectedMembers.remove(member.id);
                                                              }
                                                              if (amountValue > 0 && !_selectedMembers.contains(member.id)){
                                                                _selectedMembers.add(member.id);
                                                              }
                                                              _splits = Map.fromEntries(
                                                                _selectedMembers.map((id) => MapEntry(
                                                                  id,
                                                                  (_unevenAmounts[id] ?? 0),
                                                                ))
                                                              );
                                                              _calculatedAmount = double.parse(_unevenAmounts.values.fold(0.0, (sum, value) => sum + value).toStringAsFixed(2));
                                                              _amountController.text = _calculatedAmount.toStringAsFixed(2);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      AppSpacing.horizontalMd,
                                                      Text(
                                                        '₹${(_splits[member.id] ?? 0).toStringAsFixed(2)}',
                                                        style: textTheme.displayLarge?.copyWith(
                                                          fontWeight: FontWeight.w500,
                                                          color: colorScheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                },
                                              );
                                          
                                            },
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
                                        "No users added to split!",
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
                                      title: Text('Create Expense ?', style: textTheme.displayMedium,),
                                      content: Text('Please confirm the details in the Expense', style: textTheme.titleLarge,),
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
                                    "Create Expense",
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