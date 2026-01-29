import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/character_provider.dart';
import '../data/game_data.dart';
import '../theme/app_theme.dart';
import '../utils/roll_d6.dart';

/// Courbe pour l’animation de rebond des dés : 0 → max → 0.
class _BounceDownCurve extends Curve {
  @override
  double transformInternal(double t) => 4 * t * (1 - t);
}

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> with TickerProviderStateMixin {
  List<int>? _lastRoll;
  int? _total;
  bool? _isSuccess;
  bool? _isTriple1;
  bool? _isTriple6;
  bool? _isOtherTriple;
  int? _otherTripleValue;
  int _selectedCharacteristic = 3;
  int _bonus = 0;
  int _numDice = 3;
  String? _selectedRollType;
  bool _isRolling = false;
  List<int> _rollingDice = [1, 1, 1];
  late AnimationController _diceAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _diceRotation;
  late Animation<double> _diceTumble;
  late Animation<double> _diceBounce;
  late Animation<double> _glowAnimation;
  final TextEditingController _characteristicController = TextEditingController(text: '3');
  final TextEditingController _bonusController = TextEditingController(text: '0');

  /// Noms de caractéristiques par défaut (INS/MV) si aucun jeu/édition.
  static const List<String> _defaultStatNames = [
    'Force', 'Agilité', 'Intelligence', 'Volonté', 'Perception', 'Présence',
  ];

  @override
  void initState() {
    super.initState();
    _characteristicController.addListener(_syncCharacteristicFromController);
    _bonusController.addListener(_syncBonusFromController);
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
    _diceTumble = Tween<double>(begin: 0, end: 5 * pi).animate(
      CurvedAnimation(parent: _diceAnimationController, curve: Curves.easeInOut),
    );
    _diceBounce = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _diceAnimationController, curve: _BounceDownCurve()),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowAnimationController, curve: Curves.easeInOut),
    );
  }

  void _syncCharacteristicFromController() {
    final v = int.tryParse(_characteristicController.text);
    if (v != null && v >= 1 && v <= 6) _selectedCharacteristic = v;
  }

  void _syncBonusFromController() {
    final v = int.tryParse(_bonusController.text);
    if (v != null) _bonus = v;
  }

  @override
  void dispose() {
    _characteristicController.removeListener(_syncCharacteristicFromController);
    _bonusController.removeListener(_syncBonusFromController);
    _characteristicController.dispose();
    _bonusController.dispose();
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

    _diceAnimationController.forward(from: 0);
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _rollingDice = List.generate(_numDice, (_) => RollD6.roll());
        });
      }
    });

    await Future.delayed(const Duration(milliseconds: 800));
    timer.cancel();

    final rolled = List.generate(_numDice, (_) => RollD6.roll());
    final total = rolled.reduce((a, b) => a + b) + _bonus;
    final threshold = _selectedCharacteristic * _numDice;
    final isTriple = _numDice == 3 && rolled[0] == rolled[1] && rolled[1] == rolled[2];
    final isTriple1 = isTriple && rolled[0] == 1;
    final isTriple6 = isTriple && rolled[0] == 6;
    final isOtherTriple = isTriple && rolled[0] != 1 && rolled[0] != 6;

    setState(() {
      _lastRoll = rolled;
      _total = total;
      _isSuccess = total <= threshold;
      _isTriple1 = isTriple1;
      _isTriple6 = isTriple6;
      _isOtherTriple = isOtherTriple;
      _otherTripleValue = isOtherTriple ? rolled[0] : null;
      _isRolling = false;
      _rollingDice = rolled;
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

  /// Texte explicatif INS/MV pour 111 (intervention divine) selon le type de personnage.
  String _getTriple1Title(String? characterType) {
    switch (characterType) {
      case 'Ange':
        return '✨ 111 — INTERVENTION DIVINE ✨';
      case 'Démon':
        return '✨ 111 — INTERVENTION DIVINE ✨';
      case 'Humain':
        return '✨ 111 — INTERVENTION DIVINE ✨';
      default:
        return '✨ 111 — INTERVENTION DIVINE ✨';
    }
  }

  String _getTriple1Subtitle(String? characterType) {
    switch (characterType) {
      case 'Ange':
        return 'Réussite critique pour les anges ! Les forces célestes bénissent votre action.';
      case 'Démon':
        return 'Échec critique pour les démons. L\'intervention divine s\'oppose à vous.';
      case 'Humain':
        return 'Signe favorable pour les humains : bénédiction, la chance vous sourit.';
      default:
        return 'Intervention divine (l\'Unique). Selon votre camp : très bénéfique pour les anges, défavorable pour les démons, favorable pour les humains.';
    }
  }

  /// Texte explicatif INS/MV pour 666 (intervention démoniaque) selon le type de personnage.
  String _getTriple6Title(String? characterType) {
    switch (characterType) {
      case 'Ange':
      case 'Démon':
      case 'Humain':
        return '🔥 666 — INTERVENTION DÉMONIAQUE 🔥';
      default:
        return '🔥 666 — INTERVENTION DÉMONIAQUE 🔥';
    }
  }

  String _getTriple6Subtitle(String? characterType) {
    switch (characterType) {
      case 'Ange':
        return 'Échec critique pour les anges. Les forces infernales s\'opposent à vous.';
      case 'Démon':
        return 'Réussite critique pour les démons ! Les forces infernales influencent le destin en votre faveur.';
      case 'Humain':
        return 'Signe défavorable pour les humains : malédiction, le sort s\'acharne.';
      default:
        return 'Intervention démoniaque (chiffre de la Bête). Très bénéfique pour les démons, défavorable pour les anges, défavorable pour les humains.';
    }
  }

  String _getRollDescription(String? characterType) {
    if (_isTriple1 == true) {
      return _getTriple1Subtitle(characterType);
    } else if (_isTriple6 == true) {
      return _getTriple6Subtitle(characterType);
    } else if (_isOtherTriple == true && _otherTripleValue != null) {
      return 'Triple $_otherTripleValue$_otherTripleValue$_otherTripleValue : selon les éditions INS/MV, certaines combinaisons identiques peuvent avoir des effets spéciaux. Consultez votre livre de règles.';
    } else if (_isSuccess == true) {
      return 'Les dés roulent favorablement... La chance vous sourit !';
    } else {
      return 'Les dés tournent et s\'arrêtent... Le sort n\'est pas favorable.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, CharacterProvider>(
      builder: (context, gameProvider, characterProvider, _) {
        var game = gameProvider.currentGame;
        final character = characterProvider.currentCharacter;
        if (character != null && (game == null || game.id != character.gameId)) {
          final candidates = GameData.getGameSystems().where((g) => g.id == character.gameId).toList();
          if (candidates.isNotEmpty) game = candidates.first;
        }
        final editionId = gameProvider.currentEditionId ?? character?.editionId ?? (game?.editions.isEmpty ?? true ? '' : game!.editions.first.id);
        final edition = game?.getEdition(editionId);
        final statNames = edition?.statNames ?? _defaultStatNames;
        final minDice = game?.minRollDice ?? 1;
        final maxDice = game?.maxRollDice ?? 3;

        // S'assurer que _numDice est dans [minDice, maxDice]
        final effectiveNumDice = _numDice.clamp(minDice, maxDice);
        if (_numDice != effectiveNumDice) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _numDice = effectiveNumDice);
          });
        }

        // Type de jet : valeur effective (défaut = premier de la liste)
        final effectiveRollType = _selectedRollType != null && statNames.contains(_selectedRollType)
            ? _selectedRollType!
            : (statNames.isNotEmpty ? statNames.first : _defaultStatNames.first);
        if (_selectedRollType != effectiveRollType) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedRollType = effectiveRollType;
                final val = character?.characteristics[effectiveRollType] ?? 3;
                _selectedCharacteristic = val.clamp(1, 6);
                _characteristicController.text = '$_selectedCharacteristic';
              });
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type de jet (Jet de Volonté, Jet de Perception, etc.)
            DropdownButtonFormField<String>(
              value: effectiveRollType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Type de jet',
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
              items: statNames.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text('Jet de $name'),
                );
              }).toList(),
              onChanged: (name) {
                if (name == null) return;
                setState(() {
                  _selectedRollType = name;
                  final val = character?.characteristics[name] ?? 3;
                  _selectedCharacteristic = val.clamp(1, 6);
                  _characteristicController.text = '$_selectedCharacteristic';
                });
              },
            ),
            const SizedBox(height: 12),
            // Nombre de dés (1 à max du jeu)
            Row(
              children: [
                Text(
                  'Nombre de dés :',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.medievalDarkBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                ...List.generate(maxDice - minDice + 1, (i) {
                  final n = minDice + i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$n'),
                      selected: _numDice == n,
                      onSelected: (selected) {
                        if (selected) setState(() => _numDice = n);
                      },
                      selectedColor: AppTheme.medievalGold.withValues(alpha: 0.4),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            // Caractéristique (valeur du jet) et bonus
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _characteristicController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Valeur carac. (1–6)',
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _bonusController,
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
                      _isRolling ? 'Les dés roulent...' : 'Lancer ${_numDice}d6',
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
                animation: _diceAnimationController,
                builder: (context, child) {
                  final diceCount = _isRolling ? _rollingDice.length : _lastRoll!.length;
                  final tumble = _diceTumble.value;
                  final bounce = _diceBounce.value;
                  return Container(
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
                            for (int i = 0; i < diceCount; i++) ...[
                              if (i > 0)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.medievalDarkBrown,
                                    ),
                                  ),
                                ),
                            if (_isRolling)
                              Transform.translate(
                                offset: Offset(0, bounce),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(tumble + i * 0.6)
                                    ..rotateY(tumble * 1.2 + i * 0.8),
                                  child: _buildDiceFace(_rollingDice[i], true),
                                ),
                              )
                            else
                              _buildDiceFace(_lastRoll![i], false),
                            ],
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
                              'Seuil: ${_selectedCharacteristic * _numDice} (carac. × $_numDice dés)',
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
                                _getRollDescription(character?.type),
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
                              _buildCriticalBanner(
                                _getTriple1Title(character?.type),
                                _getTriple1Subtitle(character?.type),
                                Colors.green,
                              )
                            else if (_isTriple6 == true)
                              _buildCriticalBanner(
                                _getTriple6Title(character?.type),
                                _getTriple6Subtitle(character?.type),
                                AppTheme.medievalRed,
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
                      )
                    );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCriticalBanner(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            AppTheme.medievalGold.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
