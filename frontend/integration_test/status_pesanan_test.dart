// =============================================================================
// SCENARIO ID : TS.SP-1
// Scenario    : Status Pesanan - Melihat & Perubahan Status
// Test Cases  : TC.SP-1.001 s/d TC.SP-1.005
// Feature     : Status badge pada order card dan Detail Transaksi
// Type        : Integration Test (FT - Functional Test)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Mock Widget: Simulasi tampilan status pesanan tanpa bergantung ke backend.
// Status disimulasikan melalui parameter 'status' yang bisa diubah.
// ---------------------------------------------------------------------------

class _OrderStatusPage extends StatefulWidget {
  final String initialStatus;
  const _OrderStatusPage({required this.initialStatus});

  @override
  State<_OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<_OrderStatusPage> {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);

  late String currentStatus;

  static const List<String> _allStatuses = [
    'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.initialStatus;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':      return Colors.orangeAccent;
      case 'Diproses':     return Colors.blueAccent;
      case 'Dikirim':      return accentColor;
      case 'Selesai':      return accentColor;
      case 'Dibatalkan':   return Colors.redAccent;
      default:             return textSecondary;
    }
  }

  String _formatRupiah(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  void _showOrderStatusTrackerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final status = currentStatus;
        const orderDate = '2026-06-13';

        final isPending = status == 'Pending';
        final isDiproses = status == 'Diproses';
        final isDikirim = status == 'Dikirim';
        final isSelesai = status == 'Selesai';
        final isDibatalkan = status == 'Dibatalkan';

        const trackingNumber = 'GBR-20240999-EXP';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'STATUS PENGIRIMAN',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: textSecondary),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'INV-20240999',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              if (isDibatalkan) ...[
                _buildTimelineStep(
                  title: 'Order Dibuat',
                  description: 'Pesanan berhasil dibuat.',
                  time: orderDate,
                  isActive: false,
                  isCompleted: true,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Dibatalkan',
                  description: 'Pesanan telah dibatalkan oleh pengguna atau sistem.',
                  time: '',
                  isActive: true,
                  isCompleted: false,
                  isLast: true,
                  activeColor: Colors.redAccent,
                ),
              ] else ...[
                _buildTimelineStep(
                  title: 'Order Dibuat',
                  description: 'Pesanan berhasil dibuat dan menunggu proses berikutnya.',
                  time: orderDate,
                  isActive: isPending,
                  isCompleted: isDiproses || isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pembayaran Dikonfirmasi',
                  description: 'Pembayaran Anda telah sukses diverifikasi.',
                  time: '',
                  isActive: false,
                  isCompleted: isDiproses || isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Diproses',
                  description: 'Penjual sedang menyiapkan suplemen kesehatan Anda.',
                  time: '',
                  isActive: isDiproses,
                  isCompleted: isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Sedang Dikirim',
                  description: isDikirim || isSelesai
                      ? 'Pesanan dalam perjalanan oleh kurir ekspedisi.\nNo. Resi: $trackingNumber'
                      : 'Pesanan akan segera diserahkan ke kurir.',
                  time: '',
                  isActive: isDikirim,
                  isCompleted: isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Selesai',
                  description: 'Barang telah sukses sampai di alamat tujuan.',
                  time: '',
                  isActive: isSelesai,
                  isCompleted: isSelesai,
                  isLast: true,
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    required String time,
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
    Color activeColor = accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? activeColor
                    : isActive
                        ? activeColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                border: Border.all(
                  color: isCompleted || isActive ? activeColor : Colors.grey[700]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 12, color: activeColor == accentColor ? Colors.black : Colors.white)
                  : isActive
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeColor,
                            ),
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 56,
                color: isCompleted ? activeColor : Colors.grey[800],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted || isActive ? textPrimary : textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isCompleted || isActive ? activeColor.withValues(alpha: 0.8) : textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const subtotal = 700000;
    const shippingCost = 20000;
    const totalPayment = subtotal + shippingCost;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        title: const Text(
          'DETAIL PESANAN',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DETAIL TRANSAKSI',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          key: const Key('status_badge'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(currentStatus).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _statusColor(currentStatus),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            currentStatus.toUpperCase(),
                            key: const Key('status_text'),
                            style: TextStyle(
                              color: _statusColor(currentStatus),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'INV-20240999',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      'Dibuat pada: 2026-06-13',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showOrderStatusTrackerBottomSheet(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: const BorderSide(color: accentColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.local_shipping_outlined, size: 18),
                        label: const Text(
                          'LACAK STATUS PESANAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 16),

                    // Shipping Address
                    const Text(
                      'ALAMAT PENGIRIMAN',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded, color: accentColor, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Jl. Sudirman No.1, Jakarta',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products List
                    const Text(
                      'RINCIAN PRODUK',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Icon(Icons.fitness_center, color: textSecondary, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Whey Protein Gold Standard',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'x2',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      _formatRupiah(subtotal),
                                      style: const TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Details
                    const Text(
                      'RINCIAN PEMBAYARAN',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Metode Pembayaran',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                              Text(
                                'QRIS',
                                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                              Text(
                                _formatRupiah(subtotal),
                                style: const TextStyle(color: textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ongkos Kirim',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                              Text(
                                _formatRupiah(shippingCost),
                                style: const TextStyle(color: textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.white10, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                _formatRupiah(totalPayment),
                                style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Section for Simulation Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIMULATION CONTROLS (REFRESH)',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _allStatuses.map((s) {
                        final isActive = currentStatus == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            key: Key('btn_status_$s'),
                            onPressed: () => setState(() => currentStatus = s),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive ? _statusColor(s) : _statusColor(s).withValues(alpha: 0.15),
                              foregroundColor: isActive ? Colors.black : _statusColor(s),
                              elevation: isActive ? 4 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: _statusColor(s), width: 1),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildStatusPage(String status) {
    return MaterialApp(
      home: _OrderStatusPage(initialStatus: status),
    );
  }

  group('TS.SP-1 - Status Pesanan', () {
    // -------------------------------------------------------------------------
    // TC.SP-1.001 | Positive | Melihat status pesanan
    // Pre : User memiliki pesanan dengan status tertentu
    // Steps:
    //   1. Buka detail pesanan
    // Expected : Status detail pesanan tampil dengan badge yang sesuai
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.SP-1.001] Positive - Buka detail pesanan → status tampil',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildStatusPage('Pending'));
        await tester.pumpAndSettle();

        // Verifikasi halaman detail pesanan tampil
        expect(find.text('DETAIL PESANAN'), findsOneWidget,
            reason: 'TC.SP-1.001: Halaman detail pesanan harus tampil');

        // Verifikasi status badge tampil
        expect(find.byKey(const Key('status_badge')), findsOneWidget,
            reason: 'TC.SP-1.001: Status badge harus tampil di detail pesanan');

        // Verifikasi teks status
        expect(find.text('PENDING'), findsOneWidget,
            reason: 'TC.SP-1.001: Status "PENDING" harus tampil pada badge');
      },
    );

    // -------------------------------------------------------------------------
    // TC.SP-1.002 | Positive | Status berubah menjadi "Diproses"
    // Pre : Pesanan sedang diproses oleh admin
    // Steps:
    //   1. Pesanan sedang diproses
    //   2. Refresh halaman pesanan
    // Expected : Status berubah menjadi "Diproses" (biru)
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.SP-1.002] Positive - Pesanan diproses → status berubah menjadi DIPROSES',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildStatusPage('Pending'));
        await tester.pumpAndSettle();

        // Verifikasi status awal = Pending
        expect(find.text('PENDING'), findsOneWidget);

        // Simulasi refresh → status berubah ke Diproses
        await tester.tap(find.byKey(const Key('btn_status_Diproses')));
        await tester.pumpAndSettle();

        // Expected: status berubah menjadi "DIPROSES"
        expect(
          find.text('DIPROSES'),
          findsOneWidget,
          reason: 'TC.SP-1.002: Setelah refresh, status harus berubah menjadi DIPROSES',
        );

        // Verifikasi "PENDING" sudah tidak tampil
        expect(find.text('PENDING'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // TC.SP-1.003 | Positive | Status berubah menjadi "Dikirim"
    // Pre : Pesanan sudah dikirim oleh admin/kurir
    // Steps:
    //   1. Pesanan sudah dikirim
    //   2. Refresh halaman pesanan
    // Expected : Status berubah menjadi "Dikirim" (hijau/accent)
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.SP-1.003] Positive - Pesanan dikirim → status berubah menjadi DIKIRIM',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildStatusPage('Diproses'));
        await tester.pumpAndSettle();

        // Verifikasi status awal = Diproses
        expect(find.text('DIPROSES'), findsOneWidget);

        // Simulasi refresh → status berubah ke Dikirim
        await tester.tap(find.byKey(const Key('btn_status_Dikirim')));
        await tester.pumpAndSettle();

        // Expected: status berubah menjadi "DIKIRIM"
        expect(
          find.text('DIKIRIM'),
          findsOneWidget,
          reason: 'TC.SP-1.003: Setelah refresh, status harus berubah menjadi DIKIRIM',
        );

        expect(find.text('DIPROSES'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // TC.SP-1.004 | Positive | Status berubah menjadi "Selesai"
    // Pre : Pesanan sudah diterima oleh pembeli
    // Steps:
    //   1. Pesanan sudah diterima
    //   2. Refresh halaman pesanan
    // Expected : Status berubah menjadi "Selesai" (hijau/accent)
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.SP-1.004] Positive - Pesanan diterima → status berubah menjadi SELESAI',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildStatusPage('Dikirim'));
        await tester.pumpAndSettle();

        // Verifikasi status awal = Dikirim
        expect(find.text('DIKIRIM'), findsOneWidget);

        // Simulasi refresh → status berubah ke Selesai
        await tester.tap(find.byKey(const Key('btn_status_Selesai')));
        await tester.pumpAndSettle();

        // Expected: status berubah menjadi "SELESAI"
        expect(
          find.text('SELESAI'),
          findsOneWidget,
          reason: 'TC.SP-1.004: Setelah refresh, status harus berubah menjadi SELESAI',
        );

        expect(find.text('DIKIRIM'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // TC.SP-1.005 | Positive | Pesanan dibatalkan
    // Pre : Pesanan dibatalkan (oleh user atau admin)
    // Steps:
    //   1. Pesanan dibatalkan
    //   2. Buka detail pesanan
    // Expected : Status berubah menjadi "Dibatalkan" (merah)
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.SP-1.005] Positive - Pesanan dibatalkan → status berubah menjadi DIBATALKAN',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildStatusPage('Pending'));
        await tester.pumpAndSettle();

        // Verifikasi status awal = Pending
        expect(find.text('PENDING'), findsOneWidget);

        // Simulasi pembatalan → status berubah ke Dibatalkan
        await tester.tap(find.byKey(const Key('btn_status_Dibatalkan')));
        await tester.pumpAndSettle();

        // Expected: status berubah menjadi "DIBATALKAN"
        expect(
          find.text('DIBATALKAN'),
          findsOneWidget,
          reason: 'TC.SP-1.005: Status harus berubah menjadi DIBATALKAN '
              'saat pesanan dibatalkan',
        );

        expect(find.text('PENDING'), findsNothing);

        // Verifikasi warna badge merah (indikator pembatalan)
        final badgeWidget = tester.widget<Container>(
          find.byKey(const Key('status_badge')),
        );
        final decoration = badgeWidget.decoration as BoxDecoration;
        final borderColor = (decoration.border as Border).top.color;
        expect(
          borderColor,
          Colors.redAccent,
          reason: 'TC.SP-1.005: Badge "Dibatalkan" harus berwarna merah',
        );
      },
    );
  });
}
