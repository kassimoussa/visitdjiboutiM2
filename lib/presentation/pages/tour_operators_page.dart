import 'package:flutter/material.dart';
import '../../core/services/tour_operator_service.dart';
import '../../core/models/tour_operator.dart';
import '../../core/models/api_response.dart';
import '../widgets/tour_operator_card.dart';
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
      final ApiResponse<List<TourOperator>> response = await _operatorService.getTourOperators(
        perPage: 20, // Charger plus d'opérateurs
      );

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
                          Icon(
                            Icons.business_center,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun opérateur touristique trouvé',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _operators.length,
                      itemBuilder: (context, index) {
                        final operator = _operators[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TourOperatorCard(operator: operator),
                        );
                      },
                    ),
    );
  }
}