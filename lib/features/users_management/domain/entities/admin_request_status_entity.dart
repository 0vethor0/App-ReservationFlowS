/// Estado de la solicitud de administrador del usuario actual.
library;

enum AdminRequestUiState {
  canRequest,
  pending,
  rejected,
  alreadyAdmin,
}

class AdminRequestStatusEntity {
  const AdminRequestStatusEntity({
    required this.uiState,
    this.solicitaAdmin = false,
    this.solicitudRechazada = false,
  });

  final AdminRequestUiState uiState;
  final bool solicitaAdmin;
  final bool solicitudRechazada;
}
