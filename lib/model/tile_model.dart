import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TileModel extends Equatable {
  const TileModel({
    required this.value,
    required this.correctPosition,
    required this.currentPosition,
  });

  final int value;
  final Offset correctPosition;
  final Offset currentPosition;

  TileModel copyWith({required Offset newPosition}) {
    return TileModel(
      value: value,
      correctPosition: correctPosition,
      currentPosition: newPosition,
    );
  }

  @override
  List<Object> get props => [
        value,
        correctPosition,
        currentPosition,
      ];
}
