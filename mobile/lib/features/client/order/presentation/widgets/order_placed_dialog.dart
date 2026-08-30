import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/widgets/custom_button.dart';
import 'package:mongez/features/client/order/presentation/cubit/customer_orders_cubit.dart';
import 'package:mongez/generated/l10n.dart';

class OrderPlacedDialog extends StatelessWidget {
  const OrderPlacedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(lang.orderPlaced, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(lang.orderSuccess),
            const SizedBox(height: 20),
            CustomButton(
              text: lang.ok,
              onPressed: () async {
                final navigator = Navigator.of(context);
                context.read<CustomerOrdersCubit>().getOrders();
                Navigator.pop(context);
                navigator.popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
