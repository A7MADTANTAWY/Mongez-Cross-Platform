import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/features/shared/profile/data/models/profile_model.dart';
import 'package:mongez/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/widgets/custom_app_bar.dart';
import 'package:mongez/features/client/address/presentation/screens/addresses_screen.dart';

/// Real edit-profile screen, wired to PATCH /api/users/me/.
///
/// Loads the current profile from the [ProfileCubit] (which is already
/// kicked off at app boot) and hands the user a form covering the
/// editable fields:
///   • display name (name_ar)
///   • phone
///   • email (read-only — shown as registered with Google)
/// The avatar is view-only (comes from Google / uploaded image) and
/// saved addresses live in a separate My Addresses screen.
///
/// On submit it calls `ProfileCubit.updateProfile(...)`; success
/// pops back with a green snackbar, failure shows the backend error
/// inline so the user can fix it.
class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  // Captured in didChangeDependencies so dispose() doesn't have to
  // touch `context` (back-pop crash defense).
  ProfileCubit? _profileCubit;

  // The BlocConsumer.listener fires on every state change. Without
  // these flags, a silent ProfileCubit re-emit (e.g. from
  // NavigationService._fetchFreshData) would pop the screen
  // unexpectedly while the user was still editing — which previously
  // looked like a freeze when pressing back.
  bool _saving = false;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.nameAr ?? '');
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _emailCtrl = TextEditingController(text: widget.profile.email ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileCubit ??= context.read<ProfileCubit>();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = _profileCubit;
    if (cubit == null) return;
    setState(() => _saving = true);
    cubit.updateProfile(
      nameAr: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return BlocConsumer<ProfileCubit, ProfileState>(
      // Only react when the change came from OUR Save click. Other
      // parts of the app silently refresh the profile (e.g.
      // NavigationService._fetchFreshData) and we don't want a
      // background ProfileSuccess to pop the screen while the user
      // is mid-edit — that previously looked like a back-button
      // freeze because the screen popped itself out from under the
      // user.
      listenWhen: (previous, current) => _saving,
      listener: (ctx, state) {
        if (state is ProfileSuccess && !_popped && mounted) {
          _popped = true;
          // Pop first; show the snack via the *parent* messenger so
          // it isn't tied to this Scaffold's disposed state.
          final messenger = ScaffoldMessenger.maybeOf(ctx);
          Navigator.of(ctx).maybePop();
          messenger?.showSnackBar(
            SnackBar(
              content: Text(lang.profileUpdated),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProfileFailure) {
          if (!mounted) return;
          setState(() => _saving = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (ctx, state) {
        // Only show the spinner when this screen kicked off the work.
        final loading = _saving && state is ProfileLoading;
        return Scaffold(
          appBar: CustomAppBar(title: lang.editProfile),
          body: AbsorbPointer(
            absorbing: loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withValues(alpha: 0.1),
                        ),
                        // Foreground border so the photo fills the
                        // circle edge-to-edge (a decoration border
                        // pads the child and leaves a ring).
                        foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.profile.profileImage != null
                            ? AppNetworkImage(
                                imageUrl: widget.profile.profileImage!,
                                fit: BoxFit.cover,
                                cacheWidth: 120,
                                errorWidget: (_, _, _) => Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: cs.primary,
                                ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: cs.primary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(lang.personal, style: tt.titleSmall),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: lang.fullName,
                        hintText: lang.fullNameHint,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? lang.pleaseEnterYourName
                              : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: lang.phoneNumber,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return lang.pleaseEnterPhone;
                        if (s.length < 10) return lang.phoneTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailCtrl,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: lang.emailOptional,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(lang.addresses, style: tt.titleSmall),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressPage(),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(lang.addressesDesc),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 28),

                    FilledButton.icon(
                      onPressed: loading ? null : _onSubmit,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(loading ? lang.saving : lang.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
