import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongez/core/constants/api_constants.dart';
import 'package:mongez/features/auth/bloc/auth_cubit.dart';
import 'package:mongez/features/auth/screens/complete_profile_screen.dart';
import 'package:mongez/features/auth/screens/pending_verification_screen.dart';
import 'package:mongez/services/navigation_service.dart';
import 'package:mongez/widgets/logo.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    final webClientId = ApiConstants.googleClientId;
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: kIsWeb && webClientId.isNotEmpty ? webClientId : null,
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final profileCompleted = state.auth.profileCompleted ?? false;
          final verificationStatus = state.auth.verificationStatus ?? 'verified';

          if (!profileCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CompleteProfileScreen(auth: state.auth),
              ),
            );
          } else if (verificationStatus == 'pending' || verificationStatus == 'rejected') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => PendingVerificationScreen(auth: state.auth),
              ),
              (route) => false,
            );
          } else {
            NavigationService.toMainScreen(context, state.auth);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const Logo(),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Mongez',
                    textAlign: TextAlign.center,
                    style: tt.displayMedium?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  state is AuthLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleGoogleSignIn(context),
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return;

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken != null && mounted) {
        context.read<AuthCubit>().signInWithGoogle(idToken: idToken);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
