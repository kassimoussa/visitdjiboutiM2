import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<Map<String, dynamic>> _events = [
    {
      'id': 1,
      'title': 'Festival de la Mer Rouge',
      'description': 'Festival de musique et culture traditionnelle djiboutienne avec artistes locaux et internationaux',
      'startDate': DateTime(2024, 3, 15, 18, 0),
      'endDate': DateTime(2024, 3, 17, 23, 0),
      'location': 'Place Mahmoud Harbi, Djibouti Ville',
      'price': 0.0,
      'maxParticipants': 5000,
      'currentParticipants': 1250,
      'isFeatured': true,
      'isRegistered': false,
      'image': '🎵',
      'category': 'Culture',
    },
    {
      'id': 2,
      'title': 'Marathon du Grand Bara',
      'description': 'Course de marathon à travers le magnifique désert du Grand Bara',
      'startDate': DateTime(2024, 3, 22, 6, 0),
      'endDate': DateTime(2024, 3, 22, 12, 0),
      'location': 'Désert du Grand Bara',
      'price': 25.0,
      'maxParticipants': 300,
      'currentParticipants': 189,
      'isFeatured': true,
      'isRegistered': true,
      'image': '🏃',
      'category': 'Sport',
    },
    {
      'id': 3,
      'title': 'Salon du Tourisme 2024',
      'description': 'Exposition des richesses touristiques de Djibouti et rencontres professionnelles',
      'startDate': DateTime(2024, 3, 28, 9, 0),
      'endDate': DateTime(2024, 3, 30, 18, 0),
      'location': 'Palais du Peuple, Djibouti Ville',
      'price': 5.0,
      'maxParticipants': 2000,
      'currentParticipants': 456,
      'isFeatured': false,
      'isRegistered': false,
      'image': '🏢',
      'category': 'Business',
    },
    {
      'id': 4,
      'title': 'Excursion Lac Assal',
      'description': 'Visite guidée du lac Assal avec déjeuner traditionnel et baignade',
      'startDate': DateTime(2024, 4, 5, 7, 0),
      'endDate': DateTime(2024, 4, 5, 17, 0),
      'location': 'Lac Assal, Tadjourah',
      'price': 45.0,
      'maxParticipants': 50,
      'currentParticipants': 23,
      'isFeatured': false,
      'isRegistered': false,
      'image': '🚌',
      'category': 'Excursion',
    },
    {
      'id': 5,
      'title': 'Nuit des Étoiles',
      'description': 'Observation astronomique dans le désert avec télescopes professionnels',
      'startDate': DateTime(2024, 4, 12, 20, 0),
      'endDate': DateTime(2024, 4, 13, 2, 0),
      'location': 'Désert d\'Arta',
      'price': 15.0,
      'maxParticipants': 100,
      'currentParticipants': 67,
      'isFeatured': false,
      'isRegistered': false,
      'image': '🌟',
      'category': 'Science',
    },
    {
      'id': 6,
      'title': 'Plongée Îles Moucha',
      'description': 'Sortie plongée avec masque et tuba dans les récifs coralliens',
      'startDate': DateTime(2024, 4, 18, 8, 0),
      'endDate': DateTime(2024, 4, 18, 16, 0),
      'location': 'Îles Moucha',
      'price': 65.0,
      'maxParticipants': 20,
      'currentParticipants': 12,
      'isFeatured': false,
      'isRegistered': false,
      'image': '🤿',
      'category': 'Sport',
    },
  ];

  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'À venir', 'Mes réservations', 'Gratuit'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    final filteredEvents = _getFilteredEvents();

    return Column(
        children: [
          // Filtres
          Container(
            height: isSmallScreen ? 45 : 50,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16, 
              vertical: 8
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF3860F8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Liste des événements
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      );
  }

  List<Map<String, dynamic>> _getFilteredEvents() {
    switch (_selectedFilter) {
      case 'À venir':
        return _events.where((event) => 
          event['startDate'].isAfter(DateTime.now())).toList();
      case 'Mes réservations':
        return _events.where((event) => event['isRegistered'] == true).toList();
      case 'Gratuit':
        return _events.where((event) => event['price'] == 0.0).toList();
      default:
        return _events;
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final startDate = event['startDate'] as DateTime;
    final isRegistered = event['isRegistered'] as bool;
    final availableSpots = event['maxParticipants'] - event['currentParticipants'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec image et badge
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3860F8).withOpacity(0.8),
                      const Color(0xFF006B96).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    event['image'],
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
              if (event['isFeatured'])
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Populaire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isRegistered)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009639),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Inscrit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  event['description'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Date et lieu
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${startDate.day}/${startDate.month}/${startDate.year}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Prix et places disponibles
                Row(
                  children: [
                    // Prix
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: event['price'] == 0.0 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFF3860F8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['price'] == 0.0 
                            ? 'Gratuit' 
                            : '${event['price']} USD',
                        style: TextStyle(
                          color: event['price'] == 0.0 
                              ? const Color(0xFF10B981)
                              : const Color(0xFF3860F8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Places disponibles
                    Text(
                      '$availableSpots places restantes',
                      style: TextStyle(
                        color: availableSpots < 10 
                            ? const Color(0xFFEF4444)
                            : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleEventAction(event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered 
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isRegistered ? 'Annuler inscription' : 'S\'inscrire',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleEventAction(Map<String, dynamic> event) {
    setState(() {
      event['isRegistered'] = !event['isRegistered'];
      if (event['isRegistered']) {
        event['currentParticipants']++;
      } else {
        event['currentParticipants']--;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event['isRegistered'] 
              ? 'Inscription confirmée pour ${event['title']}'
              : 'Inscription annulée pour ${event['title']}',
        ),
        backgroundColor: event['isRegistered'] 
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
      ),
    );
  }
}