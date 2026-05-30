import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/canal_model.dart';
import '../models/mensaje_model.dart';

class MessagingRemoteDataSource {
  final SupabaseClient _supabase;

  MessagingRemoteDataSource(this._supabase);

  Future<CanalModel> getOrCreateCanal(String reservaId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    // 1. Intentar buscar canal existente
    final existing = await _supabase
        .from('canales_reserva')
        .select('*, perfiles(*)')
        .eq('reserva_id', reservaId)
        .maybeSingle();

    if (existing != null) {
      return CanalModel.fromMap(existing);
    }

    // 2. Crear si no existe. 
    final reserva = await _supabase.from('reservas').select('id_usuario').eq('id', reservaId).single();
    final ownerId = reserva['id_usuario'] as String;

    final inserted = await _supabase.from('canales_reserva').insert({
      'reserva_id': reservaId,
      'usuario_id': ownerId,
      'estado': 'abierto',
    }).select('*, perfiles(*)').single();

    return CanalModel.fromMap(inserted);
  }

  Future<List<CanalModel>> getActiveCanales() async {
    final res = await _supabase
        .from('canales_reserva')
        .select('*, perfiles(*)')
        .eq('estado', 'abierto')
        .order('creado_en', ascending: false);
    
    return res.map((m) => CanalModel.fromMap(m)).toList();
  }

  Stream<List<MensajeModel>> getMensajesStream(String canalId) {
    return _supabase
        .from('mensajes')
        .stream(primaryKey: ['id'])
        .eq('canal_id', canalId)
        .order('creado_en', ascending: true)
        .map((list) => list.map((m) => MensajeModel.fromMap(m)).toList());
  }

  Future<String?> uploadEvidence(File imagen) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imagen.path)}';
    final path = '$userId/$fileName';

    await _supabase.storage.from('evidencias_reserva').upload(path, imagen);
    return _supabase.storage.from('evidencias_reserva').getPublicUrl(path);
  }

  Future<void> enviarMensaje({
    required String canalId,
    String? texto,
    File? imagen,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    String? imageUrl;
    if (imagen != null) {
      imageUrl = await uploadEvidence(imagen);
    }

    if (texto == null && imageUrl == null) return;

    final data = <String, dynamic>{
      'canal_id': canalId,
      'remitente_id': userId,
    };
    if (texto != null) data['texto'] = texto;
    if (imageUrl != null) data['archivo_url'] = imageUrl;

    await _supabase.from('mensajes').insert(data);
  }
}
