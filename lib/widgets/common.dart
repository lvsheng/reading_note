import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

const borderRadius = BorderRadius.all(Radius.circular(3));
final borderDecoration = BoxDecoration(border: Border.all(), borderRadius: borderRadius);
final buttonDecorationDisable = borderDecoration.copyWith(border: Border.all(color: CupertinoColors.systemGrey));
const mainButtonSize = 30.0;
const operatingAreaSize = 300.0;
const panelPadding = 0.0;

const buttonHeight = 150.0;
Widget buildConfirmButton(VoidCallback? onPressed) => buildButton(onPressed, material.Icons.check, CupertinoColors.activeBlue);

Widget buildButton(VoidCallback? onPressed, IconData icon, Color color) => CupertinoButton(
  onPressed: onPressed,
  child: Container(
    height: buttonHeight,
    width: operatingAreaSize,
    decoration: onPressed != null ? borderDecoration.copyWith(border: Border.all(color: color)) : buttonDecorationDisable,
    child: Icon(icon, color: onPressed != null ? color : CupertinoColors.systemGrey),
  ),
);
