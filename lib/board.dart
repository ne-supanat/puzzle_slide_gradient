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
      simulationShuffle();
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
              simulationShuffle();
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

  simulationShuffle() {
    for (var i = 0; i < 40; i++) {
      final whitePos = whiteSpaceCurrentPosition;

      double focusX = 0, focusY = 0;
      final group = <TileModel>[];
      if (whitePos.dx == size - 1) {
        focusX = whitePos.dx - 1;
        focusY = findPossibleY(whitePos.dy);
        group.addAll(findFocusGroup(focusX, focusY));
      } else if (whitePos.dx == 0) {
        focusX = whitePos.dx + 1;
        focusY = findPossibleY(whitePos.dy);
        group.addAll(findFocusGroup(focusX, focusY));
      } else {
        if (Random().nextBool()) {
          focusX = whitePos.dx + 1;
        } else {
          focusX = whitePos.dx - 1;
        }
        focusY = findPossibleY(whitePos.dy);
        group.addAll(findFocusGroup(focusX, focusY));
      }
      rotateFocusTileGroup(group);
    }

    setState(() {
      isFinish = false;
      tileOffsets;
    });
  }

  double findPossibleY(double whitePosY) {
    var focusY = whitePosY;
    if (whitePosY == 0) {
      focusY = whitePosY + 1;
    } else if (whitePosY == size - 1) {
      focusY = whitePosY - 1;
    } else {
      if (Random().nextBool()) {
        focusY = whitePosY + 1;
      } else {
        focusY = whitePosY - 1;
      }
    }

    return focusY;
  }

  List<TileModel> findFocusGroup(double focusX, double focusY) {
    return tileOffsets.values
        .where((tile) => isInGroup(tile, focusX, focusY))
        .toList();
  }

  isInGroup(TileModel tile, double focusX, double focusY) {
    return tile.currentPosition ==
            Offset(whiteSpaceCurrentPosition.dx, focusY) ||
        tile.currentPosition == Offset(focusX, whiteSpaceCurrentPosition.dy) ||
        tile.currentPosition == Offset(focusX, focusY);
  }

  rotateFocusTileGroup(List<TileModel> group) {
    final t1 = tileOffsets[whiteSpaceValue]!;
    final t2 = group.firstWhere((tile) =>
        tile.currentPosition.dy == t1.currentPosition.dy &&
        tile.currentPosition != t1.currentPosition);
    final t3 = group.firstWhere((tile) =>
        tile.currentPosition.dx == t2.currentPosition.dx &&
        tile.currentPosition != t2.currentPosition);
    final t4 = group.firstWhere((tile) =>
        tile.currentPosition.dy == t3.currentPosition.dy &&
        tile.currentPosition != t3.currentPosition);

    final sortGroup = [t1, t2, t3, t4];
    final refGroup = List<TileModel>.from(sortGroup);
    final shiftTime = Random().nextInt(4);

    for (var i = 0; i < 4; i++) {
      final trimShiftTime = (i + shiftTime) % 4;
      final focusValue = sortGroup[i].value;
      tileOffsets[focusValue] = tileOffsets[focusValue]!
          .copyWith(newPosition: refGroup[trimShiftTime].currentPosition);
    }
    whiteSpaceCurrentPosition = tileOffsets[whiteSpaceValue]!.currentPosition;
  }
}
