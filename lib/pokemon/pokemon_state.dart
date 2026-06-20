import 'package:demo2/pokemon/pokemon_tile.dart';

class PokemonState {
  final List<List<PokemonTile>> board;
  final PokemonTile? selectedTile;
  final Set<String> hintedKeys;
  final List<PokemonConnectionPoint> connectionPath;
  final int score;
  final int hintsLeft;
  final int shufflesLeft;
  final int currentLevel;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isCompleted;
  final bool isTimeOver;
  final String message;

  const PokemonState({
    this.board = const [],
    this.selectedTile,
    this.hintedKeys = const {},
    this.connectionPath = const [],
    this.score = 0,
    this.hintsLeft = 3,
    this.shufflesLeft = 3,
    this.currentLevel = 1,
    this.totalSeconds = 600,
    this.remainingSeconds = 600,
    this.isCompleted = false,
    this.isTimeOver = false,
    this.message = '',
  });

  PokemonState copyWith({
    List<List<PokemonTile>>? board,
    PokemonTile? selectedTile,
    bool clearSelected = false,
    Set<String>? hintedKeys,
    List<PokemonConnectionPoint>? connectionPath,
    bool clearConnectionPath = false,
    int? score,
    int? moves,
    int? hintsLeft,
    int? shufflesLeft,
    int? currentLevel,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isCompleted,
    bool? isTimeOver,
    String? message,
  }) {
    return PokemonState(
      board: board ?? this.board,
      selectedTile: clearSelected ? null : selectedTile ?? this.selectedTile,
      hintedKeys: hintedKeys ?? this.hintedKeys,
      connectionPath: clearConnectionPath
          ? const []
          : connectionPath ?? this.connectionPath,
      score: score ?? this.score,
      hintsLeft: hintsLeft ?? this.hintsLeft,
      shufflesLeft: shufflesLeft ?? this.shufflesLeft,
      currentLevel: currentLevel ?? this.currentLevel,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isTimeOver: isTimeOver ?? this.isTimeOver,
      message: message ?? this.message,
    );
  }
}

class PokemonConnectionPoint {
  final int row;
  final int column;

  const PokemonConnectionPoint({required this.row, required this.column});
}
