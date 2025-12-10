import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuggestionChips extends StatefulWidget {
  final List<String> labels;
  final List<IconData> icons;
  final AnimationController controller; // master controller from parent
  final List<AnimationController> popControllers; // per-chip tap pop controllers
  final Function(int) onTap;

  const SuggestionChips({
    Key? key,
    required this.labels,
    required this.icons,
    required this.controller,
    required this.popControllers,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SuggestionChips> createState() => _SuggestionChipsState();
}

class _SuggestionChipsState extends State<SuggestionChips> {
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _iconScaleAnims;
  late final List<Animation<double>> _rotationAnims;

  final List<Color> _chipColors = [
    Colors.redAccent,
    Colors.orange,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.red,
    Colors.blueAccent,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    // re-build on each tick to rebuild widgets that depend on controller.value
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant SuggestionChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.labels.length != widget.labels.length) {
      oldWidget.controller.removeListener(_onControllerTick);
      _buildAnimations();
      widget.controller.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    super.dispose();
  }

  void _onControllerTick() {
    // Just trigger rebuild for Animated values
    if (mounted) setState(() {});
  }

  void _buildAnimations() {
    final count = widget.labels.length;
    _fadeAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.45).clamp(0.0, 1.0);
      final anim = CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim);
    });

    _iconScaleAnims = List.generate(count, (i) {
      final start = (i * 0.08 + 0.05).clamp(0.0, 0.9);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: widget.controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _rotationAnims = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.12, end: 0.0).animate(
        CurvedAnimation(parent: widget.controller, curve: Interval(start, end, curve: Curves.easeOut)),
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
          final fade = _fadeAnims[index].value.clamp(0.0, 1.0);
          final slide = _slideAnims[index].value;
          final iconScale = (0.7 + 0.3 * _iconScaleAnims[index].value).clamp(0.7, 1.2);
          final rotation = _rotationAnims[index].value;
          final popScale = 1.0 + widget.popControllers[index].value;

          final color = _chipColors[index % _chipColors.length];
          final label = widget.labels[index];
          final icon = widget.icons[index];

          return Transform.translate(
            offset: Offset(0, 40 * (1 - fade)) + slide * 24,
            child: Opacity(
              opacity: fade,
              child: GestureDetector(
                onTap: () => widget.onTap(index),
                child: Transform.scale(
                  scale: popScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated icon: rotate + scale + colored
                        Transform.rotate(
                          angle: rotation,
                          child: Transform.scale(
                            scale: iconScale,
                            child: Icon(icon, size: 22, color: color),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
