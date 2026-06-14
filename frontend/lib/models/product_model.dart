class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;
  final int? weightGrams;
  final double averageRating;
  final int totalReviews;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.imageUrl,
    this.weightGrams,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] is double ? json['price'] : double.parse(json['price'].toString()),
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      category: json['category'],
      imageUrl: json['image_url'],
      weightGrams: json['weight_grams'] != null ? (json['weight_grams'] is int ? json['weight_grams'] : int.parse(json['weight_grams'].toString())) : null,
      averageRating: json['average_rating'] != null ? double.parse(json['average_rating'].toString()) : 0.0,
      totalReviews: json['total_reviews'] != null ? int.parse(json['total_reviews'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'weight_grams': weightGrams,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
