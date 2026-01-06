import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/anonymous_auth_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../main_navigation_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthDecisionPage extends StatelessWidget {
  const AuthDecisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: Responsive.all(24),
            child: Column(
              children: [
                SizedBox(height: 40.h),

                // Logo
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3860F8).withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: Responsive.all(20),
                  child: Image.asset(
                    'assets/images/logo_visitdjibouti.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.travel_explore,
                      color: const Color(0xFF3860F8),
                      size: 60.w,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Title
                // Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.authWelcomeToApp,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2233),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16.h),

                // Subtitle
                Text(
                  AppLocalizations.of(context)!.authWelcomeSubtitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 60.h),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.authRegister,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3860F8),
                      side: const BorderSide(
                        color: Color(0xFF3860F8),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.authLogin,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Guest Button
                // Guest Button
                TextButton(
                  onPressed: () async {
                    await AnonymousAuthService().setGuestModeConfirmed();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationPage(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.authContinueGuest,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
