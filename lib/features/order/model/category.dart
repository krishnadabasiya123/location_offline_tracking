import 'package:equatable/equatable.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: int.tryParse(json['id']?.toString() ?? '-1') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  final int id;
  final String name;
  final String description;

  ProductCategory copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  @override
  String toString() {
    return '$id, $name, $description, ';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
  ];
}
