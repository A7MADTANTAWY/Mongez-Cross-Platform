import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/widgets/custom_text_form_field.dart';
import 'package:mongez/features/client/order/presentation/widgets/checkout_toggle_row.dart';
import 'package:mongez/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:mongez/generated/l10n.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool useAccountPhone;
  final ValueChanged<bool> onToggle;
  final FormFieldValidator<String> validator;

  const PhoneField({
    super.key,
    required this.controller,
    required this.useAccountPhone,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleRow(
          label: lang.useAccountPhone,
          value: useAccountPhone,
          onChanged: (value) {
            if (value) {
              final profileState = context.read<ProfileCubit>().state;
              if (profileState is ProfileSuccess) {
                controller.text = profileState.profile.phone;
              }
            }
            onToggle(value);
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: useAccountPhone
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: ReadOnlyField(
              icon: Icons.phone_outlined, text: controller.text),
          secondChild: CustomFormField(
            controller: controller,
            hintText: lang.phoneForOrder,
            keyboardType: TextInputType.phone,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
