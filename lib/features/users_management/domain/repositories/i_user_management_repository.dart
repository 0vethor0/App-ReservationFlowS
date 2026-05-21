/// Repository interface for user management operations.
library;

import '../entities/admin_request_status_entity.dart';
import '../entities/pending_user_entity.dart';

abstract class IUserManagementRepository {
  Future<List<PendingUserEntity>> getPendingUsers();

  Future<void> approveUser(String userId);

  Future<void> rejectUser(String userId);

  Stream<List<PendingUserEntity>> watchPendingUsers();

  Future<void> submitAdminRequest(String userId);

  Future<AdminRequestStatusEntity> getAdminRequestStatus(String userId);

  Stream<AdminRequestStatusEntity> watchAdminRequestStatus(String userId);

  Future<void> approveAdminPromotion(String userId);

  Future<void> rejectAdminPromotion(String userId);

  void disposeRealtime();
}
