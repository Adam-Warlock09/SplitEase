import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/appBar.dart';
import 'package:split_ease/widgets/navigationDrawer.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final description = _descController.text.trim().isEmpty ? null : _descController.text.trim();

    final session = Provider.of<SessionProvider>(context, listen: false);
    if (!session.isLoggedIn) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      }
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final token = session.token;

    try {

      final api = ApiService();
      final responseData = await api.createGroup(name, description, token);

      if(!mounted) return;

      if (responseData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error while creating group!",
              style: TextStyle(
                color: Colors.white,
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
      }else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Group Created Successfully!",
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

        context.go("/group/${responseData.id}");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error : $e!",
              style: TextStyle(
                color: Colors.white,
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
        currentPage: "Groups",
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Create a New Group",
                    style: textTheme.displayLarge,
                  ),
                ),
                AppSpacing.verticalLg,
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelText: "Group Name",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.group),
                            filled: true,
                            fillColor: colorScheme.onSurface.withAlpha(50),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Group Name Required";
                            }
                            if (value.length > 50) {
                              return "Name too long (max 50 chars)";
                            }
                            return null;
                          },
                        ),
                        AppSpacing.verticalLg,
                        TextFormField(
                          maxLength: 125,
                          controller: _descController,
                          decoration: InputDecoration(
                            labelText: "Description (Optional)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                            filled: true,
                            fillColor: colorScheme.onSurface.withAlpha(50),
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value != null && value.length > 125) {
                              return "Description too long (max 50 chars)";
                            }
                            return null;
                          },
                        ),
                        AppSpacing.verticalLg,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: _isSubmitting
                              ? const CircularProgressIndicator()
                              : Text(
                                "Create Group",
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
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}