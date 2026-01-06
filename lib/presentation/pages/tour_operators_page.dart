import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      final ApiResponse<List<TourOperator>> response = await _operatorService
          .getTourOperators();

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
            _errorMessage =
                response.message ??
                AppLocalizations.of(context)!.tourOperatorsErrorLoading;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(
            context,
          )!.tourOperatorsErrorUnexpected('$e');
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
              child: CircularProgressIndicator(color: Color(0xFF3860F8)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadTourOperators,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3860F8),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.tourOperatorsRetry,
                    ),
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
                    padding: Responsive.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business_center,
                      size: 48,
                      color: Color(0xFF3860F8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    AppLocalizations.of(context)!.tourOperatorsEmptyMessage,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D2233),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: Responsive.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: Responsive.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Color(0xFF3860F8),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.tourOperatorsPartnersCount('${_operators.length}'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D2233),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 2.5,
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
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TourOperatorDetailPage(operator: operator),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: Responsive.all(20),
            child: Row(
              children: [
                // Logo section
                if (operator.logo != null && operator.logoUrl.isNotEmpty)
                  Container(
                    width: 65.w,
                    height: 65.h,
                    margin: Responsive.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!, width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: operator.logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3860F8),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF3860F8).withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF3860F8),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2233),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (operator.featured == true)
                            Container(
                              padding: Responsive.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF009639),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tourOperatorsFeatured,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (operator.hasPhone)
                            _buildContactChip(
                              Icons.phone,
                              operator.displayPhone,
                            ),
                          if (operator.hasPhone && operator.hasEmail)
                            SizedBox(height: 6.h),
                          if (operator.hasEmail)
                            _buildContactChip(
                              Icons.email,
                              operator.displayEmail,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  padding: Responsive.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3860F8).withValues(alpha: 0.1),
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
      padding: Responsive.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3860F8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF3860F8)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Color(0xFF3860F8),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
