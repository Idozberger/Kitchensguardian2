import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_item_entity.dart';

class ScanItemModel extends ScanItemEntity {
  ScanItemModel({
    required super.amount,
    required super.name,
    required super.unit,
    required super.thumbnail,
  });

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    return ScanItemModel(
      amount: (json['amount'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      thumbnail: _parseThumbnail(json['thumbnail']),
    );
  }
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'name': name,
    'unit': unit,
    'thumbnail': thumbnail,
  };
  static Uint8List _parseThumbnail(dynamic thumbnailData) {
    if (thumbnailData == null) {
      return Uint8List(0);
    }

    if (thumbnailData is Uint8List) {
      return thumbnailData;
    }

    if (thumbnailData is List) {
      try {
        return Uint8List.fromList(thumbnailData.cast<int>());
      } catch (e) {
        return Uint8List.fromList(thumbnailData.map((e) => e as int).toList());
      }
    }

    if (thumbnailData is String) {
      try {
        String base64String = thumbnailData.trim();

        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        base64String = base64String.replaceAll(RegExp(r'\s+'), '');

        return base64Decode(base64String);
      } catch (e) {
        return Uint8List(0);
      }
    }

    debugPrint('Unsupported thumbnail type: ${thumbnailData.runtimeType}');
    return Uint8List(0);
  }
}
