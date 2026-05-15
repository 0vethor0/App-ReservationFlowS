/// Implementation of StorageRepository.
///
/// Bridges the domain layer with the data source.
library;

import 'dart:io';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_remote_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource dataSource;

  StorageRepositoryImpl(this.dataSource);

  @override
  Future<String> uploadProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    return await dataSource.uploadProfilePhoto(
      userId: userId,
      photoFile: photoFile,
    );
  }

  @override
  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    await dataSource.deleteFile(
      bucket: bucket,
      filePath: filePath,
    );
  }
}
