/// Storage remote datasource for handling file uploads.
///
/// Manages all Supabase Storage operations.
library;

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRemoteDataSource {
  final SupabaseClient client;

  StorageRemoteDataSource(this.client);

  /// Upload a file to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadFile({
    required String bucket,
    required String filePath,
    required File file,
  }) async {
    await client.storage
        .from(bucket)
        .upload(filePath, file);

    return client.storage
        .from(bucket)
        .getPublicUrl(filePath);
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    await client.storage
        .from(bucket)
        .remove([filePath]);
  }

  /// Upload profile photo with deterministic filename
  /// This prevents duplicate uploads - only one file per user
  Future<String> uploadProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    // Use a fixed filename based on userId to prevent duplicates
    final fileName = 'avatar.jpg';
    final filePath = '$userId/$fileName';

    // Try to delete existing file first (if any)
    try {
      await deleteFile(
        bucket: 'profile-photos',
        filePath: filePath,
      );
    } catch (_) {
      // File might not exist, ignore error
    }

    // Upload the new file
    return await uploadFile(
      bucket: 'profile-photos',
      filePath: filePath,
      file: photoFile,
    );
  }
}
