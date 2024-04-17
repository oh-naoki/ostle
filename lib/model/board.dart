import 'package:ostle/model/piece_type.dart';

class Board {
  final List<List<PieceType>> grid;

  Board() : grid = List.generate(5, (_) => List.filled(5, PieceType.empty));

  void placePiece(int row, int col, PieceType piece) {
    grid[row][col] = piece;
  }

  PieceType getPiece(int row, int col) {
    return grid[row][col];
  }
}
