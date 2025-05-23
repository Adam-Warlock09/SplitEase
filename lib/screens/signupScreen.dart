import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/services/api.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/theme/appTheme.dart';
import 'package:split_ease/widgets/centeredBox.dart';
import 'package:split_ease/widgets/curvedBackground.dart';
import 'package:split_ease/widgets/fullBox.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitSignup() async {

    final colorScheme = Theme.of(context).colorScheme;

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final api = ApiService();
      final responseData = await api.signup(name, email, password);

      if (!mounted) return;

      if (responseData != null) {

        final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
        await sessionProvider.SaveSession(responseData["token"], responseData["user"]["id"], responseData["user"]["name"]);

        if (!mounted) return;

        context.go('/dashboard');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "User Already Exists!",
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

    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme(context),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              CurvedBackground(),
              CenteredBox(
                child: FullBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('images/home.png', fit: BoxFit.fitHeight),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            top: 16.0,
                            bottom: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  AutoSizeText(
                                    "SPLITEASE",
                                    style: GoogleFonts.itim(
                                      color: Color(0xFF000000),
                                      fontSize: 64,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AutoSizeText(
                                    "Join Now",
                                    style: GoogleFonts.jacquesFrancois(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF393939),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Form(
                                key: _formKey,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                  child: Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 400),
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            labelText: "Name",
                                            border: OutlineInputBorder(),
                                            prefixIcon: Icon(Icons.person),
                                          ),
                                          keyboardType: TextInputType.name,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Enter Name";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      AppSpacing.verticalSm,
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 400),
                                        child: TextFormField(
                                          controller: _emailController,
                                          decoration: const InputDecoration(
                                            labelText: "Email",
                                            border: OutlineInputBorder(),
                                            prefixIcon: Icon(Icons.email),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Enter Email";
                                            }
                                            if (!RegExp(
                                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                            ).hasMatch(value)) {
                                              return "Enter a valid Email Address";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      AppSpacing.verticalSm,
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 400),
                                         child: TextFormField(
                                          controller: _passwordController,
                                          decoration: InputDecoration(
                                            labelText: "Password",
                                            border: const OutlineInputBorder(),
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(
                                                  () =>
                                                      _obscurePassword =
                                                          !_obscurePassword,
                                                );
                                              },
                                            ),
                                          ),
                                          obscureText: _obscurePassword,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return "Enter Password";
                                            if (value != _confirmPasswordController.text) return "Passwords do not match";
                                            return null;
                                          },
                                        ),
                                      ),
                                      AppSpacing.verticalSm,
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 400,
                                        ),
                                        child: TextFormField(
                                          controller: _confirmPasswordController,
                                          decoration: InputDecoration(
                                            labelText: "Confirm Password",
                                            border: const OutlineInputBorder(),
                                            prefixIcon: const Icon(Icons.lock_outline),
                                          ),
                                          obscureText: _obscurePassword,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return "Confirm your Password";
                                            if (value != _passwordController.text) return "Passwords do not match";
                                            return null;
                                          },
                                        ),
                                      ),
                                      AppSpacing.verticalMd,
                                      ElevatedButton(
                                        onPressed: _submitSignup,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: AutoSizeText(
                                          "SIGN UP",
                                          style: GoogleFonts.montserrat(
                                            color: Color(0xFF000000).withAlpha(153),
                                            fontSize: 28,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 12,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}