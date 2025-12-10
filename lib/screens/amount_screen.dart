import 'package:flutter/material.dart';
import 'package:flutter_gift_amount/screens/suggestion_chips.dart';

import 'amount_display.dart';
import 'custom_keyboard.dart';
import 'note_display.dart';

class AmountScreen extends StatefulWidget {
  const AmountScreen({Key? key}) : super(key: key);

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen>
    with TickerProviderStateMixin {
  String _amount = '0';
  String _note = '';

  bool _keyboardVisible = false;

  late final AnimationController _chipsController;
  final List<String> _chips = [
    'Gift',
    'Lunch Treat',
    'Donation',
    'Celebration',
    'Support',
    'Motivation',
    'Blessing'
  ];

  final List<IconData> _icons = [
    Icons.card_giftcard,
    Icons.lunch_dining,
    Icons.volunteer_activism,
    Icons.celebration,
    Icons.favorite,
    Icons.rocket_launch,
    Icons.local_florist,
  ];

  final List<AnimationController> _chipPopControllers = [];

  @override
  void initState() {
    super.initState();

    _chipsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    for (int i = 0; i < _chips.length; i++) {
      _chipPopControllers.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
        lowerBound: 0.0,
        upperBound: 0.12,
      ));
    }
  }

  @override
  void dispose() {
    _chipsController.dispose();
    for (final c in _chipPopControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleKeyboard() {
    setState(() {
      _keyboardVisible = !_keyboardVisible;

      if (_keyboardVisible) {
        _chipsController.forward();
      } else {
        _chipsController.reverse();
      }
    });
  }

  void _onKeyboardTap(String key) {
    setState(() {
      if (key == 'del') {
        _amount = _amount.length <= 1 ? '0' : _amount.substring(0, _amount.length - 1);
      } else {
        if (_amount == '0') {
          _amount = key;
        } else {
          if (_amount.length < 9) _amount += key;
        }
      }
    });
  }

  Future<void> _onChipTap(int index) async {
    final pop = _chipPopControllers[index];
    await pop.forward();
    await pop.reverse();

    setState(() {
      _note = _chips[index]; // ONLY UPDATE NOTE
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_keyboardVisible) {
          setState(() {
            _keyboardVisible = false;
            _chipsController.reverse();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              AmountDisplay(
                amount: _amount,
                keyboardVisible: _keyboardVisible,
                onToggle: _toggleKeyboard,
              ),

              NoteDisplay(note: _note),

              const Divider(height: 1),

              Expanded(
                child: Center(
                  child: Text(
                    "Tap the amount to open keyboard\nTap a chip to set a note 🎁",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.45),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _keyboardVisible
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SuggestionChips(
                      labels: _chips,
                      icons: _icons,
                      controller: _chipsController,
                      popControllers: _chipPopControllers,
                      onTap: _onChipTap,
                    ),
                    CustomKeyboard(onTap: _onKeyboardTap),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
