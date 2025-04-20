class CartItem {

  final int? productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? weight;

  CartItem({
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.weight,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (weight != null) 'weight': weight,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as int?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
      weight: json['weight'] as String?,
    );
  }
}
