import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongez/features/auth/bloc/auth_cubit.dart';
import 'package:mongez/features/auth/models/auth.dart';
import 'package:mongez/features/auth/models/governorate.dart';
import 'package:mongez/features/auth/repos/governorates_repo.dart';
import 'package:mongez/features/auth/screens/google_sign_in_screen.dart';
import 'package:mongez/features/auth/screens/pending_verification_screen.dart';
import 'package:mongez/core/app_colors.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/services/navigation_service.dart';
import 'package:mongez/services/services_locator.dart';
import 'package:mongez/widgets/custom_button.dart';
import 'package:mongez/widgets/custom_text_form_field.dart';
import 'package:mongez/widgets/logo.dart';

class CompleteProfileScreen extends StatefulWidget {
  final Auth auth;

  const CompleteProfileScreen({super.key, required this.auth});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  Governorate? _selectedGovernorate;
  String _selectedRole = 'client';
  Uint8List? _imageBytes;
  bool _makeDefault = true;

  late Future<List<Governorate>> _governoratesFuture;

  @override
  void initState() {
    super.initState();
    _governoratesFuture = _loadGovernorates();

    // Pre-fill name from Google
    final googleName = widget.auth.user?.nameAr ?? widget.auth.user?.displayName ?? '';
    if (googleName.isNotEmpty) {
      nameController.text = googleName;
    }

    // Pre-fill phone from Google (if available)
    final googlePhone = widget.auth.user?.phone ?? '';
    if (googlePhone.isNotEmpty) {
      phoneController.text = googlePhone;
    }

    // Load Google profile picture as default avatar
    _loadGoogleAvatar();
  }

  Future<void> _loadGoogleAvatar() async {
    final picUrl = widget.auth.googlePictureUrl?.isNotEmpty == true
        ? widget.auth.googlePictureUrl
        : widget.auth.user?.profileImage;
    if (picUrl == null || picUrl.isEmpty) return;
    try {
      final response = await Dio().get<List<int>>(
        picUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && mounted) {
        setState(() => _imageBytes = Uint8List.fromList(response.data!));
      }
    } catch (_) {}
  }

  Future<List<Governorate>> _loadGovernorates() async {
    final result = await getIt<GovernoratesRepo>().getGovernorates();
    return result.fold(
      (failure) => throw Exception(failure.errorMessage),
      (list) => list,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileCompleted) {
          NavigationService.toMainScreen(context, state.auth);
        } else if (state is AuthPendingVerification) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PendingVerificationScreen(auth: state.auth),
            ),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _showExitDialog(context);
            }
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Logo(),
                      const SizedBox(height: 24),

                      // Profile Image (display only)
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : null,
                          child: _imageBytes == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email (read-only)
                      CustomFormField(
                        controller: TextEditingController(
                          text: widget.auth.user?.email ?? '',
                        ),
                        hintText: 'Email',
                        enabled: false,
                        preIcon: Icon(
                          Icons.email_outlined,
                          color: textTheme.bodySmall?.color,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Full Name field
                      CustomFormField(
                        controller: nameController,
                        hintText: lang.fullName,
                        preIcon: Icon(
                          Icons.person,
                          color: textTheme.bodySmall?.color,
                        ),
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            return lang.pleaseEnterYourName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone Field
                      CustomFormField(
                        controller: phoneController,
                        hintText: lang.phoneNumber,
                        keyboardType: TextInputType.phone,
                        preIcon: Icon(
                          Icons.phone,
                          color: textTheme.bodySmall?.color,
                        ),
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          final phone = phoneController.text.trim();
                          if (phone.isEmpty) {
                            return lang.pleaseEnterYourPhoneNumber;
                          }
                          if (phone.length < 10) {
                            return lang.invalidPhoneNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Governorate dropdown
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh, color: colorScheme.error),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Couldn't load governorates — tap to retry",
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
                              hintText: 'Governorate / المحافظة',
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
                            onChanged: (g) => setState(() => _selectedGovernorate = g),
                            validator: (g) => g == null
                                ? 'Please pick your governorate'
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // City / Area (required)
                      CustomFormField(
                        controller: cityController,
                        hintText: lang.addressNickname,
                        preIcon: Icon(
                          Icons.label_outline,
                          color: textTheme.bodySmall?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a label (e.g. Home, Office)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Address (required)
                      CustomFormField(
                        controller: addressController,
                        hintText: lang.addressDetailsHint,
                        preIcon: Icon(
                          Icons.location_on_outlined,
                          color: textTheme.bodySmall?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Make default checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _makeDefault,
                            onChanged: (bool? value) {
                              setState(() => _makeDefault = value ?? false);
                            },
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            side: const BorderSide(color: AppColors.textTertiary, width: 2),
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
                      const SizedBox(height: 24),

                      // ── Account Type Selection ──
                      Text(
                        'Account Type',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose whether you are a client or a technician.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _RoleCard(
                              icon: Icons.person_outline,
                              label: 'Client',
                              subtitle: 'Hire technicians',
                              isSelected: _selectedRole == 'client',
                              onTap: () => setState(() => _selectedRole = 'client'),
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoleCard(
                              icon: Icons.build_outlined,
                              label: 'Worker',
                              subtitle: 'Provide services',
                              isSelected: _selectedRole == 'worker',
                              onTap: () => setState(() => _selectedRole = 'worker'),
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedRole == 'worker') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Your account will be reviewed by an admin before you can start working.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),

                      // Submit Button
                      state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              text: 'Complete Profile',
                              onPressed: () {
                                if (_formKey.currentState!.validate() &&
                                    _selectedGovernorate != null) {
                                  context.read<AuthCubit>().completeProfile(
                                    nameAr: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    role: _selectedRole,
                                    governorate: _selectedGovernorate!.code,
                                    city: cityController.text.trim(),
                                    address: addressController.text.trim(),
                                    makeDefault: _makeDefault,
                                    profileImageBytes: _imageBytes,
                                  );
                                }
                              },
                              backgroundColor: colorScheme.primary,
                              textColor: colorScheme.onPrimary,
                            ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave without completing?'),
        content: const Text(
          'Your account will be deleted if you leave without completing your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<AuthCubit>().deleteIncompleteProfile();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthCubit>(),
                      child: const GoogleSignInScreen(),
                    ),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Leave',
              style: tt.labelLarge?.copyWith(color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final bgColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
