import 'package:flutter/material.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/constants/app_strings.dart';

class DailyProgressWidget extends StatelessWidget {
  const DailyProgressWidget({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E2DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppProgressBar(
        current: current,
        total: total,
        label: AppStrings.todayGoalLabel,
        showFraction: true,
      ),
    );
  }
}
