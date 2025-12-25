import 'package:flutter/foundation.dart';

/// Represents a single tile in the 2048 game grid
@immutable
class Tile {
  final int value;
  final int row;
  final int col;
  final String id;
  final bool isNew;
  final bool isMerged;

  const Tile({
    required this.value,
    required this.row,
    required this.col,
    required this.id,
    this.isNew = false,
    this.isMerged = false,
  });

  Tile copyWith({
    int? value,
    int? row,
    int? col,
    String? id,
    bool? isNew,
    bool? isMerged,
  }) {
    return Tile(
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      id: id ?? this.id,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile &&
        other.value == value &&
        other.row == row &&
        other.col == col &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(value, row, col, id);

  @override
  String toString() => 'Tile(value: $value, row: $row, col: $col, id: $id)';
}

