import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerAbout),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: Responsive.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Center(
                  child: Text('🇩🇯', style: TextStyle(fontSize: 60.sp)),
                ),
              ),

              SizedBox(height: ResponsiveConstants.largeSpace),

              // App Name
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: TextStyle(
                  fontSize: ResponsiveConstants.headline5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3860F8),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: ResponsiveConstants.smallSpace),

              // Version
              Text(
                AppLocalizations.of(context)!.aboutVersion('1.0.0'),
                style: TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: ResponsiveConstants.extraLargeSpace),

              // Description
              Container(
                padding: Responsive.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  AppLocalizations.of(context)!.aboutDescription,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    height: 1.5,
                    color: const Color(0xFF1D2233),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: ResponsiveConstants.extraLargeSpace),

              // Copyright
              Text(
                AppLocalizations.of(
                  context,
                )!.aboutCopyright(DateTime.now().year.toString()),
                style: TextStyle(
                  fontSize: ResponsiveConstants.body2,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
