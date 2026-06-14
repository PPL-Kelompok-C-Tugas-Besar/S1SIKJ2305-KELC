import 'package:flutter/material.dart';
import '../../services/supplement_service.dart';
import '../../utils/palette.dart';

class WriteReviewPage extends StatefulWidget {
  final int productId;
  const WriteReviewPage({super.key, required this.productId});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final SupplementService _supplementService = SupplementService();
  int _selectedRating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submitReview() async {
    if (_selectedRating < 1 || _selectedRating > 5) {
      setState(() {
        _error = 'Pilih rating bintang terlebih dahulu (1 - 5)';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await _supplementService.submitReview(
      widget.productId,
      _selectedRating,
      _commentCtrl.text.trim().isNotEmpty ? _commentCtrl.text.trim() : null,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan Anda berhasil dikirim! Terima kasih.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = result['message'];
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'STORE',
              style: TextStyle(
                color: kTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'TULIS ULASAN',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bagaimana kualitas produk ini?',
              style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Berikan rating bintang untuk membantu pengguna Gymbro lainnya.',
              style: TextStyle(color: kTextMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Stars Selector
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  final isSelected = starVal <= _selectedRating;
                  return IconButton(
                    iconSize: 44,
                    icon: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? Colors.amber : kTextMuted.withOpacity(0.5),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _selectedRating = starVal;
                              _error = null;
                            });
                          },
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedRating > 0)
              Center(
                child: Text(
                  _getRatingText(_selectedRating),
                  style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            const SizedBox(height: 24),

            // Comment Box
            const Text(
              'Tulis komentar Anda (opsional)',
              style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentCtrl,
              enabled: !_isSubmitting,
              maxLines: 5,
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Tulis ulasan Anda mengenai produk, rasa, kemasan, atau kecepatan pengiriman di sini...',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                fillColor: kCard,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: kAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error display
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: kAccent.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  elevation: 8,
                  shadowColor: kAccent.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Sangat Bagus!';
      default:
        return '';
    }
  }
}
