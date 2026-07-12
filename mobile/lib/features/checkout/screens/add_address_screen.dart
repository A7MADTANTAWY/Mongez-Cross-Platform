import 'package:flutter/material.dart';
import 'package:mongez/core/app_colors.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/services/api_service.dart';
import 'package:mongez/services/services_locator.dart';
import 'package:mongez/widgets/custom_app_bar.dart';
import 'package:mongez/widgets/custom_button.dart';
import 'package:mongez/widgets/custom_text_form_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _labelCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) return;
    setState(() => _saving = true);
    try {
      await getIt<ApiService>().post(
        endPoint: Endpoints.addresses,
        body: {
          'label': _labelCtrl.text.trim(),
          'address': address,
          'is_default': _isDefault,
        },
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: lang.addNewAddress),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Divider(thickness: 1, color: AppColors.gray3),
                  const SizedBox(height: 12),
                  Text(
                    lang.addressNickname,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomFormField(
                    controller: _labelCtrl,
                    hintText: 'e.g. Home, Office',
                  ),
                  const SizedBox(height: 30),
                  Text(
                    lang.addressDetails,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomFormField(
                    controller: _addressCtrl,
                    hintText: 'e.g. 12 Street Name, District',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _isDefault,
                        onChanged: (bool? value) {
                          setState(() => _isDefault = value ?? false);
                        },
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.makeDefault,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: lang.apply,
                    onPressed: _saving ? () {} : () => _save(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
