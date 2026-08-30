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
import 'package:mongez/features/worker/profile_setup/presentation/screens/pending_verification_screen.dart';
import 'package:mongez/features/worker/profile_setup/presentation/widgets/exit_profile_dialog.dart';
import 'package:mongez/features/worker/profile_setup/presentation/widgets/governorate_field.dart';
import 'package:mongez/features/worker/profile_setup/presentation/widgets/role_card.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/routing/navigation_service.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/core/widgets/custom_button.dart';
import 'package:mongez/core/widgets/custom_text_form_field.dart';
import 'package:mongez/core/widgets/logo.dart';

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
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      )).get<List<int>>(
        picUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && mounted) {
        setState(() => _imageBytes = Uint8List.fromList(response.data!));
      }
    } catch (e) {
      debugPrint('[AVATAR] Failed to load Google avatar: $e');
    }
  }

  Future<List<Governorate>> _loadGovernorates() async {
    final result = await getIt<GovernoratesRepo>().getSupportedGovernorates();
    return result.fold(
      (failure) => throw Exception(failure.errorMessage),
      (list) => list,
    );
  }

  void _retryGovernorates() {
    if (!mounted) return;
    setState(() {
      _governoratesFuture = _loadGovernorates();
    });
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
                          child: _imageBytes != null
                              ? ClipOval(
                                  child: Image.memory(
                                    _imageBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: colorScheme.primary,
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email (read-only)
                      CustomFormField(
                        controller: TextEditingController(
                          text: widget.auth.user?.email ?? '',
                        ),
                        hintText: lang.email,
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
                      GovernorateField(
                        future: _governoratesFuture,
                        selected: _selectedGovernorate,
                        onChanged: (g) => setState(() => _selectedGovernorate = g),
                        onRetry: _retryGovernorates,
                      ),
                      const SizedBox(height: 20),

                      // City (required)
                      CustomFormField(
                        controller: cityController,
                        hintText: lang.areaDistrictHint,
                        preIcon: Icon(
                          Icons.location_city_outlined,
                          color: textTheme.bodySmall?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return lang.thisFieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Detailed Address (required)
                      CustomFormField(
                        controller: addressController,
                        hintText: lang.addressDetailsHint,
                        preIcon: Icon(
                          Icons.location_on_outlined,
                          color: textTheme.bodySmall?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return lang.thisFieldRequired;
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
                        lang.accountType,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang.chooseAccountTypeDesc,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RoleCard(
                              icon: Icons.person_outline,
                              label: lang.clientRole,
                              subtitle: lang.hireTechnicians,
                              isSelected: _selectedRole == 'client',
                              onTap: () => setState(() => _selectedRole = 'client'),
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RoleCard(
                              icon: Icons.build_outlined,
                              label: lang.workerRole,
                              subtitle: lang.provideServices,
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
                                  lang.workerVerificationNotice,
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
                              text: lang.completeProfileBtn,
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
    showDialog(
      context: context,
      builder: (_) => ExitProfileDialog(
        onLeave: () async {
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
      ),
    );
  }
}
