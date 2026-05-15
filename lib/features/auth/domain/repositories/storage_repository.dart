/// Repository interface for storage operations.
///
/// Defines the contract for file storage operations.
library;

import 'dart:io';

abstract class StorageRepository {
  /// Upload a profile photo to storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadProfilePhoto({
    required String userId,
    required File photoFile,
  });

  /// Delete a file from storage
  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  });
}
