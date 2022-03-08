import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'model/tile_model.dart';
import 'puzzle_style.dart';

class Tile extends StatefulWidget {
  const Tile({
    Key? key,
    required this.size,
    required this.tile,
    this.isWhiteSpace = false,
  }) : super(key: key);

  final double size;
  final TileModel tile;
  final bool isWhiteSpace;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'state_machine');
    artboard.addController(controller!);

    SMITrigger? player;

    final v = (widget.tile.correctPosition.dx + widget.tile.correctPosition.dy)
        .toInt();
    switch (v) {
      case 0:
        player = controller.findInput<bool>('play01') as SMITrigger;
        break;
      case 1:
        player = controller.findInput<bool>('play02') as SMITrigger;
        break;
      case 2:
        player = controller.findInput<bool>('play03') as SMITrigger;
        break;
      case 3:
        player = controller.findInput<bool>('play04') as SMITrigger;
        break;
      case 4:
        player = controller.findInput<bool>('play05') as SMITrigger;
        break;
      case 5:
        player = controller.findInput<bool>('play06') as SMITrigger;
        break;
      default:
    }

    player?.fire();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 370),
      alignment: FractionalOffset(widget.tile.currentPosition.dx / (4 - 1),
          widget.tile.currentPosition.dy / (4 - 1)),
      child: Container(
        height: widget.size,
        width: widget.size,
        padding: const EdgeInsets.all(4),
        child: Container(
          child: widget.isWhiteSpace
              ? null
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    RiveAnimation.asset(
                      'gradient_loop.riv',
                      animations: [getAnimation()],
                    ),
                    Text(widget.tile.value.toString(),
                        style: PuzzleTextStyle.headline3),
                  ],
                ),
        ),
      ),
    );
  }

  String getAnimation() {
    final v = (widget.tile.correctPosition.dx + widget.tile.correctPosition.dy)
        .toInt();

    switch (v) {
      case 0:
        return 'begin01';
      case 1:
        return 'begin02';
      case 2:
        return 'begin03';
      case 3:
        return 'begin04';
      case 4:
        return 'begin05';
      case 5:
        return 'begin06';
      default:
        return '';
    }
  }
}
