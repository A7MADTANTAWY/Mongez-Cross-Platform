import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mongez/features/auth/models/auth.dart';
import 'package:mongez/features/auth/repos/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  final AuthRepository authRepository;

  late Auth auth;

  void reset() {
    emit(AuthInitial());
  }

  Future<void> signInWithGoogle({required String idToken}) async {
    emit(AuthLoading());

    final result = await authRepository.signInWithGoogle(idToken: idToken);

    result.fold(
      (failure) => emit(AuthFailure(errorMessage: failure.errorMessage)),
      (auth) {
        this.auth = auth;
        emit(AuthAuthenticated(auth: auth));
      },
    );
  }

  Future<void> completeProfile({
    required String nameAr,
    required String phone,
    required String role,
    required String governorate,
    String city = "",
    String address = "",
    bool makeDefault = true,
    String email = "",
    Uint8List? profileImageBytes,
  }) async {
    emit(AuthLoading());

    final result = await authRepository.completeProfile(
      nameAr: nameAr,
      phone: phone,
      role: role,
      governorate: governorate,
      city: city,
      address: address,
      makeDefault: makeDefault,
      email: email,
      profileImageBytes: profileImageBytes,
    );

    result.fold(
      (failure) => emit(AuthFailure(errorMessage: failure.errorMessage)),
      (auth) {
        this.auth = auth;
        final vs = auth.verificationStatus;
        if (role == 'worker' && vs == 'pending') {
          emit(AuthPendingVerification(auth: auth));
        } else {
          emit(AuthProfileCompleted(auth: auth));
        }
      },
    );
  }

  Future<void> deleteIncompleteProfile() async {
    emit(AuthLoading());

    final result = await authRepository.deleteIncompleteProfile();

    result.fold(
      (failure) => emit(AuthFailure(errorMessage: failure.errorMessage)),
      (_) => emit(AuthAccountDeleted()),
    );
  }
}
