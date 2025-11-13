import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/tour_operator.dart';
import '../pages/tour_operator_detail_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourOperatorCard extends StatelessWidget {
  final TourOperator operator;

  const TourOperatorCard({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourOperatorDetailPage(operator: operator),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo et nom
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: operator.logoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: operator.logoUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Icon(Icons.business, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(Icons.business, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) => Text(
                        operator.name ?? AppLocalizations.of(context)!.tourUnknownOperator,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              if (operator.description != null && operator.description!.isNotEmpty)
                Text(
                  operator.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              // Contact info
              if (operator.address != null && operator.address!.isNotEmpty)
                _buildContactInfo(Icons.location_on, operator.address!),
              if (operator.displayPhone != 'N/A')
                _buildContactInfo(Icons.phone, operator.displayPhone),
              if (operator.displayEmail != 'N/A')
                _buildContactInfo(Icons.email, operator.displayEmail),
              const SizedBox(height: 8),
              
              // Action buttons
              Row(
                children: [
                  if (operator.displayPhone != 'N/A')
                    Expanded(
                      child: Builder(
                        builder: (context) => ElevatedButton.icon(
                          onPressed: () => _launchPhone(operator.displayPhone),
                          icon: const Icon(Icons.phone, size: 16),
                          label: Text(AppLocalizations.of(context)!.tourCall),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3860F8),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (operator.displayPhone != 'N/A' && operator.website != null)
                    const SizedBox(width: 8),
                  if (operator.website != null && operator.website!.isNotEmpty)
                    Expanded(
                      child: Builder(
                        builder: (context) => OutlinedButton.icon(
                          onPressed: () => _launchWebsite(operator.website!),
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(AppLocalizations.of(context)!.tourWebsite),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3860F8),
                          ),
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

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      // Ignore errors silently
    }
  }

  void _launchWebsite(String website) async {
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
