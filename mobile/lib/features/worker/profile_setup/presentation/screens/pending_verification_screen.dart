import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongez/features/auth/bloc/auth_cubit.dart';
import 'package:mongez/features/auth/models/auth.dart';
import 'package:mongez/features/auth/screens/google_sign_in_screen.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/widgets/logo.dart';

class PendingVerificationScreen extends StatelessWidget {
  final Auth auth;

  const PendingVerificationScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final isRejected = auth.user?.verificationStatus == 'rejected';
                    final rejectionReason = auth.user?.rejectionReason ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {},
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Logo(),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isRejected
                        ? cs.error.withValues(alpha: 0.1)
                        : Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected ? Icons.block_outlined : Icons.hourglass_top_outlined,
                    size: 64,
                    color: isRejected ? cs.error : Colors.amber[700],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isRejected ? lang.accountNotApproved : lang.accountUnderReview,
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isRejected
                      ? lang.registrationRejected
                      : lang.registrationUnderReview,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                if (isRejected && rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.reason,
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rejectionReason,
                          style: tt.bodyMedium?.copyWith(color: cs.error),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await GoogleSignIn().signOut();
                      } catch (e) {
                        debugPrint('[LOGOUT] Google signOut failed: $e');
                      }
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
                    icon: const Icon(Icons.logout),
                    label: Text(
                      lang.logout,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
