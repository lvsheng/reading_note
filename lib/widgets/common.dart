import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

const borderRadius = BorderRadius.all(Radius.circular(3));
final borderDecoration = BoxDecoration(border: Border.all(), borderRadius: borderRadius);
final buttonDecorationDisable = borderDecoration.copyWith(border: Border.all(color: CupertinoColors.systemGrey));
const mainButtonSize = 30.0;
const operatingAreaSize = 300.0;
const panelPadding = 0.0;

const buttonHeight = 150.0;

const buttonPadding = 16.0;

Widget buildConfirmButton(VoidCallback? onPressed, {double widthFactor = 1.0, double heightFactor = 1.0, EdgeInsets? padding}) =>
    buildButton(onPressed, material.Icons.check, CupertinoColors.activeBlue,
        widthFactor: widthFactor, heightFactor: heightFactor, padding: padding);

Widget buildButton(VoidCallback? onPressed, IconData icon, Color color,
        {double widthFactor = 1.0, double heightFactor = 1.0, EdgeInsets? padding}) =>
    CupertinoButton(
      onPressed: onPressed,
      padding: padding,
      child: Container(
        height: buttonHeight * heightFactor,
        width: operatingAreaSize * widthFactor,
        decoration: onPressed != null ? borderDecoration.copyWith(border: Border.all(color: color)) : buttonDecorationDisable,
        child: Icon(icon, color: onPressed != null ? color : CupertinoColors.systemGrey),
      ),
    );
