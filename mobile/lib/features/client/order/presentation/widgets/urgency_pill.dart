import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/features/client/order/data/models/order_model.dart';
import 'package:mongez/features/client/order/presentation/widgets/meta_pill.dart';
import 'package:mongez/generated/l10n.dart';

class UrgencyPill extends StatelessWidget {
  final OrderUrgency urgency;
  const UrgencyPill({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    Color color;
    IconData icon;
    String label;
    switch (urgency) {
      case OrderUrgency.low:
        color = AppColors.success;
        icon = Icons.schedule;
        label = lang.urgencyWhenever;
        break;
      case OrderUrgency.high:
        color = AppColors.danger;
        icon = Icons.local_fire_department_outlined;
        label = lang.urgencyEmergency;
        break;
      case OrderUrgency.normal:
        color = AppColors.primary;
        icon = Icons.today_outlined;
        label = lang.urgencyToday;
        break;
    }
    return MetaPill(icon: icon, label: label, color: color);
  }
}