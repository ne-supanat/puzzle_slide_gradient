import 'dart:math';

import 'package:flutter/material.dart';

import 'model/tile_model.dart';
import 'puzzle_controller.dart';
import 'puzzle_style.dart';
import 'tile.dart';

class Board extends StatefulWidget {
  const Board({
    Key? key,
    required this.size,
    required this.onAllCorrect,
    required this.boardSize,
    required this.tileSize,
  }) : super(key: key);

  final int size;
  final void Function() onAllCorrect;
  final double boardSize;
  final double tileSize;

  static small(int size, void Function() onAllCorrect, {Key? key}) {
    return Board(
        size: size,
        onAllCorrect: onAllCorrect,
        boardSize: PuzzleSize.smallBoardWidth,
        tileSize: PuzzleSize.smallTileWidth);
  }

  static medium(int size, void Function() onAllCorrect, {Key? key}) {
    return Board(
        size: size,
        onAllCorrect: onAllCorrect,
        boardSize: PuzzleSize.mediumBoardWidth,
        tileSize: PuzzleSize.mediumTileWidth);
  }

  static large(int size, void Function() onAllCorrect, {Key? key}) {
    return Board(
        size: size,
        onAllCorrect: onAllCorrect,
        boardSize: PuzzleSize.largeBoardWidth,
        tileSize: PuzzleSize.largeTileWidth);
  }

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  var isFinish = false;

  var isBlock = false;

