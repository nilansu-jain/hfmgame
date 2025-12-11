import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

class FourBarGraph extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      "label": "A",
      "value": 18,
      "color": AppColors.op1Color,
      "image": AppImages.optionC1,
    },
    {
      "label": "B",
      "value": 10,
      "color": AppColors.op2Color,
      "image": AppImages.optionC2,
    },
    {
      "label": "C",
      "value": 6,
      "color": AppColors.op3Color,
      "image": AppImages.optionC3,
    },
    {
      "label": "D",
      "value": 3,
      "color": AppColors.op4Color,
      "image": AppImages.optionC4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double maxValue = items.fold(
      0.0,
          (prev, e) => (e['value'] as num).toDouble() > prev
          ? (e['value'] as num).toDouble()
          : prev,
    );
    return Column(
      children: items.map((item) {
        double widthFactor = item['value'] / maxValue;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              /// LEFT IMAGE
              Image.asset(
                item["image"],
                height: 20,
                width: 20,
              ),

              const SizedBox(width: 12),

              /// BAR
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    /// Background bar
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: item["color"].withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    /// Filled bar
                    FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: item["color"],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// COUNT
              Text(
                item['value'].toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: item['color'],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
