
/// Este widget muestra una tarjeta con la informacion de un usuario pendiente de aprobacion.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pending_user_entity.dart';

class UserApprovalCard extends StatefulWidget {
  const UserApprovalCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  final PendingUserEntity user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  State<UserApprovalCard> createState() => _UserApprovalCardState();
}

class _UserApprovalCardState extends State<UserApprovalCard> {
  bool _isProcessing = false;

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    widget.onApprove();
    // Small delay to show loading state
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isProcessing = true);
    widget.onReject();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isProcessing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Se ha registrado un nuevo usuario en la app.',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Avatar and User Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Vertically center avatar
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: widget.user.avatarUrl != null &&
                                widget.user.avatarUrl!.isNotEmpty
                            ? NetworkImage(widget.user.avatarUrl!)
                            : null,
                        child: widget.user.avatarUrl == null ||
                                widget.user.avatarUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 35,
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.fullName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (widget.user.especialidad != null &&
                                widget.user.especialidad!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.user.especialidad!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            if (widget.user.carrera != null &&
                                widget.user.carrera!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.user.carrera!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleApprove,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleReject,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Declinar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
