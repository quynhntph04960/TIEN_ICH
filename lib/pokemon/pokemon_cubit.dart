import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:demo2/pokemon/pokemon_state.dart';
import 'package:demo2/pokemon/pokemon_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PokemonCubit extends Cubit<PokemonState> {
  PokemonCubit() : super(const PokemonState());

  static const int rows = 9;
  static const int columns = 16;
  static const int pokemonKinds = 36;
  static const int levelCount = 9;
  static const int gameSeconds = 600;

  final Random _random = Random();
  Timer? _timer;
  int _animationId = 0;

  void initialize() {
    newGame();
  }

  void newGame() {
    _startGameAtLevel(state.currentLevel);
  }

  void continueAfterWin() {
    if (!state.isCompleted) return;

    final nextLevel = state.currentLevel >= levelCount
        ? 1
        : state.currentLevel + 1;
    _startGameAtLevel(nextLevel);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startGameAtLevel(int level) {
    _animationId++;
    _timer?.cancel();
    emit(
      PokemonState(
        board: _createBoard(),
        currentLevel: level,
        totalSeconds: gameSeconds,
        remainingSeconds: gameSeconds,
        message: '${_levelName(level)} đã sẵn sàng',
      ),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed || state.isCompleted || state.isTimeOver) {
        _timer?.cancel();
        return;
      }

      final remainingSeconds = state.remainingSeconds - 1;
      if (remainingSeconds <= 0) {
        _animationId++;
        _timer?.cancel();
        emit(
          state.copyWith(
            remainingSeconds: 0,
            isTimeOver: true,
            clearSelected: true,
            clearConnectionPath: true,
            hintedKeys: const {},
            message: 'Hết giờ rồi',
          ),
        );
        return;
      }

      emit(state.copyWith(remainingSeconds: remainingSeconds));
    });
  }

  Future<void> selectTile(PokemonTile tile) async {
    if (state.isCompleted ||
        state.isTimeOver ||
        tile.isRemoved ||
        state.connectionPath.isNotEmpty) {
      return;
    }

    final selected = state.selectedTile;
    if (selected == null) {
      emit(
        state.copyWith(
          selectedTile: tile,
          hintedKeys: const {},
          message: 'Đã chọn Pokemon đầu tiên',
        ),
      );
      return;
    }

    if (_samePosition(selected, tile)) {
      emit(state.copyWith(clearSelected: true, message: 'Đã bỏ chọn'));
      return;
    }

    if (selected.pokemonId != tile.pokemonId) {
      emit(
        state.copyWith(
          selectedTile: tile,
          hintedKeys: const {},
          message: 'Hai Pokemon chưa giống nhau',
        ),
      );
      return;
    }

    final path = _findConnectionPath(selected, tile, state.board);
    if (path == null) {
      emit(
        state.copyWith(
          selectedTile: tile,
          hintedKeys: const {},
          message: 'Đường nối bị chặn',
        ),
      );
      return;
    }

    final animationId = ++_animationId;
    emit(
      state.copyWith(
        clearSelected: true,
        hintedKeys: const {},
        connectionPath: _toConnectionPath(path),
        message: 'Đã nối đúng cặp!',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (isClosed || animationId != _animationId) return;

    final updated = _removePair(state.board, selected, tile);
    final leveled = _applyLevelMovement(updated);
    final completed = _isCompleted(leveled);
    final needsShuffle = !completed && _findConnectablePair(leveled) == null;
    final nextBoard = needsShuffle ? _shuffleRemaining(leveled) : leveled;
    if (completed) _timer?.cancel();

    emit(
      state.copyWith(
        board: nextBoard,
        clearSelected: true,
        clearConnectionPath: true,
        hintedKeys: const {},
        score: state.score + 10,
        isCompleted: completed,
        message: completed
            ? 'Hoàn thành ván Pokemon'
            : needsShuffle
            ? 'Ăn điểm! Bàn đã tự xáo vì hết nước đi'
            : 'Ăn điểm!',
      ),
    );
  }

  void revealHint() {
    if (state.isCompleted ||
        state.isTimeOver ||
        state.connectionPath.isNotEmpty ||
        state.hintsLeft <= 0) {
      emit(state.copyWith(message: 'Bạn đã dùng hết gợi ý'));
      return;
    }

    final pair = _findConnectablePair(state.board);
    if (pair == null) {
      shuffleBoard(force: true);
      return;
    }

    emit(
      state.copyWith(
        selectedTile: pair.first,
        hintedKeys: {_tileKey(pair.first), _tileKey(pair.second)},
        hintsLeft: state.hintsLeft - 1,
        message: 'Đã tìm thấy một cặp có thể nối',
      ),
    );
  }

  void shuffleBoard({bool force = false}) {
    if (state.isCompleted ||
        state.isTimeOver ||
        state.connectionPath.isNotEmpty) {
      return;
    }
    if (!force && state.shufflesLeft <= 0) {
      emit(state.copyWith(message: 'Bạn đã dùng hết lượt xáo'));
      return;
    }

    _animationId++;
    emit(
      state.copyWith(
        board: _shuffleRemaining(state.board),
        clearSelected: true,
        clearConnectionPath: true,
        hintedKeys: const {},
        shufflesLeft: force ? state.shufflesLeft : state.shufflesLeft - 1,
        message: 'Đã xáo lại bàn chơi',
      ),
    );
  }

  List<List<PokemonTile>> _createBoard() {
    final pairCount = rows * columns ~/ 2;
    final ids = <int>[];

    for (var index = 0; index < pairCount; index++) {
      final id = index % pokemonKinds;
      ids.addAll([id, id]);
    }

    List<List<PokemonTile>> board;
    do {
      ids.shuffle(_random);
      board = List.generate(rows, (row) {
        return List.generate(columns, (column) {
          return PokemonTile(
            row: row,
            column: column,
            pokemonId: ids[row * columns + column],
          );
        });
      });
    } while (_findConnectablePair(board) == null);

    return board;
  }

  List<List<PokemonTile>> _removePair(
    List<List<PokemonTile>> board,
    PokemonTile first,
    PokemonTile second,
  ) {
    return board.map((row) {
      return row.map((tile) {
        if (_samePosition(tile, first) || _samePosition(tile, second)) {
          return tile.copyWith(isRemoved: true);
        }
        return tile;
      }).toList();
    }).toList();
  }

  List<List<PokemonTile>> _shuffleRemaining(List<List<PokemonTile>> board) {
    final ids = <int>[];
    for (final row in board) {
      for (final tile in row) {
        if (!tile.isRemoved) ids.add(tile.pokemonId);
      }
    }

    if (ids.isEmpty) return board;

    List<List<PokemonTile>> shuffled;
    do {
      ids.shuffle(_random);
      var index = 0;
      shuffled = board.map((row) {
        return row.map((tile) {
          if (tile.isRemoved) return tile;
          return PokemonTile(
            row: tile.row,
            column: tile.column,
            pokemonId: ids[index++],
          );
        }).toList();
      }).toList();
    } while (_findConnectablePair(shuffled) == null);

    return shuffled;
  }

  List<List<PokemonTile>> _applyLevelMovement(List<List<PokemonTile>> board) {
    return switch (state.currentLevel) {
      2 => _packColumns(board, toEnd: true),
      3 => _packColumns(board, toEnd: false),
      4 => _packRows(board, toEnd: true),
      5 => _packRows(board, toEnd: false),
      6 => _packToCenter(board),
      7 => _packToOutside(board),
      8 => _packRowsToMiddleRow(board),
      9 => _packRowsToEdgesWithMiddleSplit(board),
      _ => board,
    };
  }

  List<List<PokemonTile>> _packColumns(
    List<List<PokemonTile>> board, {
    required bool toEnd,
  }) {
    final packed = _emptyBoard();
    for (var column = 0; column < columns; column++) {
      final ids = <int>[];
      for (var row = 0; row < rows; row++) {
        final tile = board[row][column];
        if (!tile.isRemoved) ids.add(tile.pokemonId);
      }

      for (var index = 0; index < ids.length; index++) {
        final row = toEnd ? rows - ids.length + index : index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: ids[index],
        );
      }
    }
    return packed;
  }

  List<List<PokemonTile>> _packRows(
    List<List<PokemonTile>> board, {
    required bool toEnd,
  }) {
    final packed = _emptyBoard();
    for (var row = 0; row < rows; row++) {
      final ids = <int>[];
      for (var column = 0; column < columns; column++) {
        final tile = board[row][column];
        if (!tile.isRemoved) ids.add(tile.pokemonId);
      }

      for (var index = 0; index < ids.length; index++) {
        final column = toEnd ? columns - ids.length + index : index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: ids[index],
        );
      }
    }
    return packed;
  }

  List<List<PokemonTile>> _packToCenter(List<List<PokemonTile>> board) {
    return _packRowsToMiddleColumns(board);
  }

  List<List<PokemonTile>> _packToOutside(List<List<PokemonTile>> board) {
    return _packRowsToOuterColumns(board);
  }

  List<List<PokemonTile>> _packRowsToMiddleRow(List<List<PokemonTile>> board) {
    final packed = _emptyBoard();

    for (var column = 0; column < columns; column++) {
      final ids = <int>[];
      for (var row = 0; row < rows; row++) {
        final tile = board[row][column];
        if (!tile.isRemoved) ids.add(tile.pokemonId);
      }

      final startRow = (rows - ids.length) ~/ 2;
      for (var index = 0; index < ids.length; index++) {
        final row = startRow + index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: ids[index],
        );
      }
    }

    return packed;
  }

  List<List<PokemonTile>> _packRowsToEdgesWithMiddleSplit(
    List<List<PokemonTile>> board,
  ) {
    final packed = _emptyBoard();
    final middleRow = rows ~/ 2;

    for (var column = 0; column < columns; column++) {
      final topIds = <int>[];
      for (var row = 0; row < middleRow; row++) {
        final tile = board[row][column];
        if (!tile.isRemoved) topIds.add(tile.pokemonId);
      }

      final middleTile = board[middleRow][column];
      final isEvenDisplayColumn = (column + 1).isEven;
      if (!middleTile.isRemoved && isEvenDisplayColumn) {
        topIds.add(middleTile.pokemonId);
      }

      for (var index = 0; index < topIds.length; index++) {
        packed[index][column] = PokemonTile(
          row: index,
          column: column,
          pokemonId: topIds[index],
        );
      }

      final bottomIds = <int>[];
      if (!middleTile.isRemoved && !isEvenDisplayColumn) {
        bottomIds.add(middleTile.pokemonId);
      }

      for (var row = middleRow + 1; row < rows; row++) {
        final tile = board[row][column];
        if (!tile.isRemoved) bottomIds.add(tile.pokemonId);
      }

      final bottomStartRow = rows - bottomIds.length;
      for (var index = 0; index < bottomIds.length; index++) {
        final row = bottomStartRow + index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: bottomIds[index],
        );
      }
    }

    return packed;
  }

  List<List<PokemonTile>> _packRowsToMiddleColumns(
    List<List<PokemonTile>> board,
  ) {
    final packed = _emptyBoard();
    final leftCenterColumn = columns ~/ 2 - 1;
    final rightCenterColumn = columns ~/ 2;

    for (var row = 0; row < rows; row++) {
      final leftIds = <int>[];
      for (var column = 0; column <= leftCenterColumn; column++) {
        final tile = board[row][column];
        if (!tile.isRemoved) leftIds.add(tile.pokemonId);
      }

      final leftStartColumn = leftCenterColumn - leftIds.length + 1;
      for (var index = 0; index < leftIds.length; index++) {
        final column = leftStartColumn + index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: leftIds[index],
        );
      }

      final rightIds = <int>[];
      for (var column = rightCenterColumn; column < columns; column++) {
        final tile = board[row][column];
        if (!tile.isRemoved) rightIds.add(tile.pokemonId);
      }

      for (var index = 0; index < rightIds.length; index++) {
        final column = rightCenterColumn + index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: rightIds[index],
        );
      }
    }

    return packed;
  }

  List<List<PokemonTile>> _packRowsToOuterColumns(
    List<List<PokemonTile>> board,
  ) {
    final packed = _emptyBoard();
    final leftCenterColumn = columns ~/ 2 - 1;
    final rightCenterColumn = columns ~/ 2;

    for (var row = 0; row < rows; row++) {
      final leftIds = <int>[];
      for (var column = 0; column <= leftCenterColumn; column++) {
        final tile = board[row][column];
        if (!tile.isRemoved) leftIds.add(tile.pokemonId);
      }

      for (var index = 0; index < leftIds.length; index++) {
        packed[row][index] = PokemonTile(
          row: row,
          column: index,
          pokemonId: leftIds[index],
        );
      }

      final rightIds = <int>[];
      for (var column = rightCenterColumn; column < columns; column++) {
        final tile = board[row][column];
        if (!tile.isRemoved) rightIds.add(tile.pokemonId);
      }

      final rightStartColumn = columns - rightIds.length;
      for (var index = 0; index < rightIds.length; index++) {
        final column = rightStartColumn + index;
        packed[row][column] = PokemonTile(
          row: row,
          column: column,
          pokemonId: rightIds[index],
        );
      }
    }

    return packed;
  }

  List<List<PokemonTile>> _emptyBoard() {
    return List.generate(rows, (row) {
      return List.generate(columns, (column) {
        return PokemonTile(
          row: row,
          column: column,
          pokemonId: 0,
          isRemoved: true,
        );
      });
    });
  }

  _PokemonPair? _findConnectablePair(List<List<PokemonTile>> board) {
    final activeTiles = <PokemonTile>[];
    for (final row in board) {
      for (final tile in row) {
        if (!tile.isRemoved) activeTiles.add(tile);
      }
    }

    for (var first = 0; first < activeTiles.length; first++) {
      for (var second = first + 1; second < activeTiles.length; second++) {
        final firstTile = activeTiles[first];
        final secondTile = activeTiles[second];
        if (firstTile.pokemonId == secondTile.pokemonId &&
            _findConnectionPath(firstTile, secondTile, board) != null) {
          return _PokemonPair(firstTile, secondTile);
        }
      }
    }

    return null;
  }

  List<_Point>? _findConnectionPath(
    PokemonTile first,
    PokemonTile second,
    List<List<PokemonTile>> board,
  ) {
    final grid = _buildConnectionGrid(board, first, second);
    final start = _Point(first.row + 1, first.column + 1);
    final target = _Point(second.row + 1, second.column + 1);
    final queue = Queue<_PathNode>();
    final bestTurns = <String, int>{};

    for (var direction = 0; direction < _directions.length; direction++) {
      final next = start.move(_directions[direction]);
      if (!_canPass(next, target, grid)) continue;
      queue.add(_PathNode(next, direction, 0, [start, next]));
      bestTurns['${next.row},${next.column},$direction'] = 0;
    }

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      if (node.point == target) return _compactPath(node.path);

      for (var direction = 0; direction < _directions.length; direction++) {
        final turns = node.turns + (direction == node.direction ? 0 : 1);
        if (turns > 2) continue;

        final next = node.point.move(_directions[direction]);
        if (!_canPass(next, target, grid)) continue;

        final key = '${next.row},${next.column},$direction';
        final previousTurns = bestTurns[key];
        if (previousTurns != null && previousTurns <= turns) continue;

        bestTurns[key] = turns;
        queue.add(_PathNode(next, direction, turns, [...node.path, next]));
      }
    }

    return null;
  }

  List<_Point> _compactPath(List<_Point> path) {
    if (path.length <= 2) return path;

    final compacted = <_Point>[path.first];
    for (var index = 1; index < path.length - 1; index++) {
      final previous = path[index - 1];
      final current = path[index];
      final next = path[index + 1];
      final previousDirection = _Point(
        current.row - previous.row,
        current.column - previous.column,
      );
      final nextDirection = _Point(
        next.row - current.row,
        next.column - current.column,
      );

      if (previousDirection != nextDirection) {
        compacted.add(current);
      }
    }
    compacted.add(path.last);
    return compacted;
  }

  List<PokemonConnectionPoint> _toConnectionPath(List<_Point> path) {
    return path.map((point) {
      return PokemonConnectionPoint(
        row: point.row - 1,
        column: point.column - 1,
      );
    }).toList();
  }

  List<List<bool>> _buildConnectionGrid(
    List<List<PokemonTile>> board,
    PokemonTile first,
    PokemonTile second,
  ) {
    return List.generate(rows + 2, (row) {
      return List.generate(columns + 2, (column) {
        if (row == 0 ||
            column == 0 ||
            row == rows + 1 ||
            column == columns + 1) {
          return true;
        }

        final tile = board[row - 1][column - 1];
        return tile.isRemoved ||
            _samePosition(tile, first) ||
            _samePosition(tile, second);
      });
    });
  }

  bool _canPass(_Point point, _Point target, List<List<bool>> grid) {
    if (point.row < 0 ||
        point.column < 0 ||
        point.row >= grid.length ||
        point.column >= grid.first.length) {
      return false;
    }
    return grid[point.row][point.column] || point == target;
  }

  bool _isCompleted(List<List<PokemonTile>> board) {
    for (final row in board) {
      for (final tile in row) {
        if (!tile.isRemoved) return false;
      }
    }
    return true;
  }

  bool _samePosition(PokemonTile first, PokemonTile second) {
    return first.row == second.row && first.column == second.column;
  }

  String _tileKey(PokemonTile tile) => '${tile.row}-${tile.column}';

  String _levelName(int level) {
    return switch (level) {
      1 => 'Cấp 1: Giữ nguyên',
      2 => 'Cấp 2: Từ trên xuống',
      3 => 'Cấp 3: Từ dưới lên',
      4 => 'Cấp 4: Từ trái qua phải',
      5 => 'Cấp 5: Từ phải qua trái',
      6 => 'Cấp 6: Tập trung vào giữa',
      7 => 'Cấp 7: Tập trung ra ngoài',
      8 => 'Cấp 8: Dồn về hàng 5',
      9 => 'Cấp 9: Tách về hàng 1 và 9',
      _ => 'Cấp $level',
    };
  }
}

const List<_Point> _directions = [
  _Point(-1, 0),
  _Point(0, 1),
  _Point(1, 0),
  _Point(0, -1),
];

class _PokemonPair {
  final PokemonTile first;
  final PokemonTile second;

  const _PokemonPair(this.first, this.second);
}

class _PathNode {
  final _Point point;
  final int direction;
  final int turns;
  final List<_Point> path;

  const _PathNode(this.point, this.direction, this.turns, this.path);
}

class _Point {
  final int row;
  final int column;

  const _Point(this.row, this.column);

  _Point move(_Point direction) {
    return _Point(row + direction.row, column + direction.column);
  }

  @override
  bool operator ==(Object other) {
    return other is _Point && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}
