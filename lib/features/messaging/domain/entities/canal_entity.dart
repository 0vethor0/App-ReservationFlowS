class CanalEntity {
  final String id;
  final String reservaId;
  final String usuarioId;
  final String estado; // 'abierto', 'cerrado'
  final DateTime creadoEn;

  const CanalEntity({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.estado,
    required this.creadoEn,
  });
}
