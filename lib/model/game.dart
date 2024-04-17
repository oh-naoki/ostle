import 'package:ostle/model/piece_type.dart';

import 'board.dart';

enum Direction { up, down, left, right }

class Game {
  final Board _board;
  PieceType _currentPieceType;
  int _whiteCaptures = 0;
  int _blackCaptures = 0;

  Game()
      : _board = Board(),
        _currentPieceType = PieceType.white;

  bool _isOnBoard(int row, int col) {
    return row >= 0 && row < _board.grid.length && col >= 0 && col < _board.grid[0].length;
  }

  bool _isEmpty(int row, int col) {
    PieceType piece = _board.getPiece(row, col);
    return piece == PieceType.empty || piece == PieceType.hole;
  }

  bool _isValidMove(int row, int col) {
    return _isOnBoard(row, col) && _isEmpty(row, col);
  }

  bool canMovePiece(int row, int col) {
    PieceType piece = _board.getPiece(row, col);
    return piece == _currentPieceType;
  }

  bool canMoveHole(int row, int col) {
    PieceType piece = _board.getPiece(row, col);
    return piece == PieceType.hole && _isValidMove(row, col);
  }

  void _movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    PieceType piece = _board.getPiece(fromRow, fromCol);

    if (piece == PieceType.hole) {
      _moveHole(fromRow, fromCol, toRow, toCol);
    } else {
      _moveOtherPiece(fromRow, fromCol, toRow, toCol);
    }
  }

  void _moveHole(int fromRow, int fromCol, int toRow, int toCol) {
    _board.placePiece(toRow, toCol, PieceType.hole);
    _board.placePiece(fromRow, fromCol, PieceType.empty);
  }

  void _moveOtherPiece(int fromRow, int fromCol, int toRow, int toCol) {
    List<PieceType> movedPieces = [_board.getPiece(fromRow, fromCol)];
    int currentRow = fromRow;
    int currentCol = fromCol;
    int rowStep = _getRowStep(fromRow, toRow);
    int colStep = _getColStep(fromCol, toCol);

    while (_isOnBoard(currentRow + rowStep, currentCol + colStep) && _board.getPiece(currentRow + rowStep, currentCol + colStep) != PieceType.hole) {
      currentRow += rowStep;
      currentCol += colStep;
      movedPieces.add(_board.getPiece(currentRow, currentCol));
    }

    for (int i = movedPieces.length - 1; i >= 0; i--) {
      _board.placePiece(fromRow + (movedPieces.length - 1 - i) * rowStep, fromCol + (movedPieces.length - 1 - i) * colStep, movedPieces[i]);
    }

    _board.placePiece(fromRow, fromCol, PieceType.empty);
  }

  int _getRowStep(int fromRow, int toRow) {
    return (toRow - fromRow).sign;
  }

  int _getColStep(int fromCol, int toCol) {
    return (toCol - fromCol).sign;
  }

  void makeMove(int fromRow, int fromCol, Direction direction) {
    if (!canMovePiece(fromRow, fromCol) && !canMoveHole(fromRow, fromCol)) {
      throw Exception('Invalid move');
    }

    int rowStep = 0;
    int colStep = 0;

    switch (direction) {
      case Direction.up:
        rowStep = -1;
        break;
      case Direction.down:
        rowStep = 1;
        break;
      case Direction.left:
        colStep = -1;
        break;
      case Direction.right:
        colStep = 1;
        break;
    }

    int toRow = fromRow + rowStep;
    int toCol = fromCol + colStep;

    if (_isValidMove(toRow, toCol)) {
      _movePiece(fromRow, fromCol, toRow, toCol);

      if (_board.getPiece(toRow, toCol) == PieceType.hole) {
        PieceType capturedPiece = _board.getPiece(fromRow, fromCol);
        if (capturedPiece != PieceType.empty && capturedPiece != PieceType.hole) {
          if (_currentPieceType == PieceType.white) {
            _whiteCaptures++;
          } else {
            _blackCaptures++;
          }
          _board.placePiece(fromRow, fromCol, PieceType.empty);
        }
      }
    } else {
      PieceType capturedPiece = _board.getPiece(fromRow, fromCol);
      if (capturedPiece != PieceType.empty && capturedPiece != PieceType.hole) {
        if (capturedPiece == _currentPieceType) {
          if (_currentPieceType == PieceType.white) {
            _blackCaptures++;
          } else {
            _whiteCaptures++;
          }
        } else {
          if (_currentPieceType == PieceType.white) {
            _whiteCaptures++;
          } else {
            _blackCaptures++;
          }
        }
        _board.placePiece(fromRow, fromCol, PieceType.empty);
      }
    }

    _switchPlayer();
  }

  bool isGameOver() {
    return _whiteCaptures == 2 || _blackCaptures == 2;
  }

  void _switchPlayer() {
    _currentPieceType = (_currentPieceType == PieceType.white) ? PieceType.black : PieceType.white;
  }
}
