import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/client/order/presentation/cubit/checkout_cubit.dart';
import 'package:mongez/generated/l10n.dart';

class CheckoutSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CheckoutSubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = S.of(context);
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final isLoading = state is CheckoutLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    lang.placeOrder,
                    style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }
}
