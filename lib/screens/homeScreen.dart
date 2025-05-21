import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/curvedBackground.dart';
import '../widgets/centeredBox.dart';
import '../widgets/fullBox.dart';
import '../theme/appSpacing.dart';
// import '../theme/appSpacing.dart';
// import '../theme/appTextStyles.dart';
// import '../widgets/customTextField.dart';
// import '../widgets/customButton.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                                  "Bill Splitting App",
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
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context.go('/signup');
                                  },
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
                                    "SIGN UP",
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
                                AppSpacing.verticalMd,
                                ElevatedButton(
                                  onPressed: () {
                                    context.go('/login');
                                  },
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
                                    "LOGIN",
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