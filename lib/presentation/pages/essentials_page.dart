import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/essentials_service.dart';
import '../../core/models/organization.dart';
import '../../core/models/external_link.dart';
import '../../core/models/api_response.dart';
import '../../generated/l10n/app_localizations.dart';

class EssentialsPage extends StatefulWidget {
  const EssentialsPage({super.key});

  @override
  State<EssentialsPage> createState() => _EssentialsPageState();
}

class _EssentialsPageState extends State<EssentialsPage> with SingleTickerProviderStateMixin {
  final EssentialsService _essentialsService = EssentialsService();
  late TabController _tabController;
  
  Organization? _organization;
  List<ExternalLink> _externalLinks = [];
  
  bool _isLoadingOrg = true;
  bool _isLoadingLinks = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEssentialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEssentialData() async {
    await Future.wait([
      _loadOrganization(),
      _loadExternalLinks(),
    ]);
  }

  Future<void> _loadOrganization() async {
    try {
      final ApiResponse<Organization> response = await _essentialsService.getOrganization();
      if (mounted && response.isSuccess && response.data != null) {
        setState(() {
          _organization = response.data;
          _isLoadingOrg = false;
        });
      } else {
        setState(() => _isLoadingOrg = false);
      }
    } catch (e) {
      setState(() => _isLoadingOrg = false);
    }
  }

  Future<void> _loadExternalLinks() async {
    try {
      final ApiResponse<List<ExternalLink>> response = await _essentialsService.getExternalLinks();
      if (mounted && response.isSuccess && response.data != null) {
        setState(() {
          _externalLinks = response.data!;
          _isLoadingLinks = false;
        });
      } else {
        setState(() => _isLoadingLinks = false);
      }
    } catch (e) {
      setState(() => _isLoadingLinks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.essentialsTitle),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Organisation'),
            Tab(icon: Icon(Icons.link), text: 'Liens Utiles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrganizationTab(),
          _buildExternalLinksTab(),
        ],
      ),
    );
  }


  Widget _buildOrganizationTab() {
    if (_isLoadingOrg) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)));
    }

    if (_organization == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(AppLocalizations.of(context)!.essentialsUnavailableInfo, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: Responsive.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: Responsive.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _organization!.name,
                style: const TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                _organization!.description,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
              ),
              const Divider(height: 32.h),
              _buildContactItem(Icons.location_on, 'Adresse', _organization!.address),
              _buildContactItem(Icons.phone, 'Téléphone', _organization!.phone),
              _buildContactItem(Icons.email, AppLocalizations.of(context)!.embassiesEmail, _organization!.email),
              _buildContactItem(Icons.schedule, 'Horaires', _organization!.openingHours),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchPhone(_organization!.phone),
                      icon: const Icon(Icons.phone),
                      label: Text(AppLocalizations.of(context)!.embassiesCall),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8), 
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchEmail(_organization!.email),
                      icon: const Icon(Icons.email),
                      label: Text(AppLocalizations.of(context)!.embassiesEmail),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3860F8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExternalLinksTab() {
    if (_isLoadingLinks) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3860F8)));
    }

    if (_externalLinks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(AppLocalizations.of(context)!.essentialsNoLinksAvailable, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: Responsive.all(16),
      itemCount: _externalLinks.length,
      itemBuilder: (context, index) {
        final link = _externalLinks[index];
        return Card(
          margin: Responsive.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPlatformColor(link.color),
              child: Icon(_getPlatformIcon(link.platform), color: Colors.white),
            ),
            title: Text(link.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${link.platform.toUpperCase()} • ${link.domain}'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchWebsite(link.url),
          ),
        );
      },
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3860F8)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.sp, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.embassiesCannotOpenPhone)),
        );
      }
    }
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.embassiesCannotOpenEmail)),
        );
      }
    }
  }

  void _launchWebsite(String website) async {
    final uri = Uri.parse(website);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.embassiesCannotOpenWebsite)),
        );
      }
    }
  }

  Color _getPlatformColor(String color) {
    switch (color.toLowerCase()) {
      case 'primary':
        return const Color(0xFF3860F8);
      case 'danger':
        return const Color(0xFFDC3545);
      case 'info':
        return const Color(0xFF17A2B8);
      case 'success':
        return const Color(0xFF28A745);
      case 'warning':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF3860F8);
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_filled;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'website':
      default:
        return Icons.language;
    }
  }
}