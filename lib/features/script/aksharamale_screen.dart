import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/mittu_widget.dart';

class AksharamaleScreen extends StatefulWidget {
  const AksharamaleScreen({super.key});

  @override
  State<AksharamaleScreen> createState() => _AksharamaleScreenState();
}

class _AksharamaleScreenState extends State<AksharamaleScreen> {
  final List<String> _vowels = [
    'ಅ', 'ಆ', 'ಇ', 'ಈ', 'ಉ', 'ಊ', 'ಋ', 'ಎ', 'ಏ', 'ಐ', 'ಒ', 'ಓ', 'ಔ', 'ಅಂ', 'ಅಃ'
  ];

  final List<String> _consonants = [
    'ಕ', 'ಖ', 'ಗ', 'ಘ', 'ಙ',
    'ಚ', 'ಛ', 'ಜ', 'ಝ', 'ಞ',
    'ಟ', 'ಠ', 'ಡ', 'ಢ', 'ಣ',
    'ತ', 'ಥ', 'ದ', 'ಧ', 'ನ',
    'ಪ', 'ಫ', 'ಬ', 'ಭ', 'ಮ',
    'ಯ', 'ರ', 'ಲ', 'ವ', 'ಶ',
    'ಷ', 'ಸ', 'ಹ', 'ಳ'
  ];

  int _selectedTab = 0; // 0 = Vowels (Swaragalu), 1 = Consonants (Vyanjanagalu)
  int _selectedIndex = 0;
  List<Offset?> _points = [];

  List<String> get _activeList => _selectedTab == 0 ? _vowels : _consonants;
  String get _selectedLetter => _activeList[_selectedIndex];

  void _speakLetter() {
    AudioService.instance.speakKannada(_selectedLetter);
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  void _verifyDrawing() {
    final drawnPointsCount = _points.where((p) => p != null).length;
    
    if (drawnPointsCount < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✍️ Please trace more of the letter before verifying!'),
          backgroundColor: AppTheme.secondaryOrange,
        ),
      );
      AudioService.instance.playIncorrect();
      return;
    }

    AudioService.instance.playSuccess();
    _speakLetter();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('🎉 Sakkath!', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MittuWidget(mood: MittuMood.happy, size: 120, animate: true),
              const SizedBox(height: 16),
              Text(
                "You successfully traced '$_selectedLetter'!",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Keep tracing letters to master the Kannada Aksharamale writing script.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearCanvas();
                setState(() {
                  if (_selectedIndex < _activeList.length - 1) {
                    _selectedIndex++;
                  } else {
                    _selectedIndex = 0;
                  }
                });
              },
              child: const Text('Next Letter ➡️', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aksharamale Tracing', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 0;
                        _selectedIndex = 0;
                        _clearCanvas();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.grey[850] : Colors.grey[200]),
                      foregroundColor: _selectedTab == 0
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Vowels (Swaragalu)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = 1;
                        _selectedIndex = 0;
                        _clearCanvas();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.grey[850] : Colors.grey[200]),
                      foregroundColor: _selectedTab == 1
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Consonants (Vyanjana)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _activeList.length,
              itemBuilder: (context, index) {
                final bool isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _clearCanvas();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    width: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _activeList[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.premiumShadow(isDark: isDark),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        _selectedLetter,
                        style: TextStyle(
                          fontSize: 240,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.grey[900]?.withOpacity(0.4)
                              : Colors.grey[100],
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: GestureDetector(
                        onPanStart: (details) {
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            _points.add(localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            _points.add(localPosition);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _points.add(null);
                          });
                        },
                        child: CustomPaint(
                          painter: TracingPainter(points: _points, isDark: isDark),
                          size: Size.infinite,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'btn_speak',
                            onPressed: _speakLetter,
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.volume_up_rounded),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'btn_clear',
                            onPressed: _clearCanvas,
                            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                            foregroundColor: isDark ? Colors.white70 : Colors.black87,
                            child: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _verifyDrawing,
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Verify Tracing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final List<Offset?> points;
  final bool isDark;

  TracingPainter({required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
