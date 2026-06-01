import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomMediaContainer
// ─────────────────────────────────────────────────────────────────────────────
// Komponen reusable untuk menampilkan media (GIF / Image aset) pada layar
// eksekusi latihan dengan tema gelap (Dark Mode) dan layout vertikal.
//
// Fitur:
//   • Menampilkan GIF / gambar dari aset lokal
//   • Error Builder otomatis jika aset gagal dimuat (file tidak ada, corrupt, dll)
//   • Overlay label latihan opsional di sudut kiri-bawah
//   • Glow border berwarna sesuai tema
//   • Shimmer loading placeholder
//   • Dapat dikustomisasi: ukuran, warna border, radius, overlay
//
// Cara pakai:
//   CustomMediaContainer(
//     assetPath: 'assets/gifs/pushups.gif',
//     themeColor: Colors.orange,
//     label: 'Push Up',
//   )
// ─────────────────────────────────────────────────────────────────────────────

class CustomMediaContainer extends StatefulWidget {
  /// Path ke aset GIF atau gambar, contoh: 'assets/gifs/pushups.gif'
  final String assetPath;

  /// Warna aksen untuk border glow dan ikon fallback
  final Color themeColor;

  /// Label opsional yang ditampilkan di overlay bawah-kiri
  final String? label;

  /// Tinggi container. Default mengikuti flex parent jika null.
  final double? height;

  /// Lebar container. Default [double.infinity].
  final double width;

  /// Border radius sudut container
  final double borderRadius;

  /// Tampilkan gradient overlay gelap di bagian bawah
  final bool showBottomGradient;

  /// Widget kustom yang ditampilkan saat terjadi error (override default)
  final Widget? customErrorWidget;

  const CustomMediaContainer({
    super.key,
    required this.assetPath,
    this.themeColor = const Color(0xFFFF6B35),
    this.label,
    this.height,
    this.width = double.infinity,
    this.borderRadius = 24.0,
    this.showBottomGradient = true,
    this.customErrorWidget,
  });

  @override
  State<CustomMediaContainer> createState() => _CustomMediaContainerState();
}

class _CustomMediaContainerState extends State<CustomMediaContainer>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CustomMediaContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error state jika path berubah (pindah latihan)
    if (oldWidget.assetPath != widget.assetPath) {
      setState(() => _hasError = false);
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final color = widget.themeColor;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: radius,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
        boxShadow: [
          // Glow luar sesuai warna tema
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          // Shadow bawah gelap
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Konten Utama ─────────────────────────────────────────────────
          if (_hasError)
            _ErrorView(
              color: color,
              assetPath: widget.assetPath,
              customErrorWidget: widget.customErrorWidget,
            )
          else
            Image.asset(
              widget.assetPath,
              fit: BoxFit.contain,
              // ── Error Builder ──────────────────────────────────────────
              // Dipanggil otomatis oleh Flutter jika:
              //   • File tidak ditemukan di pubspec.yaml / assets
              //   • File corrupt atau format tidak didukung
              //   • Path salah ketik
              errorBuilder:
                  (BuildContext ctx, Object error, StackTrace? trace) {
                    // Tandai error agar widget rebuild ke _ErrorView
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _hasError = true);
                    });
                    // Tampilkan placeholder sementara saat proses rebuild
                    return _ShimmerPlaceholder(
                      color: color,
                      animation: _shimmerAnim,
                    );
                  },
            ),

          // ── Gradient Overlay Bawah ────────────────────────────────────
          if (widget.showBottomGradient && !_hasError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1C1C28).withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

          // ── Label Overlay Bawah-Kiri ──────────────────────────────────
          if (widget.label != null && !_hasError)
            Positioned(
              bottom: 10,
              left: 14,
              child: _LabelChip(label: widget.label!, color: color),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView — ditampilkan saat aset gagal dimuat
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Color color;
  final String assetPath;
  final Widget? customErrorWidget;

  const _ErrorView({
    required this.color,
    required this.assetPath,
    this.customErrorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (customErrorWidget != null) return customErrorWidget!;

    // Ekstrak nama file dari path untuk pesan debug
    final fileName = assetPath.split('/').last;

    return Container(
      color: const Color(0xFF12121A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon utama
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
              border: Border.all(
                color: color.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: color.withValues(alpha: 0.60),
              size: 36,
            ),
          ),
          const SizedBox(height: 14),

          // Pesan utama
          const Text(
            'Media tidak dapat dimuat',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Nama file (untuk debugging)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              fileName,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Sub-keterangan
          Text(
            'Pastikan file ada di folder assets/',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerPlaceholder — placeholder animasi saat aset sedang dimuat
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerPlaceholder extends StatelessWidget {
  final Color color;
  final Animation<double> animation;

  const _ShimmerPlaceholder({required this.color, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1C1C28),
              Color.lerp(
                const Color(0xFF1C1C28),
                color,
                animation.value * 0.15,
              )!,
              const Color(0xFF1C1C28),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.fitness_center_rounded,
            color: color.withValues(alpha: animation.value * 0.6),
            size: 52,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LabelChip — label nama latihan di sudut bawah media
// ─────────────────────────────────────────────────────────────────────────────

class _LabelChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LabelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
