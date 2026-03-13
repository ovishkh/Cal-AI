//final
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nutrition_info.dart';
import '../utils/app_theme.dart';

class NutritionChart extends StatefulWidget {
  final NutritionInfo nutritionInfo;

  const NutritionChart({super.key, required this.nutritionInfo});

  @override
  State<NutritionChart> createState() => _NutritionChartState();
}

class _NutritionChartState extends State<NutritionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Track which section is tapped
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header gradient bar
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor,
                    Color(0xFF80CBC4),
                    AppTheme.primaryLight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food title and calories
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppTheme.accentColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nutritionInfo.foodName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.nutritionInfo.calories} calories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildHealthScoreBadge(widget.nutritionInfo.healthScore),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Chart and legend
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return SizedBox(
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (
                                          FlTouchEvent event,
                                          pieTouchResponse,
                                        ) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              _touchedIndex = -1;
                                              return;
                                            }
                                            _touchedIndex =
                                                pieTouchResponse
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: _createPieChartSections(
                                        _animation.value,
                                      ),
                                      startDegreeOffset: -90,
                                    ),
                                  ),
                                  // Center text
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_calculateTotalGrams().toStringAsFixed(1)}g',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Macros Legend
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Macronutrients',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMacroIndicator(
                              'Protein',
                              '${widget.nutritionInfo.macros.protein}g',
                              const Color(0xFFF44336),
                              0,
                            ),
                            const SizedBox(height: 12),
                            _buildMacroIndicator(
                              'Carbs',
                              '${widget.nutritionInfo.macros.carbs}g',
                              const Color(0xFF2196F3),
                              1,
                            ),
                            const SizedBox(height: 12),
                            _buildMacroIndicator(
                              'Fat',
                              '${widget.nutritionInfo.macros.fat}g',
                              const Color(0xFFFFB300),
                              2,
                            ),
                            const SizedBox(height: 12),
                            _buildMacroIndicator(
                              'Fiber',
                              '${widget.nutritionInfo.macros.fiber}g',
                              const Color(0xFF4CAF50),
                              3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nutritional Overview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.nutritionInfo.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: AppTheme.textPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips
                  Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nutrition Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.nutritionInfo.nutritionTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(
    String label,
    String value,
    Color color,
    int index,
  ) {
    final isSelected = _touchedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isSelected ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(double animationValue) {
    final double totalMacros = _calculateTotalGrams();

    if (totalMacros == 0) {
      // Return dummy data if no macros are available
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: '',
          radius: 50 * animationValue,
        ),
      ];
    }

    return [
      _buildSection(
        value: widget.nutritionInfo.macros.protein,
        color: const Color(0xFFF44336),
        title: 'P',
        index: 0,
        animationValue: animationValue,
      ),
      _buildSection(
        value: widget.nutritionInfo.macros.carbs,
        color: const Color(0xFF2196F3),
        title: 'C',
        index: 1,
        animationValue: animationValue,
      ),
      _buildSection(
        value: widget.nutritionInfo.macros.fat,
        color: const Color(0xFFFFB300),
        title: 'F',
        index: 2,
        animationValue: animationValue,
      ),
      _buildSection(
        value: widget.nutritionInfo.macros.fiber,
        color: const Color(0xFF4CAF50),
        title: 'Fb',
        index: 3,
        animationValue: animationValue,
      ),
    ];
  }

  PieChartSectionData _buildSection({
    required double value,
    required Color color,
    required String title,
    required int index,
    required double animationValue,
  }) {
    final isTouched = index == _touchedIndex;
    final double fontSize = isTouched ? 18 : 14;
    final double radius = isTouched ? 60 * animationValue : 50 * animationValue;

    return PieChartSectionData(
      color: color,
      value: value,
      title: value > 3 ? '${value.round()}g' : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
      ),
    );
  }

  Widget _buildHealthScoreBadge(int score) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getHealthScoreColor(score).withOpacity(0.1),
        border: Border.all(color: _getHealthScoreColor(score), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getHealthScoreColor(score).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: TextStyle(
              color: _getHealthScoreColor(score),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/10',
            style: TextStyle(color: _getHealthScoreColor(score), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.amber;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  double _calculateTotalGrams() {
    return widget.nutritionInfo.macros.protein +
        widget.nutritionInfo.macros.carbs +
        widget.nutritionInfo.macros.fat +
        widget.nutritionInfo.macros.fiber;
  }
}
