import 'package:flutter/material.dart';
import 'package:visitdjibouti/core/utils/responsive.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How to use geolocation?', // TODO: Add translation key
      'answer': 'Enable location services in your phone settings, then allow Visit Djibouti to access your location. The app will automatically show you nearby POIs.', // TODO: Add translation key
      'category': 'Navigation',
      'isExpanded': false,
    },
    {
      'question': 'Comment réserver un événement ?',
      'answer': 'Allez dans l\'onglet Événements, sélectionnez un événement qui vous intéresse, puis appuyez sur "S\'inscrire". Vous pouvez gérer vos réservations dans votre profil.',
      'category': 'Événements',
      'isExpanded': false,
    },
    {
      'question': 'Puis-je utiliser l\'app sans connexion Internet ?',
      'answer': 'Oui ! Activez le mode hors ligne dans les paramètres pour télécharger les données essentielles. Les cartes peuvent également être téléchargées pour une utilisation offline.',
      'category': 'Utilisation',
      'isExpanded': false,
    },
    {
      'question': 'Comment ajouter un lieu en favoris ?',
      'answer': 'Sur la page de détail d\'un POI, appuyez sur l\'icône cœur. Vous retrouverez tous vos favoris dans votre profil.',
      'category': 'Favoris',
      'isExpanded': false,
    },
    {
      'question': 'L\'app est-elle gratuite ?',
      'answer': 'Oui, Visit Djibouti est entièrement gratuite. Certains événements peuvent avoir un coût, mais l\'application elle-même ne nécessite aucun paiement.',
      'category': 'Général',
      'isExpanded': false,
    },
    {
      'question': 'Comment changer la langue de l\'interface ?',
      'answer': 'Allez dans Paramètres > Langue et sélectionnez votre langue préférée (Français, English, العربية).',
      'category': 'Paramètres',
      'isExpanded': false,
    },
    {
      'question': 'Les informations sont-elles mises à jour ?',
      'answer': 'Oui, notre équipe met à jour régulièrement les informations sur les POIs et événements. Assurez-vous d\'avoir une connexion Internet pour recevoir les dernières données.',
      'category': 'Contenu',
      'isExpanded': false,
    },
    {
      'question': 'Comment signaler un problème avec un lieu ?',
      'answer': 'Utilisez la fonction "Commentaires" dans le menu principal pour nous signaler tout problème. Votre feedback nous aide à améliorer l\'application.',
      'category': 'Support',
      'isExpanded': false,
    },
  ];

  String _selectedCategory = 'Toutes';
  final List<String> _categories = [
    'Toutes',
    'Navigation',
    'Événements',
    'Utilisation',
    'Favoris',
    'Général',
    'Paramètres',
    'Contenu',
    'Support',
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final filteredFAQ = _selectedCategory == 'Toutes'
        ? _faqItems
        : _faqItems.where((item) => item['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerHelp),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header avec recherche
          Container(
            padding: Responsive.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.05),
            ),
            child: Column(
              children: [
                const Text(
                  'How can we help you?', // TODO: Add translation key
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle1,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3860F8),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans l\'aide...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    // Logic de recherche
                  },
                ),
              ],
            ),
          ),
          
          // Accès rapide
          Container(
            height: 80.h,
            padding: Responsive.symmetric(vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: ResponsiveConstants.mediumSpace),
                _buildQuickAction(
                  Icons.chat,
                  'Chat en direct',
                  () => _showLiveChat(),
                ),
                _buildQuickAction(
                  Icons.email,
                  'Nous contacter',
                  () => _showContactForm(),
                ),
                _buildQuickAction(
                  Icons.video_library,
                  'Tutoriels',
                  () => _showTutorials(),
                ),
                _buildQuickAction(
                  Icons.bug_report,
                  'Signaler un bug',
                  () => _showBugReport(),
                ),
                SizedBox(width: ResponsiveConstants.mediumSpace),
              ],
            ),
          ),
          
          // Filtres par catégorie
          Container(
            height: 50.h,
            padding: Responsive.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: Responsive.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
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
          
          SizedBox(height: ResponsiveConstants.smallSpace),
          
          // FAQ Liste
          Expanded(
            child: ListView.builder(
              padding: Responsive.symmetric(horizontal: 16),
              itemCount: filteredFAQ.length,
              itemBuilder: (context, index) {
                final faq = filteredFAQ[index];
                return _buildFAQItem(faq);
              },
            ),
          ),
          
          // Footer avec contact
          Container(
            padding: Responsive.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Vous ne trouvez pas la réponse ?',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.body1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smallSpace),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showContactForm(),
                        icon: const Icon(Icons.email),
                        label: const Text('Nous contacter'),
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smallSpace),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showLiveChat(),
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat en direct'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        margin: Responsive.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3860F8),
                size: 24,
              ),
            ),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Card(
      margin: Responsive.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveConstants.body1,
          ),
        ),
        subtitle: Padding(
          padding: Responsive.only(top: 4),
          child: Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              faq['category'],
              style: const TextStyle(
                color: Color(0xFF3860F8),
                fontSize: ResponsiveConstants.caption,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        leading: Container(
          padding: Responsive.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3860F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: const Icon(
            Icons.help_outline,
            color: Color(0xFF3860F8),
            size: 20,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: ResponsiveConstants.body2,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: Responsive.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Chat en direct',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            Expanded(
              child: Container(
                padding: Responsive.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat,
                      size: 64,
                      color: Color(0xFF3860F8),
                    ),
                    SizedBox(height: ResponsiveConstants.mediumSpace),
                    const Text(
                      'Chat en direct',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.subtitle2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.smallSpace),
                    Text(
                      'Notre équipe est disponible de 8h à 18h\npour répondre à vos questions en temps réel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: ResponsiveConstants.largeSpace),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connexion au chat en cours...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Démarrer le chat'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: Responsive.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nous contacter',
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sujet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Votre message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Votre email (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.largeSpace),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smallSpace),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message envoyé avec succès !'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
            ],
          ),
        ),
      ),
    );
  }

  void _showTutorials() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: Responsive.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tutoriels vidéo',
              style: TextStyle(
                fontSize: ResponsiveConstants.subtitle1,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: const Text('Comment utiliser la carte'),
              subtitle: const Text('3 min'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: const Text('Réserver un événement'),
              subtitle: const Text('2 min'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: const Text('Gérer ses favoris'),
              subtitle: const Text('1 min'),
              onTap: () {},
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
          ],
        ),
      ),
    );
  }

  void _showBugReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: Responsive.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: Responsive.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Signaler un problème',
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Titre du problème',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description détaillée',
                  hintText: 'Décrivez le problème rencontré...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.largeSpace),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smallSpace),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rapport de bug envoyé !'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Signaler'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
            ],
          ),
        ),
      ),
    );
  }
}