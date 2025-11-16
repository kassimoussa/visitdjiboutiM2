import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/utils/responsive.dart';
import '../../generated/l10n/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Utiliser la version par défaut en cas d'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerAbout),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec gradient
            _buildHeader(context, l10n),

            // Contenu principal
            Padding(
              padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _buildDescriptionCard(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Statistiques
                  _buildStatsSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Fonctionnalités
                  _buildFeaturesSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Organisation
                  _buildOrganizationSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Partenaires
                  _buildPartnersSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Technologies
                  _buildTechnologiesSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Contact
                  _buildContactSection(context, l10n),

                  SizedBox(height: ResponsiveConstants.extraLargeSpace),

                  // Copyright
                  _buildCopyrightSection(context, l10n, currentYear),

                  SizedBox(height: ResponsiveConstants.largeSpace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3860F8),
            const Color(0xFF3860F8).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveConstants.extraLargeSpace),

          // Logo de l'application
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo_visitdjibouti.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: ResponsiveConstants.largeSpace),

          // Nom de l'application
          Text(
            l10n.aboutAppName,
            style: TextStyle(
              fontSize: ResponsiveConstants.headline4,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: ResponsiveConstants.smallSpace),

          // Version
          Text(
            l10n.aboutVersion(_appVersion),
            style: TextStyle(
              fontSize: ResponsiveConstants.body1,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          SizedBox(height: ResponsiveConstants.extraLargeSpace),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3860F8).withOpacity(0.05),
            const Color(0xFF0072CE).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        border: Border.all(
          color: const Color(0xFF3860F8).withOpacity(0.1),
        ),
      ),
      child: Text(
        l10n.aboutDescription,
        style: TextStyle(
          fontSize: ResponsiveConstants.body1,
          height: 1.6,
          color: const Color(0xFF1D2233),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '50+',
            l10n.aboutStatsPois,
            Icons.place_outlined,
            const Color(0xFF3860F8),
          ),
        ),
        SizedBox(width: ResponsiveConstants.mediumSpace),
        Expanded(
          child: _buildStatCard(
            '100+',
            l10n.aboutStatsEvents,
            Icons.event_outlined,
            const Color(0xFF009639),
          ),
        ),
        SizedBox(width: ResponsiveConstants.mediumSpace),
        Expanded(
          child: _buildStatCard(
            '6',
            l10n.aboutStatsRegions,
            Icons.map_outlined,
            const Color(0xFF0072CE),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: ResponsiveConstants.smallSpace),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.headline5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveConstants.tinySpace),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveConstants.caption,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutFeaturesTitle, Icons.stars),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        _buildFeatureItem(
          Icons.explore,
          l10n.aboutFeatureDiscoverTitle,
          l10n.aboutFeatureDiscoverDesc,
          const Color(0xFF3860F8),
        ),
        _buildFeatureItem(
          Icons.event,
          l10n.aboutFeatureEventsTitle,
          l10n.aboutFeatureEventsDesc,
          const Color(0xFF009639),
        ),
        _buildFeatureItem(
          Icons.map,
          l10n.aboutFeatureMapsTitle,
          l10n.aboutFeatureMapsDesc,
          const Color(0xFF0072CE),
        ),
        _buildFeatureItem(
          Icons.favorite,
          l10n.aboutFeatureFavoritesTitle,
          l10n.aboutFeatureFavoritesDesc,
          const Color(0xFFE8356D),
        ),
        _buildFeatureItem(
          Icons.offline_pin,
          l10n.aboutFeatureOfflineTitle,
          l10n.aboutFeatureOfflineDesc,
          const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3860F8), size: 24),
        SizedBox(width: ResponsiveConstants.smallSpace),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveConstants.headline6,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2233),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: ResponsiveConstants.mediumSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D2233),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.tinySpace),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body2,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutDevelopedByTitle, Icons.business),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.05),
            borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
            border: Border.all(
              color: const Color(0xFF3860F8).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'ANT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.mediumSpace),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutOrganization,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.subtitle1,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2233),
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.tinySpace),
                    Text(
                      l10n.aboutOrganizationDescription,
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
        ),
      ],
    );
  }

  Widget _buildPartnersSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutPartnersTitle, Icons.handshake),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        _buildPartnerItem(
          Icons.account_balance,
          l10n.aboutPartnerMinistry,
          l10n.aboutPartnerMinistryDesc,
          const Color(0xFF3860F8),
        ),
        SizedBox(height: ResponsiveConstants.smallSpace),
        _buildPartnerItem(
          Icons.hotel,
          l10n.aboutPartnerHotels,
          l10n.aboutPartnerHotelsDesc,
          const Color(0xFF009639),
        ),
      ],
    );
  }

  Widget _buildPartnerItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    color: const Color(0xFF1D2233),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.tinySpace),
                Text(
                  subtitle,
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

  Widget _buildTechnologiesSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutTechnologiesTitle, Icons.code),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTechChip('Flutter', l10n.aboutTechFlutter, const Color(0xFF02569B)),
            _buildTechChip('Dart', l10n.aboutTechDart, const Color(0xFF0175C2)),
            _buildTechChip('Laravel', l10n.aboutTechLaravel, const Color(0xFFFF2D20)),
            _buildTechChip('Google Maps', l10n.aboutTechMaps, const Color(0xFF4285F4)),
          ],
        ),
      ],
    );
  }

  Widget _buildTechChip(String name, String description, Color color) {
    return Tooltip(
      message: description,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.smallSpace,
          vertical: ResponsiveConstants.tinySpace,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 8),
            SizedBox(width: ResponsiveConstants.tinySpace),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: ResponsiveConstants.body2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.aboutContactTitle, Icons.contact_mail),
        SizedBox(height: ResponsiveConstants.mediumSpace),
        _buildContactItem(
          Icons.language,
          l10n.aboutContactWebsite,
          'www.office-tourisme.dj',
          () => _showSnackBar(context, l10n.aboutOpeningWebsite),
        ),
        _buildContactItem(
          Icons.email_outlined,
          l10n.aboutContactEmail,
          'info@office-tourisme.dj',
          () => _showSnackBar(context, l10n.aboutOpeningEmail),
        ),
        _buildContactItem(
          Icons.phone_outlined,
          l10n.aboutContactPhone,
          '+253 21 35 68 00',
          () => _showSnackBar(context, l10n.aboutOpeningPhone),
        ),
        _buildContactItem(
          Icons.location_on_outlined,
          l10n.aboutContactAddress,
          l10n.aboutContactAddressValue,
          () => _showSnackBar(context, l10n.aboutOpeningMap),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.smallSpace),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3860F8), size: 24),
            SizedBox(width: ResponsiveConstants.mediumSpace),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.body2,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.tinySpace / 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.body1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D2233),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyrightSection(
    BuildContext context,
    AppLocalizations l10n,
    String year,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.largeSpace),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons.copyright,
            color: Colors.grey[600],
            size: 20,
          ),
          SizedBox(height: ResponsiveConstants.smallSpace),
          Text(
            l10n.aboutCopyright(year),
            style: TextStyle(
              fontSize: ResponsiveConstants.body1,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.smallSpace),
          Text(
            l10n.aboutCopyrightDescription,
            style: TextStyle(
              fontSize: ResponsiveConstants.body2,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF3860F8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
        ),
      ),
    );
  }
}
