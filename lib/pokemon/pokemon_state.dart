import 'package:demo2/pokemon/pokemon_tile.dart';

class PokemonState {
  final List<List<PokemonTile>> board;
  final PokemonTile? selectedTile;
  final Set<String> hintedKeys;
  final List<PokemonConnectionPoint> connectionPath;
  final int score;
  final int moves;
  final int hintsLeft;
  final int shufflesLeft;
  final int currentLevel;
  final bool isCompleted;
  final String message;

  const PokemonState({
    this.board = const [],
    this.selectedTile,
    this.hintedKeys = const {},
    this.connectionPath = const [],
    this.score = 0,
    this.moves = 0,
    this.hintsLeft = 3,
    this.shufflesLeft = 3,
    this.currentLevel = 1,
    this.isCompleted = false,
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
    bool? isCompleted,
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
      moves: moves ?? this.moves,
      hintsLeft: hintsLeft ?? this.hintsLeft,
      shufflesLeft: shufflesLeft ?? this.shufflesLeft,
      currentLevel: currentLevel ?? this.currentLevel,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
    );
  }
}

class PokemonConnectionPoint {
  final int row;
  final int column;

  const PokemonConnectionPoint({required this.row, required this.column});
}
