library;

abstract class IProductsRepository {
  Future<List<Map<String, dynamic>>> getProducts();
  Future<void> createProduct(Map<String, dynamic> data);
  Future<void> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
}
