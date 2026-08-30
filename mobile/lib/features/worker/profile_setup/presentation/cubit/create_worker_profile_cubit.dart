import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mongez/features/shared/workers/data/models/worker_model.dart';
import 'package:mongez/features/shared/workers/domain/worker_repository.dart';

part 'create_worker_profile_state.dart';

class CreateWorkerProfileCubit extends Cubit<CreateWorkerProfileState> {
  CreateWorkerProfileCubit({required this.workerRepository})
      : super(CreateWorkerProfileInitial());

  final WorkerRepository workerRepository;

  void reset() {
    emit(CreateWorkerProfileInitial());
  }

  Future<void> createProfile({
    int? categoryId,
    required int experienceYears,
    required bool isAvailable,
    String description = '',
  }) async {
    emit(CreateWorkerProfileLoading());
    final result = await workerRepository.createWorkerProfile(
      categoryId: categoryId,
      experienceYears: experienceYears,
      isAvailable: isAvailable,
      description: description,
    );
    result.fold(
      (failure) => emit(
        CreateWorkerProfileFailure(errorMessage: failure.errorMessage),
      ),
      (profile) => emit(CreateWorkerProfileSuccess(profile: profile)),
    );
  }

  /// Loads the caller's existing worker profile so the edit-service
  /// form can pre-fill it.
  Future<void> loadProfile() async {
    emit(const CreateWorkerProfileFetchLoading());
    final result = await workerRepository.getMyProfile();
    result.fold(
      (failure) => emit(
        CreateWorkerProfileFailure(errorMessage: failure.errorMessage),
      ),
      (profile) => emit(CreateWorkerProfileFetchLoaded(profile: profile)),
    );
  }

  /// PATCHes the existing service. Only non-null fields are sent, so
  /// untouched parts of the form stay as they are server-side.
  Future<void> updateProfile({
    int? categoryId,
    int? experienceYears,
    bool? isAvailable,
    String? description,
  }) async {
    emit(CreateWorkerProfileLoading());
    final result = await workerRepository.updateWorkerProfile(
      categoryId: categoryId,
      experienceYears: experienceYears,
      isAvailable: isAvailable,
      description: description,
    );
    result.fold(
      (failure) => emit(
        CreateWorkerProfileFailure(errorMessage: failure.errorMessage),
      ),
      (profile) => emit(CreateWorkerProfileSuccess(profile: profile)),
    );
  }
}
