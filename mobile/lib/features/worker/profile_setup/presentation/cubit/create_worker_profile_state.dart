part of 'create_worker_profile_cubit.dart';

@immutable
sealed class CreateWorkerProfileState {
  const CreateWorkerProfileState();
}

final class CreateWorkerProfileInitial extends CreateWorkerProfileState {
  const CreateWorkerProfileInitial();
}

final class CreateWorkerProfileLoading extends CreateWorkerProfileState {
  const CreateWorkerProfileLoading();
}

final class CreateWorkerProfileSuccess extends CreateWorkerProfileState {
  final WorkerModel profile;
  const CreateWorkerProfileSuccess({required this.profile});
}

final class CreateWorkerProfileFailure extends CreateWorkerProfileState {
  final String errorMessage;
  const CreateWorkerProfileFailure({required this.errorMessage});
}

/// Emitted while `GET /workers/me/` is being fetched to pre-fill the
/// edit-service form.
final class CreateWorkerProfileFetchLoading extends CreateWorkerProfileState {
  const CreateWorkerProfileFetchLoading();
}

/// The worker's existing profile, ready to pre-fill the form.
final class CreateWorkerProfileFetchLoaded extends CreateWorkerProfileState {
  final WorkerModel profile;
  const CreateWorkerProfileFetchLoaded({required this.profile});
}
