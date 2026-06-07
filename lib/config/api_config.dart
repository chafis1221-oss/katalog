class ApiConfig {
  // Base URL Panel Bagus (API + Database)
  static const String baseUrl = 'http://38.49.208.80:5921';

  // Base URL Panel Jelek (Image Storage)
  static const String imageBaseUrl = 'http://38.46.223.56:5667';

  // Upload gambar langsung ke Panel Jelek
  static const String uploadImageUrl = '$imageBaseUrl/api/upload';

  // Panel Bagus endpoints
  static const String productsUrl = '$baseUrl/api/products';
  static const String searchProductsUrl = '$baseUrl/api/products/search';
  static const String validateCartUrl = '$baseUrl/api/cart/validate';
  static const String healthUrl = '$baseUrl/';

  // Timeout HTTP request (detik)
  static const int requestTimeout = 15;
}