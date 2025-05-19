import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/theme/appSpacing.dart';
import 'package:split_ease/widgets/centeredBox.dart';
import 'package:split_ease/widgets/curvedBackground.dart';
import 'package:split_ease/widgets/fullBox.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      print("Logging in with $email and $password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          top: 48.0,
                          bottom: 48.0,
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
                                    textStyle:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayLarge,
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AutoSizeText(
                                  "Welcome Back",
                                  style: GoogleFonts.jacquesFrancois(
                                    textStyle:
                                        Theme.of(context).textTheme.labelSmall,
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
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: "Email",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.email),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
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
                                    AppSpacing.verticalMd,
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
                                              setState(() => _obscurePassword = !_obscurePassword);
                                            },
                                          ),
                                        ),
                                        obscureText: _obscurePassword,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return "Enter Password";
                                          return null;
                                        },
                                      ),
                                    ),
                                    AppSpacing.verticalLg,
                                    ElevatedButton(
                                      onPressed: _submitLogin,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: AutoSizeText(
                                        "LOG IN",
                                        style: GoogleFonts.montserrat(
                                          textStyle:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          // color: Color(0xFF393939),
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
    );
  }
}
