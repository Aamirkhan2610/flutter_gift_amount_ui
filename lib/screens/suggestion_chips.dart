import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ⭐ SUPER SMOOTH breathing zoom curve (sine wave)
class SmoothSinusCurve extends Curve {
  const SmoothSinusCurve();

  @override
  double transform(double t) {
    return 0.5 + 0.5 * math.sin(t * 2 * math.pi);
  }
}

class SuggestionChips extends StatefulWidget {
  final List<String> labels;
  final List<IconData> icons;
  final AnimationController controller; // enter animation
  final AnimationController infiniteIconController; // NONSTOP zoom
  final List<AnimationController> popControllers;
  final Function(int) onTap;

  const SuggestionChips({
    Key? key,
    required this.labels,
    required this.icons,
    required this.controller,
    required this.infiniteIconController,
    required this.popControllers,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SuggestionChips> createState() => _SuggestionChipsState();
}

class _SuggestionChipsState extends State<SuggestionChips> {
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _iconScaleAnims;
  late List<Animation<double>> _rotationAnims;

  // ⭐ Only infinite SCALE (smooth breathing)
  late List<Animation<double>> _iconInfiniteScales;

  final List<Color> _chipColors = [
    Colors.redAccent,
    Colors.orange,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.red,
    Colors.blueAccent,
    Colors.green,
  ];

  int _selectedIndex = -1; // <- track selected chip

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    widget.controller.addListener(_onControllerTick);
    widget.infiniteIconController.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant SuggestionChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    widget.infiniteIconController.removeListener(_onControllerTick);
    super.dispose();
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  void _buildAnimations() {
    final count = widget.labels.length;

    /// Fade In
    _fadeAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    /// Slide Up
    _slideAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.45).clamp(0.0, 1.0);
      final anim = CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
          .animate(anim);
    });

    /// Icon Entrance Scale
    _iconScaleAnims = List.generate(count, (i) {
      final start = (i * 0.08 + 0.05).clamp(0.0, 0.9);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    /// Small entrance rotation only (kept)
    _rotationAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.12, end: 0.0).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(start, end)),
      );
    });

    /// ⭐ Infinite smooth breathing animation (SINE WAVE)
    _iconInfiniteScales = List.generate(count, (i) {
      return Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(
          parent: widget.infiniteIconController,
          curve: const SmoothSinusCurve(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.labels.length;

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final fade = _fadeAnims[index].value;
          final slide = _slideAnims[index].value;

          final iconEntranceScale = 0.7 + 0.3 * _iconScaleAnims[index].value;
          final iconEntranceRotate = _rotationAnims[index].value;

          final iconInfiniteScale = _iconInfiniteScales[index].value;

          final popScale = 1.0 + widget.popControllers[index].value;

          final icon = widget.icons[index];
          final label = widget.labels[index];
          final color = _chipColors[index % _chipColors.length];

          final isSelected = _selectedIndex == index;

          return Transform.translate(
            offset: Offset(0, 40 * (1 - fade)) + slide * 24,
            child: Opacity(
              opacity: fade,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // toggle selection
                    _selectedIndex = isSelected ? -1 : index;
                  });
                  widget.onTap(index);
                },
                child: Transform.scale(
                  scale: popScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: isSelected
                          ? Border.all(color: color.withOpacity(0.20), width: 1)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// ⭐ FINAL: Smooth breathing zoom (no infinite rotation)
                        Transform.rotate(
                          angle: iconEntranceRotate, // only entrance rotate
                          child: Transform.scale(
                            scale: iconEntranceScale * iconInfiniteScale,
                            child: Icon(icon, size: 22, color: color),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
