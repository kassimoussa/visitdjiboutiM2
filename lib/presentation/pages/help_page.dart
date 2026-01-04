import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/responsive.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late List<Map<String, dynamic>> _faqItems;
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;

    _faqItems = [
      {
        'question': l10n.helpFaqQuestion1,
        'answer': l10n.helpFaqAnswer1,
        'category': l10n.helpCategoryEvents,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion2,
        'answer': l10n.helpFaqAnswer2,
        'category': l10n.helpCategoryUsage,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion3,
        'answer': l10n.helpFaqAnswer3,
        'category': l10n.helpCategoryFavorites,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion4,
        'answer': l10n.helpFaqAnswer4,
        'category': l10n.helpCategoryGeneral,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion5,
        'answer': l10n.helpFaqAnswer5,
        'category': l10n.helpCategorySettings,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion6,
        'answer': l10n.helpFaqAnswer6,
        'category': l10n.helpCategoryContent,
        'isExpanded': false,
      },
      {
        'question': l10n.helpFaqQuestion7,
        'answer': l10n.helpFaqAnswer7,
        'category': l10n.helpCategorySupport,
        'isExpanded': false,
      },
    ];

    _selectedCategory = l10n.helpCategoryAll;
    _categories = [
      l10n.helpCategoryAll,
      l10n.helpCategoryNavigation,
      l10n.helpCategoryEvents,
      l10n.helpCategoryUsage,
      l10n.helpCategoryFavorites,
      l10n.helpCategoryGeneral,
      l10n.helpCategorySettings,
      l10n.helpCategoryContent,
      l10n.helpCategorySupport,
    ];
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final l10n = AppLocalizations.of(context)!;
    final filteredFAQ = _selectedCategory == l10n.helpCategoryAll
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
              color: const Color(0xFF3860F8).withValues(alpha: 0.05),
            ),
            child: Column(
              children: [
               Text(
                  l10n.helpTitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.subtitle1,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3860F8),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mediumSpace),
                TextField(
                  decoration: InputDecoration(
                    hintText: l10n.helpSearchPlaceholder,
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
                  l10n.helpLiveChat,
                  () => _showLiveChat(),
                ),
                _buildQuickAction(
                  Icons.email,
                  l10n.helpContactUs,
                  () => _showContactForm(),
                ),
                _buildQuickAction(
                  Icons.video_library,
                  l10n.helpTutorials,
                  () => _showTutorials(),
                ),
                _buildQuickAction(
                  Icons.bug_report,
                  l10n.helpReportBug,
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
               Text(
                  AppLocalizations.of(context)!.helpCantFindAnswer,
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
                        label: Text(AppLocalizations.of(context)!.helpContactUs),
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smallSpace),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showLiveChat(),
                        icon: const Icon(Icons.chat),
                        label: Text(AppLocalizations.of(context)!.helpLiveChat),
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
                color: const Color(0xFF3860F8).withValues(alpha: 0.1),
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
                style:  TextStyle(
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
          style:  TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveConstants.body1,
          ),
        ),
        subtitle: Padding(
          padding: Responsive.only(top: 4),
          child: Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF3860F8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              faq['category'],
              style:  TextStyle(
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
            color: const Color(0xFF3860F8).withValues(alpha: 0.1),
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
               Text(
                  AppLocalizations.of(context)!.helpLiveChat,
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
                   Text(
                      AppLocalizations.of(context)!.helpLiveChat,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.subtitle2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.smallSpace),
                    Text(
                      AppLocalizations.of(context)!.helpLiveChatDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: ResponsiveConstants.largeSpace),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.helpLiveChatConnecting),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context)!.helpLiveChatStart),
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
               Text(
                AppLocalizations.of(context)!.helpContactUs,
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.helpContactSubject,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.helpContactMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.helpContactEmail,
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
                      child: Text(AppLocalizations.of(context)!.helpCancel),
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smallSpace),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.helpContactSuccess),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3860F8),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context)!.helpSend),
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
             Text(
              AppLocalizations.of(context)!.helpTutorialsTitle,
              style: TextStyle(
                fontSize: ResponsiveConstants.subtitle1,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mediumSpace),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: Text(AppLocalizations.of(context)!.helpTutorialMap),
              subtitle: Text(AppLocalizations.of(context)!.helpTutorialDuration3),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: Text(AppLocalizations.of(context)!.helpTutorialBooking),
              subtitle: Text(AppLocalizations.of(context)!.helpTutorialDuration2),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFF3860F8)),
              title: Text(AppLocalizations.of(context)!.helpTutorialFavorites),
              subtitle: Text(AppLocalizations.of(context)!.helpTutorialDuration1),
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
               Text(
                AppLocalizations.of(context)!.helpReportBug,
                style: TextStyle(
                  fontSize: ResponsiveConstants.subtitle1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.helpBugTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mediumSpace),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.helpBugDescription,
                  hintText: AppLocalizations.of(context)!.helpBugDescriptionHint,
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
                      child: Text(AppLocalizations.of(context)!.helpCancel),
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smallSpace),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.helpBugReportSent),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context)!.helpReport),
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