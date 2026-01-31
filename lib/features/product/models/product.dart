import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final String? thumbnail;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
    this.thumbnail,
  });

  bool get isInStock => stock > 0;
  String get stockStatus => isInStock ? 'In stock' : 'Out of stock';

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? description,
    String? thumbnail,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'thumbnail': thumbnail,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, category, price, stock];
}