  final tileOffsets = <int, TileModel>{};
  var size = 0;
  var whiteSpaceValue = 0;
  var whiteSpaceCurrentPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    size = widget.size;
    generateTile(size);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      shuffle();
    });
  }

  generateTile(int long) {
    whiteSpaceValue = pow(long, 2).toInt();
    whiteSpaceCurrentPosition =
        Offset((long - 1).toDouble(), (long - 1).toDouble());
    for (int x = 0; x < long; x++) {
      for (int y = 0; y < long; y++) {
        final value = (size * y + x) + 1;
        tileOffsets[value] = TileModel(
          value: value,
          correctPosition: Offset(x.toDouble(), y.toDouble()),
          currentPosition: Offset(x.toDouble(), y.toDouble()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: PuzzleController.shouldShuffleController.stream,
        builder: (context, snapshot) {
          if (PuzzleController.getShouldShuffle()) {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              shuffle();
            });
            PuzzleController.shouldShuffle = false;
          }
          return Visibility(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AbsorbPointer(
                      absorbing: isFinish || isBlock,
                      child: Container(
                        height: widget.boardSize,
                        width: widget.boardSize,
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          children: tileOffsets
                              .map((key, value) =>
                                  MapEntry(key, renderTile(value)))
                              .values
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget renderTile(TileModel tileModel) {
    final size = widget.tileSize;
    return GestureDetector(
      onTap: () {
        onClick(tileModel);
      },
      child: Tile(
        size: size,
        tile: tileModel,
        isWhiteSpace: tileModel.value == whiteSpaceValue,
      ),
    );
  }

  onClick(TileModel clickedTile) {
    blockInput();
    if (clickedTile.currentPosition.dy == whiteSpaceCurrentPosition.dy &&
        (clickedTile.currentPosition.dx - whiteSpaceCurrentPosition.dx).abs() >
            0) {
      // diff X
      final relatedTiles = tileOffsets.values
          .where((element) =>
              element.currentPosition.dy == clickedTile.currentPosition.dy &&
              element.currentPosition.dx != whiteSpaceCurrentPosition.dx)
          .toList();

      for (final tile in relatedTiles) {
        final delta =
            getDeltaX(tile.currentPosition, clickedTile.currentPosition);
        swapTile(tile,
            Offset(tile.currentPosition.dx + delta, tile.currentPosition.dy));
      }

      swapWhiteSpace(clickedTile.currentPosition);
    } else {
      // same X
      if (clickedTile.currentPosition.dx == whiteSpaceCurrentPosition.dx &&
          (clickedTile.currentPosition.dy - whiteSpaceCurrentPosition.dy)
                  .abs() >
              0) {
        // diff y
        final relatedTiles = tileOffsets.values
            .where((element) =>
                element.currentPosition.dx == clickedTile.currentPosition.dx &&
                element.currentPosition.dy != whiteSpaceCurrentPosition.dy)
            .toList();

        for (final tile in relatedTiles) {
          final delta =
              getDeltaY(tile.currentPosition, clickedTile.currentPosition);
          swapTile(tile,
              Offset(tile.currentPosition.dx, tile.currentPosition.dy + delta));
        }

        swapWhiteSpace(clickedTile.currentPosition);
      }
    }

    var isCorrect = true;

    for (var tile in tileOffsets.values) {
      isCorrect = tile.correctPosition == tile.currentPosition;
      if (!isCorrect) {
        break;
      }
    }

    if (isCorrect) {
      widget.onAllCorrect();
      isFinish = true;
    }
  }

  getDeltaX(
      Offset focusTileCurrentPosition, Offset clickedTileCurrentPosition) {
    return focusTileCurrentPosition.dx > whiteSpaceCurrentPosition.dx &&
            clickedTileCurrentPosition.dx >= focusTileCurrentPosition.dx
        ? -1
        : focusTileCurrentPosition.dx < whiteSpaceCurrentPosition.dx &&
                clickedTileCurrentPosition.dx <= focusTileCurrentPosition.dx
            ? 1
            : 0;
  }

  getDeltaY(
      Offset focusTileCurrentPosition, Offset clickedTileCurrentPosition) {
    return focusTileCurrentPosition.dy > whiteSpaceCurrentPosition.dy &&
            clickedTileCurrentPosition.dy >= focusTileCurrentPosition.dy
        ? -1
        : focusTileCurrentPosition.dy < whiteSpaceCurrentPosition.dy &&
                clickedTileCurrentPosition.dy <= focusTileCurrentPosition.dy
            ? 1
            : 0;
  }

  swapWhiteSpace(Offset clickedTileCurrentPosition) {
    whiteSpaceCurrentPosition = clickedTileCurrentPosition;
    swapTile(tileOffsets[whiteSpaceValue]!, whiteSpaceCurrentPosition);
  }

  swapTile(TileModel selectedTile, Offset targetPosition) {
    setState(() {
      tileOffsets[selectedTile.value] = tileOffsets[selectedTile.value]!
          .copyWith(newPosition: targetPosition);
    });
  }

  blockInput() {
    setState(() {
      isBlock = true;
    });
    Future.delayed(
      const Duration(milliseconds: 300),
      () => {
        setState(() {
          isBlock = false;
        })
      },
    );
  }

  shuffle() {
    do {
      final randomNumbers = List.generate(size * size, (index) => index + 1)
        ..shuffle();

      for (var i = 0; i < randomNumbers.length; i++) {
        if (tileOffsets[randomNumbers[i]] != null) {
          tileOffsets[randomNumbers[i]] = tileOffsets[randomNumbers[i]]!
              .copyWith(newPosition: tileOffsets[i + 1]!.correctPosition);
        }
      }

      whiteSpaceCurrentPosition = tileOffsets[whiteSpaceValue]!.currentPosition;
    } while (!isSolvable() ||
        !tileOffsets.values.any(
            (element) => element.correctPosition == element.currentPosition));

    setState(() {
      isFinish = false;
      tileOffsets;
    });
  }

  bool isSolvable() {
    final inversions = countInversions();

    if (size.isOdd) {
      return inversions.isEven;
    }

    final whitespace = tileOffsets[whiteSpaceValue];
    final whitespaceRow = whitespace!.currentPosition.dy.toInt();

    if (((size - whitespaceRow) + 1).isOdd) {
      return inversions.isEven;
    } else {
      return inversions.isOdd;
    }
  }

  /// Gives the number of inversions in a puzzle given its tile arrangement.
  ///
  /// An inversion is when a tile of a lower value is in a greater position than
  /// a tile of a higher value.
  int countInversions() {
    var count = 0;
    for (var a = 0; a < size; a++) {
      final tileA = tileOffsets[a + 1];
      if (tileA!.value == whiteSpaceValue) {
        continue;
      }

      for (var b = a + 1; b < size; b++) {
        final tileB = tileOffsets[b + 1];
        if (_isInversion(tileA, tileB!)) {
          count++;
        }
      }
    }
    return count;
  }

  /// Determines if the two tiles are inverted.
  bool _isInversion(TileModel a, TileModel b) {
    if (b != tileOffsets[whiteSpaceValue] && a.value != b.value) {
      if (b.value < a.value) {
        return compareTo(b.currentPosition, a.currentPosition) > 0;
      } else {
        return compareTo(a.currentPosition, b.currentPosition) > 0;
      }
    }
    return false;
  }

  int compareTo(Offset origin, Offset other) {
    if (origin.dy < other.dy) {
      return -1;
    } else if (origin.dy > other.dy) {
      return 1;
    } else {
      if (origin.dx < other.dx) {
        return -1;
      } else if (origin.dx > other.dx) {
        return 1;
      } else {
        return 0;
      }
    }
  }
}
