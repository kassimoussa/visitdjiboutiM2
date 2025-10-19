import 'package:flutter/material.dart';
import '../../core/services/tour_operator_service.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/api_response.dart';
import '../pages/tour_operator_detail_page.dart';
import '../../generated/l10n/app_localizations.dart';

class TourOperatorsPage extends StatefulWidget {
  const TourOperatorsPage({super.key});

  @override
  State<TourOperatorsPage> createState() => _TourOperatorsPageState();
}

class _TourOperatorsPageState extends State<TourOperatorsPage> {
  final TourOperatorService _operatorService = TourOperatorService();
  List<TourOperator> _operators = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTourOperators();
  }

  Future<void> _loadTourOperators() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ne pas filtrer par featured car l'API retourne un tableau vide avec ce filtre
      final ApiResponse<List<TourOperator>> response = await _operatorService.getTourOperators();

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          setState(() {
            _operators = response.data!;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? 'Error loading operators'; // TODO: Add translation key
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unexpected error occurred: $e'; // TODO: Add translation key
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTourOperators),
        backgroundColor: const Color(0xFF3860F8),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3860F8),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTourOperators,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3860F8),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _operators.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3860F8).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_center,
                              size: 48,
                              color: Color(0xFF3860F8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Aucun opérateur disponible',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D2233),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3860F8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.groups,
                                  color: Color(0xFF3860F8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_operators.length} partenaire${_operators.length > 1 ? 's' : ''} local${_operators.length > 1 ? 'aux' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D2233),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 3.2,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _operators.length,
                            itemBuilder: (context, index) {
                              final operator = _operators[index];
                              return _buildModernOperatorCard(operator);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildModernOperatorCard(TourOperator operator) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TourOperatorDetailPage(operator: operator),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              operator.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2233),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (operator.featured == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF009639),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Recommandé',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (operator.hasPhone)
                            _buildContactChip(Icons.phone, operator.displayPhone),
                          if (operator.hasPhone && operator.hasEmail)
                            const SizedBox(width: 8),
                          if (operator.hasEmail)
                            _buildContactChip(Icons.email, operator.displayEmail),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3860F8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF3860F8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF3860F8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF3860F8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}