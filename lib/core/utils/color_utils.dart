import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  /// '#8B0000' 形式のHEX文字列をColorに変換
  static Color hexToColor(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }

  /// ColorをHEX文字列に変換
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
