/// Kelas murni (tidak bergantung pada Flutter/Widget) yang merepresentasikan
/// logika pemilihan jumlah (quantity) produk pada halaman detail produk.
///
/// Dipisahkan dari widget agar bisa diuji dengan unit test.
class QuantityLogic {
  int quantity;
  final int stock;

  QuantityLogic({required this.stock, this.quantity = 1});

  /// Mengembalikan true jika berhasil increment.
  /// Mengembalikan false jika quantity sudah mencapai batas stok.
  bool increment() {
    if (quantity < stock) {
      quantity++;
      return true;
    }
    return false; // sudah di batas stok
  }

  /// Mengembalikan true jika berhasil decrement.
  /// Mengembalikan false jika quantity sudah 1 (minimum).
  bool decrement() {
    if (quantity > 1) {
      quantity--;
      return true;
    }
    return false; // sudah di batas minimum
  }
}
