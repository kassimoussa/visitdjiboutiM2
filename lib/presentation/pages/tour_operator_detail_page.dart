import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour_operator.dart';

class TourOperatorDetailPage extends StatelessWidget {
  final TourOperator operator;

  const TourOperatorDetailPage({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                if (operator.description != null && operator.description!.isNotEmpty)
                  _buildDescriptionSection(),
                _buildContactSection(),
                _buildActionButtons(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF3860F8),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          operator.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3860F8),
                Color(0xFF5B7BFF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Icon(
                  Icons.business_center,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              if (operator.featured == true)
                const Positioned(
                  top: 60,
                  right: 16,
                  child: Chip(
                    label: Text(
                      'Recommandé',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Color(0xFF009639),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3860F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tour,
                  color: Color(0xFF3860F8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operator.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2233),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Opérateur Touristique',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (operator.address != null && operator.address!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Adresse', operator.address!),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            operator.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: Color(0xFF3860F8),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2233),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (operator.hasPhone)
            _buildInfoRow(Icons.phone, 'Téléphone', operator.displayPhone),
          if (operator.hasEmail) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', operator.displayEmail),
          ],
          if (operator.hasWebsite) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.language, 'Site web', operator.displayWebsite, isLink: true),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (operator.hasPhone) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(operator.displayPhone),
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Appeler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3860F8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (operator.hasEmail || operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (operator.hasEmail) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendEmail(operator.displayEmail),
                icon: const Icon(Icons.email, size: 18),
                label: const Text('Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3860F8),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (operator.hasWebsite) const SizedBox(width: 12),
          ],
          if (operator.hasWebsite)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openWebsite(operator.displayWebsite),
                icon: const Icon(Icons.language, size: 18),
                label: const Text('Site web'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF009639),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink ? const Color(0xFF3860F8) : Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  void _openWebsite(String website) async {
    final uri = Uri.parse(website);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore errors silently
    }
  }
}