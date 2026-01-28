import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../theme/app_theme.dart';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> with TickerProviderStateMixin {
  final Random _random = Random();
  List<int>? _lastRoll;
  int? _total;
  bool? _isSuccess;
  bool? _isTriple1;
  bool? _isTriple6;
  int _selectedCharacteristic = 3;
  int _bonus = 0;
  bool _isRolling = false;
  List<int> _rollingDice = [1, 1, 1];
  late AnimationController _diceAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _diceRotation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _diceRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _diceAnimationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _lastRoll = null;
    });

    // Animation de roulement
    _diceAnimationController.forward(from: 0);
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _rollingDice = [
            _random.nextInt(6) + 1,
            _random.nextInt(6) + 1,
            _random.nextInt(6) + 1,
          ];
        });
      }
    });

    await Future.delayed(const Duration(milliseconds: 800));
    timer.cancel();

    // Résultat final
    final dice1 = _random.nextInt(6) + 1;
    final dice2 = _random.nextInt(6) + 1;
    final dice3 = _random.nextInt(6) + 1;
    final total = dice1 + dice2 + dice3 + _bonus;
    final threshold = _selectedCharacteristic * 3;
    final isTriple = dice1 == dice2 && dice2 == dice3;
    final isTriple1 = isTriple && dice1 == 1;
    final isTriple6 = isTriple && dice1 == 6;

    setState(() {
      _lastRoll = [dice1, dice2, dice3];
      _total = total;
      _isSuccess = total <= threshold;
      _isTriple1 = isTriple1;
      _isTriple6 = isTriple6;
      _isRolling = false;
      _rollingDice = [dice1, dice2, dice3];
    });

    _diceAnimationController.reverse();
  }

  Widget _buildDiceFace(int value, bool isRolling) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.medievalCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.medievalGold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.medievalDarkBrown.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.medievalDarkBrown,
            shadows: [
              Shadow(
                color: AppTheme.medievalGold.withValues(alpha: 0.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRollDescription() {
    if (_isTriple1 == true) {
      return 'Les dés scintillent d\'une lumière divine... Un miracle se produit !';
    } else if (_isTriple6 == true) {
      return 'Les dés s\'embrasent d\'une lueur infernale... Le destin bascule !';
    } else if (_isSuccess == true) {
      return 'Les dés roulent favorablement... La chance vous sourit !';
    } else {
      return 'Les dés tournent et s\'arrêtent... Le sort n\'est pas favorable.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Caractéristique',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalGold, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _selectedCharacteristic = int.tryParse(value) ?? 3;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Bonus',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalBronze, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.medievalGold, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _bonus = int.tryParse(value) ?? 0;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.medievalGold.withValues(alpha: _glowAnimation.value),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isRolling ? null : _rollDice,
                icon: Icon(
                  _isRolling ? Icons.hourglass_empty : Icons.casino,
                  size: 28,
                ),
                label: Text(
                  _isRolling ? 'Les dés roulent...' : 'Lancer 3d6',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            );
          },
        ),
        if (_isRolling || _lastRoll != null) ...[
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _diceRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _isRolling ? _diceRotation.value : 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.medievalBronze.withValues(alpha: 0.3),
                        AppTheme.medievalGold.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.medievalGold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.medievalDarkBrown.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDiceFace(_isRolling ? _rollingDice[0] : _lastRoll![0], _isRolling),
                          const SizedBox(width: 12),
                          const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDiceFace(_isRolling ? _rollingDice[1] : _lastRoll![1], _isRolling),
                          const SizedBox(width: 12),
                          const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDiceFace(_isRolling ? _rollingDice[2] : _lastRoll![2], _isRolling),
                          if (_bonus != 0) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${_bonus > 0 ? '+' : ''}$_bonus',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.medievalGold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (!_isRolling) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.medievalGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.medievalGold,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '= $_total',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seuil: ${_selectedCharacteristic * 3}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.medievalBronze,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.medievalCream.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.medievalBronze.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getRollDescription(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.medievalDarkBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isTriple1 == true)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withValues(alpha: 0.3),
                                  AppTheme.medievalGold.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '✨ RÉUSSITE CRITIQUE DIVINE ✨',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Les forces célestes bénissent votre action !',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_isTriple6 == true)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.medievalRed.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.medievalRed, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.medievalRed.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🔥 RÉUSSITE CRITIQUE INFERNALE 🔥',
                                  style: TextStyle(
                                    color: AppTheme.medievalRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Les forces infernales influencent le destin !',
                                  style: TextStyle(
                                    color: AppTheme.medievalRed,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_isSuccess == true)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Text(
                              '✅ RÉUSSITE !',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.medievalRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.medievalRed, width: 2),
                            ),
                            child: const Text(
                              '❌ ÉCHEC',
                              style: TextStyle(
                                color: AppTheme.medievalRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
