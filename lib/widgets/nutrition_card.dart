import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionCard extends StatelessWidget {
  final Map<String, dynamic> nutritionData;

  const NutritionCard({super.key, required this.nutritionData});

  @override
  Widget build(BuildContext context) {
    final macros = nutritionData['macros'] as Map<String, dynamic>;
    final total =
        macros['protein'] + macros['carbs'] + macros['fat'] + macros['fiber'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with food name
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  'Nutrition Analysis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),

            // Food name and health score
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nutritionData['foodName'] ?? 'Unknown Food',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildHealthScoreBadge(nutritionData['healthScore'] ?? 5),
                ],
              ),
            ),

            // Pie chart with macros
            AspectRatio(
              aspectRatio: 1.5,
              child: Row(
                children: [
                  // Pie chart
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          _buildPieChartSection(
                            'Protein',
                            macros['protein'] / total,
                            Colors.red.shade400,
                          ),
                          _buildPieChartSection(
                            'Carbs',
                            macros['carbs'] / total,
                            Colors.blue.shade400,
                          ),
                          _buildPieChartSection(
                            'Fat',
                            macros['fat'] / total,
                            Colors.yellow.shade700,
                          ),
                          _buildPieChartSection(
                            'Fiber',
                            macros['fiber'] / total,
                            Colors.green.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Legend
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'Protein',
                          macros['protein'].toString() + 'g',
                          Colors.red.shade400,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Carbs',
                          macros['carbs'].toString() + 'g',
                          Colors.blue.shade400,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Fat',
                          macros['fat'].toString() + 'g',
                          Colors.yellow.shade700,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Fiber',
                          macros['fiber'].toString() + 'g',
                          Colors.green.shade400,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Calories',
                          nutritionData['calories'].toString(),
                          Colors.deepOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              nutritionData['description'] ??
                  'No nutrition description available.',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 16),

            // Nutrition tips section
            const Text(
              'Nutrition Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8),

            ...List.generate(
              (nutritionData['nutritionTips'] as List?)?.length ?? 0,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nutritionData['nutritionTips'][index],
                        style: const TextStyle(fontSize: 15),
                      ),
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

  Widget _buildHealthScoreBadge(int score) {
    Color badgeColor;
    if (score >= 8) {
      badgeColor = Colors.green;
    } else if (score >= 5) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Health Score: $score',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
    String title,
    double percentage,
    Color color,
  ) {
    return PieChartSectionData(
      color: color,
      value: percentage * 100,
      title: '${(percentage * 100).toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
