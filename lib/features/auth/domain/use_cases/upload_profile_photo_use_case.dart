/// Use case for uploading profile photo.
///
/// Handles the business logic for profile photo uploads.
library;

import 'dart:io';
import '../../domain/repositories/storage_repository.dart';

class UploadProfilePhotoUseCase {
  final StorageRepository repository;

  UploadProfilePhotoUseCase(this.repository);

  /// Execute the upload
  /// Returns the public URL of the uploaded photo
  Future<String> execute({
    required String userId,
    required File photoFile,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    if (!photoFile.existsSync()) {
      throw Exception('Photo file does not exist');
    }

    // Validate file size (2MB max)
    final fileSize = photoFile.lengthSync();
    if (fileSize > 2 * 1024 * 1024) {
      throw Exception('Photo file size exceeds 2MB limit');
    }

    return await repository.uploadProfilePhoto(
      userId: userId,
      photoFile: photoFile,
    );
  }
}
