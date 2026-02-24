class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final double? buyingPrice; // Cost price for profit calculation
  final List<String> images;
  final List<String> videos;
  final List<String> sizes;
  final List<String> colors;
  final int stockQuantity;
  final double? offerPrice;
  final String imageUrl;
  final double rating;
  final bool isTrending;
  final int orderCount;
  final int reviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    this.buyingPrice,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0, // Added
    this.isTrending = false,
    this.orderCount = 0,
    this.images = const [],
    this.videos = const [],
    this.sizes = const [],
    this.colors = const [],
    this.stockQuantity = 0,
    this.offerPrice,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      buyingPrice: data['buyingPrice'] != null ? (data['buyingPrice']).toDouble() : null,
      offerPrice: data['offerPrice'] != null ? (data['offerPrice']).toDouble() : null,
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0, // Added
      isTrending: data['isTrending'] ?? false,
      orderCount: data['orderCount'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      stockQuantity: data['stockQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'buyingPrice': buyingPrice,
      'offerPrice': offerPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount, // Added
      'isTrending': isTrending,
      'orderCount': orderCount,
      'images': images,
      'videos': videos,
      'sizes': sizes,
      'colors': colors,
      'stockQuantity': stockQuantity,
    };
  }
}
