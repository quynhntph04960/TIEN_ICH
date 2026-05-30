class SudokuItem {
  final int row;
  final int column;
  final int data;
  final int answer;
  final bool isFixed;
  final bool isError;

  bool get isCorrect => data != 0 && data == answer;
  bool get isLocked => isFixed || isCorrect;

  const SudokuItem({
    required this.row,
    required this.column,
    this.data = 0,
    this.answer = 0,
    this.isFixed = false,
    this.isError = false,
  });

  SudokuItem copyWith({
    int? row,
    int? column,
    int? data,
    int? answer,
    bool? isFixed,
    bool? isError,
  }) {
    return SudokuItem(
      row: row ?? this.row,
      column: column ?? this.column,
      data: data ?? this.data,
      answer: answer ?? this.answer,
      isFixed: isFixed ?? this.isFixed,
      isError: isError ?? this.isError,
    );
  }
}
