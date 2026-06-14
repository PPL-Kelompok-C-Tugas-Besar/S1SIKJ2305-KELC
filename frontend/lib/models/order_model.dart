class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      orderId: json['order_id'] is int ? json['order_id'] : int.parse(json['order_id'].toString()),
      productId: json['product_id'] is int ? json['product_id'] : int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String userId;
  final DateTime date;
  final double subtotal;
  final double discount;
  final String? voucherCode;
  final double total;
  final String status;
  final String? paymentMethod;
  final String? shippingAddress;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.date,
    required this.subtotal,
    this.discount = 0.0,
    this.voucherCode,
    required this.total,
    required this.status,
    this.paymentMethod,
    this.shippingAddress,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List?;
    List<OrderItem> orderItems = list != null
        ? list.map((i) => OrderItem.fromJson(i)).toList()
        : [];

    return Order(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
      subtotal: json['subtotal'] != null ? double.parse(json['subtotal'].toString()) : 0.0,
      discount: json['discount'] != null ? double.parse(json['discount'].toString()) : 0.0,
      voucherCode: json['voucher_code'],
      total: json['total'] != null ? double.parse(json['total'].toString()) : 0.0,
      status: json['status'] ?? 'Pending',
      paymentMethod: json['payment_method'],
      shippingAddress: json['shipping_address'],
      items: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'date': date.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'voucher_code': voucherCode,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
