class CanalEntity {
  final String id;
  final String reservaId;
  final String usuarioId;
  final String? userName;
  final String? userSpecialty;
  final String estado; // 'abierto', 'cerrado'
  final DateTime creadoEn;

  const CanalEntity({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    this.userName,
    this.userSpecialty,
    required this.estado,
    required this.creadoEn,
  });
}
