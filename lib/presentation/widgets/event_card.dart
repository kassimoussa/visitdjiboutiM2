import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/models/event.dart';
import '../../core/services/favorites_service.dart';
import '../pages/event_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec overlay
            _buildImageSection(event),
            
            // Contenu
            Padding(
              padding: EdgeInsets.all(ResponsiveConstants.mediumSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et bouton favoris
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.body1,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2233),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.smallSpace),
                      _buildFavoriteButton(event),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveConstants.smallSpace),
                  
                  // Date et lieu
                  _buildEventInfo(event),
                  
                  SizedBox(height: ResponsiveConstants.smallSpace * 1.5),
                  
                  // Description
                  if (event.description != null && event.description!.isNotEmpty)
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.body2,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  SizedBox(height: ResponsiveConstants.smallSpace * 1.5),
                  
                  // Prix et statut
                  _buildEventFooter(event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Event event) {
    return Container(
      height: ResponsiveConstants.cardImageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Image de fond
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveConstants.mediumRadius)),
            child: CachedNetworkImage(
              imageUrl: event.imageUrl,
              width: double.infinity,
              height: ResponsiveConstants.cardImageHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerImagePlaceholder(),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.event,
                    size: 40,
                    color: Color(0xFF009639),
                  ),
                ),
              ),
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveConstants.mediumRadius)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Badge "À la une" si featured
          if (event.isFeatured)
            Positioned(
              top: ResponsiveConstants.smallSpace * 1.5,
              left: ResponsiveConstants.smallSpace * 1.5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
                decoration: BoxDecoration(
                  color: const Color(0xFF009639),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
                ),
                child: Text(
                  'À la une',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveConstants.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          // Badge de statut
          Positioned(
            top: ResponsiveConstants.smallSpace * 1.5,
            right: ResponsiveConstants.smallSpace * 1.5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
              decoration: BoxDecoration(
                color: _getStatusColor(event.statusText),
                borderRadius: BorderRadius.circular(ResponsiveConstants.mediumRadius),
              ),
              child: Text(
                event.statusText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveConstants.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(Event event) {
    return Column(
      children: [
        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: ResponsiveConstants.smallIcon,
              color: Colors.grey[600],
            ),
            SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
            Text(
              _formatEventDate(event),
              style: TextStyle(
                fontSize: ResponsiveConstants.caption + 1.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveConstants.tinySpace),
        
        // Lieu
        if (event.location.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: ResponsiveConstants.smallIcon,
                color: Colors.grey[600],
              ),
              SizedBox(width: ResponsiveConstants.tinySpace * 1.5),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.caption + 1.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEventFooter(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Prix
        if (event.price > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              '${event.price.toInt()} DJF',
              style: TextStyle(
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3860F8),
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smallSpace, vertical: ResponsiveConstants.tinySpace),
            decoration: BoxDecoration(
              color: const Color(0xFF009639).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
            ),
            child: Text(
              'Gratuit',
              style: TextStyle(
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.w600,
                color: Color(0xFF009639),
              ),
            ),
          ),
        
        // Capacité si limitée
        if (event.maxParticipants != null && event.maxParticipants! > 0)
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: ResponsiveConstants.smallIcon * 0.875,
                color: Colors.grey[600],
              ),
              SizedBox(width: ResponsiveConstants.tinySpace),
              Text(
                '${event.maxParticipants} places',
                style: TextStyle(
                  fontSize: ResponsiveConstants.caption,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(Event event) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveConstants.smallRadius),
      ),
      child: IconButton(
        onPressed: () => _toggleFavorite(event),
        icon: Icon(
          Icons.favorite,
          color: Colors.red,
          size: ResponsiveConstants.smallIcon,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _toggleFavorite(Event event) async {
    try {
      final success = await _favoritesService.toggleEventFavorite(event.id);
      if (success && mounted) {
        setState(() {}); // Refresh pour mettre à jour l'UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              await _favoritesService.isEventFavorite(event.id)
                  ? AppLocalizations.of(context)!.favoritesAddedToFavorites
                  : AppLocalizations.of(context)!.favoritesRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commonError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatEventDate(Event event) {
    try {
      final date = DateTime.parse(event.startDate);
      final months = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return event.startDate;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'à venir':
      case 'upcoming':
        return const Color(0xFF3860F8);
      case 'en cours':
      case 'ongoing':
        return const Color(0xFF009639);
      case 'terminé':
      case 'ended':
        return Colors.grey;
      default:
        return const Color(0xFF3860F8);
    }
  }

  Widget _buildShimmerImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: ResponsiveConstants.cardImageHeight,
        color: Colors.white,
      ),
    );
  }
}