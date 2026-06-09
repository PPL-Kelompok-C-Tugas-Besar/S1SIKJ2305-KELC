  import 'package:flutter_test/flutter_test.dart';
  import 'package:gymbro/logic/quantity_logic.dart';

  /// =====================================================
  /// BVA (Boundary Value Analysis) - Detail Produk
  /// =====================================================
  ///
  /// Asumsi: produk memiliki stok = 10
  ///
  /// Kelas boundary yang diuji:
  /// - Increment (tambah quantity):
  ///     min-1 : quantity = 0  → tidak valid (tidak mungkin terjadi, quantity awal = 1)
  ///     min   : quantity = 1  → valid, bisa increment
  ///     normal: quantity = 5  → valid, bisa increment (stock mencukupi)
  ///     max   : quantity = 10 → sudah di batas stok, tidak bisa increment lagi
  ///     max+1 : quantity = 11 → melebihi stok, increment gagal
  ///
  /// - Decrement (kurang quantity):
  ///     min   : quantity = 1  → tidak bisa dikurangi lagi
  ///     normal: quantity = 5  → bisa dikurangi
  ///     max   : quantity = 10 → bisa dikurangi
  /// =====================================================

  void main() {
    const int stock = 10;

    group('BVA - QuantityLogic Increment (tambah item)', () {
      test('[TC-01] Increment dari quantity 1 (nilai minimum) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 1);
        final result = logic.increment();
        expect(result, true);
        expect(logic.quantity, 2);
      });

      test('[TC-02] Increment dari quantity 5 (nilai normal, stok mencukupi) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 5);
        final result = logic.increment();
        expect(result, true);
        expect(logic.quantity, 6);
      });

      test('[TC-03] Increment dari quantity 9 (tepat di bawah batas stok) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 9);
        final result = logic.increment();
        expect(result, true);
        expect(logic.quantity, 10);
      });

      test('[TC-04] Increment dari quantity 10 (tepat di batas stok/max) → harus GAGAL', () {
        final logic = QuantityLogic(stock: stock, quantity: 10);
        final result = logic.increment();
        expect(result, false);
        expect(logic.quantity, 10); // quantity tidak berubah
      });

      test('[TC-05] Increment dari quantity 11 (melebihi stok gudang) → harus GAGAL', () {
        final logic = QuantityLogic(stock: stock, quantity: 11);
        final result = logic.increment();
        expect(result, false);
        expect(logic.quantity, 11); // quantity tidak berubah
      });
    });

    group('BVA - QuantityLogic Decrement (kurang item)', () {
      test('[TC-06] Decrement dari quantity 1 (nilai minimum) → harus GAGAL (minimal 1)', () {
        final logic = QuantityLogic(stock: stock, quantity: 1);
        final result = logic.decrement();
        expect(result, false);
        expect(logic.quantity, 1); // quantity tidak berubah
      });

      test('[TC-07] Decrement dari quantity 2 (tepat di atas minimum) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 2);
        final result = logic.decrement();
        expect(result, true);
        expect(logic.quantity, 1);
      });

      test('[TC-08] Decrement dari quantity 5 (nilai normal) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 5);
        final result = logic.decrement();
        expect(result, true);
        expect(logic.quantity, 4);
      });

      test('[TC-09] Decrement dari quantity 10 (nilai maksimum stok) → harus berhasil', () {
        final logic = QuantityLogic(stock: stock, quantity: 10);
        final result = logic.decrement();
        expect(result, true);
        expect(logic.quantity, 9);
      });
    });

    group('BVA - Skenario penuh Add to Cart', () {
      test('[TC-10] User pilih 1 item (min valid) → quantity = 1, siap di-cart', () {
        final logic = QuantityLogic(stock: stock, quantity: 1);
        expect(logic.quantity, 1);
        expect(logic.quantity <= stock, true);
      });

      test('[TC-11] User pilih 5 item (nilai tengah, stok mencukupi) → quantity = 5, siap di-cart', () {
        final logic = QuantityLogic(stock: stock, quantity: 5);
        expect(logic.quantity, 5);
        expect(logic.quantity <= stock, true);
      });

      test('[TC-12] User coba pilih 11 item (melebihi stok 10) → increment dari 10 gagal, quantity tetap 10', () {
        final logic = QuantityLogic(stock: stock, quantity: 10);

        
        final result = logic.increment();

        
        expect(result, false);
        expect(logic.quantity, 10);
        expect(logic.quantity > stock, false); 
      });
    });
  }
