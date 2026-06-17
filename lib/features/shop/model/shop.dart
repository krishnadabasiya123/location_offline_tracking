
import 'package:omkar_sale/core/app/all_import_file.dart';

class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.tin,
    required this.contactPerson,
    required this.contactPhone,
    required this.products,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: int.tryParse(json['id']?.toString() ?? '-1') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      tin: json['tin']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      products: json['products'] == null ? [] : List<Product>.from((json['products'] as List? ?? []).map((x) => Product.fromJson(x as Map<String, dynamic>))),
    );
  }

  final int id;
  final String uuid;
  final String name;
  final String address;
  final String city;
  final String latitude;
  final String longitude;
  final String tin;
  final String contactPerson;
  final String contactPhone;
  final List<Product> products;

  Shop copyWith({
    int? id,
    String? uuid,
    String? name,
    String? address,
    String? city,
    String? latitude,
    String? longitude,
    String? tin,
    String? contactPerson,
    String? contactPhone,
    List<Product>? products,
  }) {
    return Shop(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tin: tin ?? this.tin,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'name': name,
    'address': address,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'tin': tin,
    'contact_person': contactPerson,
    'contact_phone': contactPhone,
    'products': products.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return '$id, $uuid, $name, $address, $city, $latitude, $longitude, $tin, $contactPerson, $contactPhone, $products, ';
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    address,
    city,
    latitude,
    longitude,
    tin,
    contactPerson,
    contactPhone,
    products,
  ];
}
