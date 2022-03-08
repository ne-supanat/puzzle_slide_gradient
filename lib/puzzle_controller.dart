import 'dart:async';

class PuzzleController {
  static bool shouldShuffle = false;
  static StreamController<bool> shouldShuffleController =
      StreamController.broadcast();

  static setShouldShuffle(value) {
    shouldShuffle = value;
    shouldShuffleController.add(shouldShuffle);
  }

  static getShouldShuffle() => shouldShuffle;
}
