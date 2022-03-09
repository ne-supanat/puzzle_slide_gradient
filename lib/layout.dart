import 'package:flutter/material.dart';

import 'board.dart';
import 'puzzle_controller.dart';
import 'puzzle_style.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({Key? key}) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => ResponsiveLayoutState();
}

class ResponsiveLayoutState extends State<ResponsiveLayout> {
  var isReady = false;

  static const String staterText = 'Puzzle Challenge';
  var titleText = staterText;
  var gapSize = 0.0;

  var screenWidth = PuzzleSize.smallScreenWidth;

  var size = 4;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(
          Duration(milliseconds: 20 * size * size + 400),
          () => {
                setState(() {
                  isReady = true;
                })
              });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    gapSize = screenWidth > PuzzleSize.mediumScreenWidth
        ? PuzzleSize.largeGapSize
        : screenWidth > PuzzleSize.smallScreenWidth
            ? PuzzleSize.mediumGapSize
            : PuzzleSize.smallGapSize;
    return Scaffold(
      backgroundColor: PuzzleColor.bgGradient[0],
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: PuzzleColor.bgGradient,
              ),
            ),
            alignment: Alignment.bottomRight,
          ),
          SingleChildScrollView(
            child: screenWidth > PuzzleSize.mediumScreenWidth
                ? largeScreen()
                : screenWidth > PuzzleSize.smallScreenWidth
                    ? mediumScreen()
                    : smallScreen(),
          ),
          Visibility(
              visible: !isReady,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: PuzzleColor.bgGradient,
                  ),
                ),
                child: const Center(
                    child: CircularProgressIndicator(color: PuzzleColor.white)),
              ))
        ],
      ),
    );
  }

  smallScreen() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Container()),
        Flex(
            direction: Axis.vertical,
            children: [titleComponent(), gapSpaceVertical(), boardPart()]),
        Expanded(child: Container()),
      ],
    );
  }

  mediumScreen() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Container()),
        Flex(
            direction: Axis.horizontal,
            children: [titleComponent(), gapSpaceHorizontal(), boardPart()]),
        Expanded(child: Container()),
      ],
    );
  }

  largeScreen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: titleComponent()),
        Flex(direction: Axis.horizontal, children: [boardPart()]),
        Expanded(child: Container()),
      ],
    );
  }

  titleComponent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titleText,
          style: PuzzleTextStyle.headline3.copyWith(color: PuzzleColor.white),
        ),
        const SizedBox(height: 16),
        TextButton(
            style: TextButton.styleFrom(
              backgroundColor: PuzzleColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: onShuffle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.restart_alt_rounded,
                  color: PuzzleColor.text,
                ),
                const SizedBox(width: 4),
                Text(
                  'Shuffle',
                  style: PuzzleTextStyle.body3,
                )
              ],
            ))
      ],
    );
  }

  boardPart() {
    return screenWidth > PuzzleSize.mediumScreenWidth
        ? Board.large(size, onAllCorrect)
        : screenWidth > PuzzleSize.smallScreenWidth
            ? Board.medium(size, onAllCorrect)
            : Board.small(size, onAllCorrect);
  }

  gapSpaceVertical() {
    return SizedBox(
      height: gapSize,
    );
  }

  gapSpaceHorizontal() {
    return SizedBox(
      width: gapSize,
    );
  }

  onAllCorrect() {
    setState(() {
      titleText = 'Well done. Congrats!';
    });
  }

  onShuffle() {
    PuzzleController.setShouldShuffle(true);
    setState(() {
      titleText = staterText;
    });
  }
}
