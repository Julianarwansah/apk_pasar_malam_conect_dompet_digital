import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/core/constants/api_constants.dart';
import 'package:pasar_malam/core/services/dio_client.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  /// Fetch products — token otomatis disertakan oleh DioClient interceptor
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);

      // Backend response: { "data": [ {...}, {...} ] }
      final List<dynamic> data = response.data['data'];
      _products = data.map((e) => ProductModel.fromJson(e)).toList();
      _status = ProductStatus.loaded;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
          '[PRODUCT] Endpoint produk belum tersedia, memakai katalog lokal.',
        );
        _products = _localProducts;
        _status = ProductStatus.loaded;
      } else {
        _error = _readErrorMessage(e.response?.data) ?? 'Gagal memuat produk';
        _status = ProductStatus.error;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _status = ProductStatus.error;
    }

    notifyListeners();
  }

  String? _readErrorMessage(Object? data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }

  static const List<ProductModel> _localProducts = [
    ProductModel(
      id: 1,
      name: 'Running Shoes Blue',
      description: 'Sepatu running ringan untuk latihan harian.',
      price: 299000,
      stock: 20,
      category: 'Running',
      imageUrl: '',
      isActive: true,
    ),
    ProductModel(
      id: 2,
      name: 'Lifestyle Sneakers',
      description: 'Sneakers kasual untuk aktivitas sehari-hari.',
      price: 349000,
      stock: 14,
      category: 'Lifestyle',
      imageUrl: '',
      isActive: true,
    ),
    ProductModel(
      id: 3,
      name: 'Football Boots',
      description: 'Sepatu bola dengan grip kuat untuk lapangan rumput.',
      price: 429000,
      stock: 9,
      category: 'Football',
      imageUrl: '',
      isActive: true,
    ),
    ProductModel(
      id: 4,
      name: 'Training Jersey',
      description: 'Jersey breathable untuk olahraga dan latihan.',
      price: 159000,
      stock: 30,
      category: 'Lifestyle',
      imageUrl: '',
      isActive: true,
    ),
  ];
}
