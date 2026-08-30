import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/features/client/order/data/models/order_model.dart';
import 'package:mongez/features/client/order/presentation/widgets/meta_pill.dart';

class UrgencyPill extends StatelessWidget {
  final OrderUrgency urgency;
  final String locale;
  const UrgencyPill({super.key, required this.urgency, required this.locale});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (urgency) {
      case OrderUrgency.low:
        color = AppColors.success;
        icon = Icons.schedule;
        break;
      case OrderUrgency.high:
        color = AppColors.danger;
        icon = Icons.local_fire_department_outlined;
        break;
      case OrderUrgency.normal:
        color = AppColors.primary;
        icon = Icons.today_outlined;
        break;
    }
    final label = locale == 'ar' ? urgency.labelAr : urgency.label;
    return MetaPill(icon: icon, label: label, color: color);
  }
}
