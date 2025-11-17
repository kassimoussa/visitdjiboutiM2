import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/essentials_service.dart';
import '../../core/models/embassy.dart';
import '../../core/models/api_response.dart';
import '../../generated/l10n/app_localizations.dart';

class EmbassiesPage extends StatefulWidget {
  const EmbassiesPage({super.key});

  @override
  State<EmbassiesPage> createState() => _EmbassiesPageState();
}

class _EmbassiesPageState extends State<EmbassiesPage> with SingleTickerProviderStateMixin {
  final EssentialsService _essentialsService = EssentialsService();
  late TabController _tabController;
  
  List<Embassy> _foreignEmbassies = [];
  List<Embassy> _djiboutianEmbassies = [];
  
  bool _isLoadingForeign = true;
  bool _isLoadingDjibouti = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEmbassies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmbassies() async {
    await Future.wait([
      _loadForeignEmbassies(),
      _loadDjiboutianEmbassies(),
    ]);
  }

  Future<void> _loadForeignEmbassies() async {
    setState(() {
      _isLoadingForeign = true;
      _errorMessage = null;
    });

    try {
      final ApiResponse<List<Embassy>> response = 
          await _essentialsService.getEmbassies(type: 'foreign_in_djibouti');
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _foreignEmbassies = response.data!;
            _isLoadingForeign = false;
          });
        } else {
          setState(() {
            _isLoadingForeign = false;
            _errorMessage = response.message ?? 'Erreur lors du chargement des ambassades';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingForeign = false;
          _errorMessage = 'Erreur inattendue: $e';
        });
      }
    }
  }

  Future<void> _loadDjiboutianEmbassies() async {
    setState(() {
      _isLoadingDjibouti = true;
    });

    try {
      final ApiResponse<List<Embassy>> response = 
          await _essentialsService.getEmbassies(type: 'djiboutian_abroad');
      
      if (mounted) {
        setState(() {
          if (response.isSuccess && response.data != null) {
            _djiboutianEmbassies = response.data!;
          }
          _isLoadingDjibouti = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDjibouti = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.embassiesTitle),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.flag),
              text: 'À Djibouti (${_foreignEmbassies.length})',
            ),
            Tab(
              icon: const Icon(Icons.public),
              text: 'À l\'étranger (${_djiboutianEmbassies.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmbassyList(
            embassies: _foreignEmbassies,
            isLoading: _isLoadingForeign,
            emptyMessage: AppLocalizations.of(context)!.embassiesNoForeignFound,
            emptySubtitle: AppLocalizations.of(context)!.embassiesNoForeignSubtitle,
          ),
          _buildEmbassyList(
            embassies: _djiboutianEmbassies,
            isLoading: _isLoadingDjibouti,
            emptyMessage: AppLocalizations.of(context)!.embassiesNoDjiboutianFound,
            emptySubtitle: AppLocalizations.of(context)!.embassiesNoDjiboutianSubtitle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadEmbassies,
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmbassyList({
    required List<Embassy> embassies,
    required bool isLoading,
    required String emptyMessage,
    required String emptySubtitle,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3860F8)),
      );
    }

    if (_errorMessage != null && embassies.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _loadEmbassies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (embassies.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: Responsive.all(16),
      itemCount: embassies.length,
      itemBuilder: (context, index) {
        final embassy = embassies[index];
        return _buildEmbassyCard(embassy);
      },
    );
  }

  Widget _buildEmbassyCard(Embassy embassy) {
    return Card(
      margin: Responsive.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ExpansionTile(
        tilePadding: Responsive.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: _buildCountryFlag(embassy.countryCode),
        title: Text(
          embassy.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (embassy.ambassadorName != null)
              Padding(
                padding: Responsive.only(top: 4),
                child: Text(
                  embassy.ambassadorName!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (embassy.address != null)
              Padding(
                padding: Responsive.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        embassy.address!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        children: [
          _buildEmbassyDetails(embassy),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(String countryCode) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3860F8).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          countryCode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmbassyDetails(Embassy embassy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (embassy.address != null) ...[
          _buildDetailRow(Icons.location_on, 'Adresse complète', embassy.address!),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.postalBox != null) ...[
          _buildDetailRow(Icons.markunread_mailbox, 'Boîte Postale', embassy.postalBox!),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.primaryPhone.isNotEmpty) ...[
          _buildDetailRow(Icons.phone, 'Téléphone', embassy.primaryPhone),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.phones.length > 1) ...[
          _buildDetailRow(Icons.phone_in_talk, 'Autres téléphones', embassy.phones.skip(1).join(', ')),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.fax != null) ...[
          _buildDetailRow(Icons.fax, 'Fax', embassy.fax!),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.primaryEmail.isNotEmpty) ...[
          _buildDetailRow(Icons.email, AppLocalizations.of(context)!.embassiesEmail, embassy.primaryEmail),
          SizedBox(height: 12.h),
        ],
        
        if (embassy.website != null) ...[
          _buildDetailRow(Icons.language, AppLocalizations.of(context)!.embassiesWebsite, embassy.website!),
          SizedBox(height: 16.h),
        ],
        
        // Boutons d'action
        Row(
          children: [
            if (embassy.primaryPhone.isNotEmpty)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchPhone(embassy.primaryPhone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text(AppLocalizations.of(context)!.embassiesCall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            if (embassy.primaryPhone.isNotEmpty && 
                (embassy.primaryEmail.isNotEmpty || embassy.website != null))
              SizedBox(width: 8.w),
            
            if (embassy.primaryEmail.isNotEmpty)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchEmail(embassy.primaryEmail),
                  icon: const Icon(Icons.email, size: 18),
                  label: Text(AppLocalizations.of(context)!.embassiesEmail),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3860F8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            if (embassy.primaryEmail.isNotEmpty && embassy.website != null)
              SizedBox(width: 8.w),
            
            if (embassy.website != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchWebsite(embassy.website!),
                  icon: const Icon(Icons.language, size: 18),
                  label: Text(AppLocalizations.of(context)!.embassiesWebsite),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3860F8),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: Responsive.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF3860F8),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
}