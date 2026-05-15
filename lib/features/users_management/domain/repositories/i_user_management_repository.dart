/// Repository interface for user management operations.
///
/// Defines the contract for admin user approval workflows.
library;

import '../entities/pending_user_entity.dart';

abstract class IUserManagementRepository {
  /// Get list of users pending approval
  Future<List<PendingUserEntity>> getPendingUsers();

  /// Approve a user's registration
  Future<void> approveUser(String userId);

  /// Reject a user's registration
  Future<void> rejectUser(String userId);

  /// Watch for changes in pending users list in real-time
  Stream<List<PendingUserEntity>> watchPendingUsers();
}

