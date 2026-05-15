/// Local Storage Service for managing files on device.
///
/// Provides methods for:
/// - Requesting storage permissions
/// - Saving images to persistent local storage
/// - Managing temporary and document directories
/// - Cleaning up cached files
library;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Directory names for organized storage
  static const String _profilePhotosDir = 'profile_photos';
  static const String _tempDir = 'temp';

  // ============================================
  /// PERMISSIONS MANAGEMENT
  // ============================================

  /// Request camera and storage permissions
  /// Returns true if all permissions are granted
  Future<bool> requestStoragePermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    // Check if all required permissions are granted
    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    
    // For Android 13+, we need photos permission
    // For older versions, storage permission is enough
    final storageGranted = Platform.isAndroid
        ? (await Permission.photos.status).isGranted ||
            (await Permission.storage.status).isGranted
        : true;

    return cameraGranted && storageGranted;
  }

  /// Check if storage permissions are already granted
  Future<bool> hasStoragePermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) uses photos permission
      if (await Permission.photos.isGranted) return true;
      // Older Android versions use storage permission
      if (await Permission.storage.isGranted) return true;
      return false;
    }
    // iOS and other platforms
    return await Permission.photos.isGranted;
  }

  /// Open app settings if permissions are denied
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // ============================================
  /// DIRECTORY MANAGEMENT
  // ============================================

  /// Get the profile photos directory (persistent)
  /// Files here persist until app is uninstalled
  Future<Directory> getProfilePhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final profilePhotosDir = Directory('${appDir.path}/$_profilePhotosDir');

    if (!await profilePhotosDir.exists()) {
      await profilePhotosDir.create(recursive: true);
    }

    return profilePhotosDir;
  }

  /// Get temporary directory for cache
  /// System may delete these files when space is low
  Future<Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final appTempDir = Directory('${tempDir.path}/$_tempDir');

    if (!await appTempDir.exists()) {
      await appTempDir.create(recursive: true);
    }

    return appTempDir;
  }

  // ============================================
  /// FILE OPERATIONS
  // ============================================

  /// Save image to persistent local storage
  /// Returns the file path of the saved image
  Future<File> saveImageLocally({
    required File sourceFile,
    required String fileName,
  }) async {
    final directory = await getProfilePhotosDirectory();
    final targetPath = '${directory.path}/$fileName';

    // Copy file to persistent storage
    final savedFile = await sourceFile.copy(targetPath);
    return savedFile;
  }

  /// Save image to temporary directory (cache)
  /// Returns the file path of the saved image
  Future<File> saveImageToTemp({
    required File sourceFile,
    required String fileName,
  }) async {
    final directory = await getTempDirectory();
    final targetPath = '${directory.path}/$fileName';

    final savedFile = await sourceFile.copy(targetPath);
    return savedFile;
  }

  /// Delete image from local storage
  Future<void> deleteImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clear all temporary files
  Future<void> clearTempDirectory() async {
    final directory = await getTempDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
    }
  }

  /// Clear all profile photos from local storage
  Future<void> clearProfilePhotosDirectory() async {
    final directory = await getProfilePhotosDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// Get file from path
  File? getFile(String filePath) {
    final file = File(filePath);
    return file.existsSync() ? file : null;
  }

  // ============================================
  /// HELPER METHODS
  // ============================================

  /// Generate unique filename for profile photo
  String generateProfilePhotoFileName(String userId) {
    return 'profile_${userId}.jpg';
  }

  /// Generate unique filename for temporary image
  String generateTempFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'temp_$timestamp.jpg';
  }

  /// Get storage usage statistics
  Future<Map<String, int>> getStorageStats() async {
    final profileDir = await getProfilePhotosDirectory();
    final tempDir = await getTempDirectory();

    int profileSize = 0;
    int tempSize = 0;
    int profileCount = 0;
    int tempCount = 0;

    // Calculate profile photos size
    if (await profileDir.exists()) {
      final files = profileDir.listSync();
      profileCount = files.length;
      for (final file in files) {
        if (file is File) {
          profileSize += file.lengthSync();
        }
      }
    }

    // Calculate temp files size
    if (await tempDir.exists()) {
      final files = tempDir.listSync();
      tempCount = files.length;
      for (final file in files) {
        if (file is File) {
          tempSize += file.lengthSync();
        }
      }
    }

    return {
      'profilePhotosCount': profileCount,
      'profilePhotosSize': profileSize,
      'tempFilesCount': tempCount,
      'tempFilesSize': tempSize,
    };
  }
}
