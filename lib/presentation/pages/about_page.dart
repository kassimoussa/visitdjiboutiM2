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
      ),
      body: SingleChildScrollView(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Logo et titre
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Color(0xFF3860F8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Center(
                child: Text(
                  '🇩🇯',
                  style: TextStyle(fontSize: 60.sp),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
            
            Text(
              AppLocalizations.of(context)!.aboutAppName,
              style: TextStyle(
                fontSize: ResponsiveConstants.headline5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3860F8),
              ),
            ),

            SizedBox(height: ResponsiveConstants.smallSpace),

            Text(
              AppLocalizations.of(context)!.aboutVersion('1.0.0'),
              style: TextStyle(
                fontSize: ResponsiveConstants.body1,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Description
            Container(
              padding: Responsive.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                AppLocalizations.of(context)!.aboutDescription,
                style: TextStyle(
                  fontSize: ResponsiveConstants.body1,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    '50+',
                    AppLocalizations.of(context)!.aboutStatsPois,
                    Icons.place,
                    const Color(0xFF3860F8),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smallSpace),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '100+',
                    AppLocalizations.of(context)!.aboutStatsEvents,
                    Icons.event,
                    const Color(0xFF009639),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.smallSpace),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '6',
                    AppLocalizations.of(context)!.aboutStatsRegions,
                    Icons.map,
                    const Color(0xFF0072CE),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Fonctionnalités
            _buildSection(
              AppLocalizations.of(context)!.aboutFeaturesTitle,
              [
                _buildFeatureItem(
                  Icons.explore,
                  AppLocalizations.of(context)!.aboutFeatureDiscoverTitle,
                  AppLocalizations.of(context)!.aboutFeatureDiscoverDesc,
                ),
                _buildFeatureItem(
                  Icons.event,
                  AppLocalizations.of(context)!.aboutFeatureEventsTitle,
                  AppLocalizations.of(context)!.aboutFeatureEventsDesc,
                ),
                _buildFeatureItem(
                  Icons.map,
                  AppLocalizations.of(context)!.aboutFeatureMapsTitle,
                  AppLocalizations.of(context)!.aboutFeatureMapsDesc,
                ),
                _buildFeatureItem(
                  Icons.favorite,
                  AppLocalizations.of(context)!.aboutFeatureFavoritesTitle,
                  AppLocalizations.of(context)!.aboutFeatureFavoritesDesc,
                ),
                _buildFeatureItem(
                  Icons.offline_pin,
                  AppLocalizations.of(context)!.aboutFeatureOfflineTitle,
                  AppLocalizations.of(context)!.aboutFeatureOfflineDesc,
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Équipe
            _buildSection(
              AppLocalizations.of(context)!.aboutDevelopedByTitle,
              [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF3860F8),
                    child: Text('ANT', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(AppLocalizations.of(context)!.aboutOrganizationFull),
                  subtitle: Text(AppLocalizations.of(context)!.aboutOrganizationDescription),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
            
            // Partenaires
            _buildSection(
              AppLocalizations.of(context)!.aboutPartnersTitle,
              [
                ListTile(
                  leading: const Icon(Icons.business, color: Color(0xFF3860F8)),
                  title: Text(AppLocalizations.of(context)!.aboutPartnerMinistry),
                  subtitle: Text(AppLocalizations.of(context)!.aboutPartnerMinistryDesc),
                ),
                ListTile(
                  leading: const Icon(Icons.hotel, color: Color(0xFF009639)),
                  title: Text(AppLocalizations.of(context)!.aboutPartnerHotels),
                  subtitle: Text(AppLocalizations.of(context)!.aboutPartnerHotelsDesc),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Technologies utilisées
            _buildSection(
              AppLocalizations.of(context)!.aboutTechnologiesTitle,
              [
                _buildTechItem('Flutter', AppLocalizations.of(context)!.aboutTechFlutter),
                _buildTechItem('Dart', AppLocalizations.of(context)!.aboutTechDart),
                _buildTechItem('Laravel', AppLocalizations.of(context)!.aboutTechLaravel),
                _buildTechItem('Google Maps', AppLocalizations.of(context)!.aboutTechMaps),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Contact et liens
            _buildSection(
              AppLocalizations.of(context)!.aboutContactTitle,
              [
                _buildContactItem(
                  context,
                  Icons.web,
                  AppLocalizations.of(context)!.aboutContactWebsite,
                  'www.office-tourisme.dj',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.aboutOpeningWebsite),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  context,
                  Icons.email,
                  AppLocalizations.of(context)!.aboutContactEmail,
                  'info@office-tourisme.dj',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.aboutOpeningEmail),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  context,
                  Icons.phone,
                  AppLocalizations.of(context)!.aboutContactPhone,
                  '+253 21 35 68 00',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.aboutOpeningPhone),
                      ),
                    );
                  },
                ),
                _buildContactItem(
                  context,
                  Icons.location_on,
                  AppLocalizations.of(context)!.aboutContactAddress,
                  AppLocalizations.of(context)!.aboutContactAddressValue,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.aboutOpeningMap),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.extraLargeSpace),
            
            // Copyright
            Container(
              padding: Responsive.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.aboutCopyright('2024'),
                    style: TextStyle(
                      fontSize: ResponsiveConstants.body2,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  Text(
                    AppLocalizations.of(context)!.aboutCopyrightDescription,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.caption,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveConstants.largeSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: ResponsiveConstants.smallSpace),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.subtitle1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveConstants.subtitle1,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3860F8),
          ),
        ),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: Responsive.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: Responsive.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3860F8),
              size: 20,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mediumSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.tinySpace),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body2,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String tech, String description) {
    return Padding(
      padding: Responsive.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              tech,
              style: TextStyle(
                color: Color(0xFF009639),
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smallSpace),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3860F8)),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.launch, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}