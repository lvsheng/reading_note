import 'package:flutter/cupertino.dart';

const borderRadius = BorderRadius.all(Radius.circular(3));
final borderDecoration = BoxDecoration(border: Border.all(), borderRadius: borderRadius);
final buttonDecoration = borderDecoration.copyWith(border: Border.all(color: CupertinoColors.activeBlue));
