library;

import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsRemoteDataSource {
  final SupabaseClient _client;

  ProductsRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _client
        .from('productos')
        .select()
        .order('fecha_registro', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _client.from('productos').insert(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _client.from('productos').update(data).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('productos').delete().eq('id', id);
  }
}
