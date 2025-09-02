import 'package:flutter/material.dart';
import '../../core/models/category.dart';
import '../../generated/l10n/app_localizations.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category?) onCategorySelected;
  final bool isSmallScreen;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isSmallScreen = false,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget>
    with SingleTickerProviderStateMixin {
  bool _showBottomSheet = false;
  late AnimationController _animationController;
  Category? _expandedCategory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton principal de filtrage
        _buildFilterButton(),
        
        // Chips des catégories sélectionnées/rapides
        _buildQuickFilters(),
        
        // Bottom sheet pour filtrage avancé
        if (_showBottomSheet) _buildFilterBottomSheet(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 12 : 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Bouton de filtrage principal
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showBottomSheet = !_showBottomSheet;
                });
                if (_showBottomSheet) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: widget.selectedCategory != null 
                      ? const Color(0xFF3860F8) 
                      : Colors.grey.shade300,
                    width: widget.selectedCategory != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: widget.selectedCategory != null 
                        ? const Color(0xFF3860F8) 
                        : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.selectedCategory?.name ?? 'Filtrer par catégorie',
                        style: TextStyle(
                          color: widget.selectedCategory != null 
                            ? const Color(0xFF3860F8) 
                            : Colors.grey[700],
                          fontWeight: widget.selectedCategory != null 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (widget.selectedCategory != null)
                      GestureDetector(
                        onTap: () {
                          widget.onCategorySelected(null);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF3860F8),
                          size: 18,
                        ),
                      )
                    else
                      Icon(
                        _showBottomSheet ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Compteur de résultats si filtré
          if (widget.selectedCategory != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3860F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.filter_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    if (widget.categories.isEmpty) return const SizedBox.shrink();
    
    // Afficher les 3-4 catégories les plus populaires comme filtres rapides
    final quickCategories = widget.categories
        .where((c) => c.isParentCategory)
        .take(4)
        .toList();
    
    if (quickCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? 12 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickCategories.length + 1, // +1 pour "Tous"
        itemBuilder: (context, index) {
          if (index == 0) {
            // Bouton "Tous"
            return _buildQuickFilterChip(
              null,
              'Tous',
              Icons.apps,
              widget.selectedCategory == null,
            );
          }
          
          final category = quickCategories[index - 1];
          return _buildQuickFilterChip(
            category,
            category.name,
            _getCategoryIcon(category),
            widget.selectedCategory?.id == category.id,
          );
        },
      ),
    );
  }

  Widget _buildQuickFilterChip(
    Category? category, 
    String label, 
    IconData icon, 
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => widget.onCategorySelected(category),
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF3860F8),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: _animationController.value * 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Filtrer par catégorie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          widget.onCategorySelected(null);
                          setState(() {
                            _expandedCategory = null;
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.categoryFilterClear),
                      ),
                    ],
                  ),
                ),
                
                // Liste des catégories
                Expanded(
                  child: _buildCategoryList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    final parentCategories = widget.categories
        .where((c) => c.isParentCategory)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: parentCategories.length,
      itemBuilder: (context, index) {
        final category = parentCategories[index];
        final isExpanded = _expandedCategory?.id == category.id;
        final isSelected = widget.selectedCategory?.id == category.id || 
                          (widget.selectedCategory?.parentId == category.id);

        return Column(
          children: [
            // Catégorie parente
            ListTile(
              leading: Icon(
                _getCategoryIcon(category),
                color: isSelected ? const Color(0xFF3860F8) : Colors.grey[600],
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF3860F8) : null,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category.hasSubCategories)
                    Text(
                      '${category.subCategories?.length ?? 0}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  if (category.hasSubCategories) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ],
              ),
              onTap: () {
                if (category.hasSubCategories) {
                  setState(() {
                    _expandedCategory = isExpanded ? null : category;
                  });
                } else {
                  widget.onCategorySelected(category);
                  _closeBottomSheet();
                }
              },
            ),
            
            // Sous-catégories
            if (isExpanded && category.hasSubCategories)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: category.subCategories!.map((subCategory) {
                    final isSubSelected = widget.selectedCategory?.id == subCategory.id;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 56, right: 16),
                      title: Text(
                        subCategory.name,
                        style: TextStyle(
                          fontWeight: isSubSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSubSelected ? const Color(0xFF3860F8) : null,
                          fontSize: 14,
                        ),
                      ),
                      leading: Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSubSelected 
                            ? const Color(0xFF3860F8) 
                            : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      onTap: () {
                        widget.onCategorySelected(subCategory);
                        _closeBottomSheet();
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  void _closeBottomSheet() {
    setState(() {
      _showBottomSheet = false;
    });
    _animationController.reverse();
  }

  IconData _getCategoryIcon(Category category) {
    // Utiliser l'icône de la catégorie si disponible, sinon utiliser une icône par défaut
    if (category.icon != null && category.icon!.isNotEmpty) {
      // Mapper les noms d'icônes vers IconData si nécessaire
      return _mapIconName(category.icon!);
    }
    
    // Fallback basé sur le slug ou l'ID pour les catégories parentes spécifiques
    switch (category.id) {
      case 5:  // Première catégorie parente
        return Icons.museum;
      case 15: // Deuxième catégorie parente
        return Icons.landscape;
      case 20: // Troisième catégorie parente
        return Icons.restaurant;
      case 26: // Quatrième catégorie parente
        return Icons.shopping_bag;
      default:
        // Fallback basé sur le slug
        switch (category.slug.toLowerCase()) {
          case 'culture':
          case 'patrimoine':
          case 'musee':
          case 'musees':
            return Icons.museum;
          case 'nature':
          case 'paysage':
          case 'parc':
          case 'parcs':
            return Icons.landscape;
          case 'restaurant':
          case 'gastronomie':
          case 'cuisine':
            return Icons.restaurant;
          case 'shopping':
          case 'marche':
          case 'artisanat':
            return Icons.shopping_bag;
          case 'activite':
          case 'activites':
          case 'sport':
          case 'loisir':
            return Icons.sports;
          case 'plage':
          case 'plages':
            return Icons.beach_access;
          case 'montagne':
          case 'montagnes':
            return Icons.terrain;
          case 'monument':
          case 'monuments':
            return Icons.location_city;
          case 'historique':
          case 'histoire':
            return Icons.history;
          default:
            return Icons.category;
        }
    }
  }
  
  IconData _mapIconName(String iconName) {
    // Mapper les noms d'icônes provenant de l'API vers IconData
    switch (iconName.toLowerCase()) {
      case 'museum':
      case 'musee':
        return Icons.museum;
      case 'landscape':
      case 'nature':
        return Icons.landscape;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'shopping':
      case 'shop':
        return Icons.shopping_bag;
      case 'sports':
      case 'activity':
        return Icons.sports;
      case 'beach':
        return Icons.beach_access;
      case 'mountain':
        return Icons.terrain;
      case 'monument':
        return Icons.location_city;
      case 'history':
        return Icons.history;
      default:
        return Icons.category;
    }
  }
}