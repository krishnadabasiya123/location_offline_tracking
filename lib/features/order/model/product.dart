import 'package:omkar_sale/core/app/all_import_file.dart';

class Product extends Equatable {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id']?.toString() ?? '-1') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString() ?? '',
      category: ProductCategory.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    );
  }

  final int id;
  final String name;
  final String description;
  final String price;
  final String image;
  int quantity;
  final ProductCategory category;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? price,
    String? image,
    int? quantity,
    ProductCategory? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'quantity': quantity,
    'price': price,
    'image': image,
    'ProductCategory': category.toJson(),
  };

  @override
  String toString() {
    return ' Product(id: $id, name: $name, description: $description, price: $price, image: $image, category: $category, quantity: $quantity)';
  }
  //,

  @override
  List<Object?> get props => [id, name, description, price, quantity, image, category];
}
