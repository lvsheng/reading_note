import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

const borderRadius = BorderRadius.all(Radius.circular(3));
final borderDecoration = BoxDecoration(border: Border.all(), borderRadius: borderRadius);
final buttonDecoration = borderDecoration.copyWith(border: Border.all(color: CupertinoColors.activeBlue));
final buttonDecorationDisable = borderDecoration.copyWith(border: Border.all(color: CupertinoColors.systemGrey));
const mainButtonSize = 30.0;
const operatingAreaSize = 300.0;
const panelPadding = 0.0;

Widget buildConfirmButton(VoidCallback? onPressed) => CupertinoButton(
  onPressed: onPressed,
  child: Container(
    height: 150,
    width: operatingAreaSize,
    decoration: onPressed != null ? buttonDecoration : buttonDecorationDisable,
    child: Icon(material.Icons.check, color: onPressed != null ? CupertinoColors.activeBlue : CupertinoColors.systemGrey),
  ),
);
