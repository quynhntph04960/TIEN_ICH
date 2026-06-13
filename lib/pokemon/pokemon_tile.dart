class PokemonTile {
  final int row;
  final int column;
  final int pokemonId;
  final bool isRemoved;

  const PokemonTile({
    required this.row,
    required this.column,
    required this.pokemonId,
    this.isRemoved = false,
  });

  String get assetPath => 'assets/pokemon/$pokemonId.png';

  PokemonTile copyWith({bool? isRemoved}) {
    return PokemonTile(
      row: row,
      column: column,
      pokemonId: pokemonId,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }
}
