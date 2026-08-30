import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/features/auth/models/governorate.dart';
import 'package:mongez/features/auth/repos/governorates_repo.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/network/api_service.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/core/widgets/custom_app_bar.dart';
import 'package:mongez/core/widgets/custom_button.dart';
import 'package:mongez/core/widgets/custom_text_form_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  Governorate? _selectedGovernorate;
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  late Future<List<Governorate>> _governoratesFuture;

  @override
  void initState() {
    super.initState();
    _governoratesFuture = _loadGovernorates();
  }

  Future<List<Governorate>> _loadGovernorates() async {
    final result = await getIt<GovernoratesRepo>().getSupportedGovernorates();
    return result.fold(
      (failure) => throw Exception(failure.errorMessage),
      (list) => list,
    );
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) return;
    setState(() => _saving = true);
    try {
      await getIt<ApiService>().post(
        endPoint: Endpoints.addresses,
        body: {
          'governorate': _selectedGovernorate!.code,
          'city': _cityCtrl.text.trim(),
          'address': address,
          'is_default': _isDefault,
        },
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[ADDRESS] Save failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).failedToSave),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = S.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: lang.addNewAddress),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      lang.governorateHint,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Governorate>>(
                      future: _governoratesFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return InkWell(
                            onTap: () {
                              if (!mounted) return;
                              setState(() {
                                _governoratesFuture = _loadGovernorates();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.refresh, color: colorScheme.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lang.failedToLoad,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final govs = snap.data ?? const <Governorate>[];
                        return DropdownButtonFormField<Governorate>(
                          initialValue: _selectedGovernorate,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: lang.governorateHint,
                            prefixIcon: Icon(
                              Icons.map_outlined,
                              color: textTheme.bodySmall?.color,
                            ),
                          ),
                          items: govs
                              .map(
                                (g) => DropdownMenuItem<Governorate>(
                                  value: g,
                                  child: Text(
                                    '${g.nameAr} · ${g.nameEn}',
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (g) =>
                              setState(() => _selectedGovernorate = g),
                          validator: (g) =>
                              g == null ? lang.pleasePickGovernorate : null,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      lang.addressDetails,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomFormField(
                      controller: _cityCtrl,
                      hintText: lang.areaDistrictHint,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? lang.thisFieldRequired
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomFormField(
                      controller: _addressCtrl,
                      hintText: lang.addressDetailsHint,
                      keyboardType: TextInputType.multiline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? lang.thisFieldRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (bool? value) {
                            setState(() => _isDefault = value ?? false);
                          },
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: AppColors.textTertiary,
                            width: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.makeDefault,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _saving ? '...' : lang.apply,
                      onPressed: _saving ? null : () => _save(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
