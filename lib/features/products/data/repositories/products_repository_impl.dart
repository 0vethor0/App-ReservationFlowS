library;

import '../../domain/repositories/i_products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements IProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _remoteDataSource.getProducts();
  }

  @override
  Future<void> createProduct(Map<String, dynamic> data) async {
    await _remoteDataSource.createProduct(data);
  }

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateProduct(id, data);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }
}
