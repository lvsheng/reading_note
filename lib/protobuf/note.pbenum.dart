//
//  Generated code. Do not modify.
//  source: note.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PenType extends $pb.ProtobufEnum {
  static const PenType PT_BALL_POINT_PEN = PenType._(0, _omitEnumNames ? '' : 'PT_BALL_POINT_PEN');
  static const PenType PT_MARK_PEN = PenType._(1, _omitEnumNames ? '' : 'PT_MARK_PEN');

  static const $core.List<PenType> values = <PenType> [
    PT_BALL_POINT_PEN,
    PT_MARK_PEN,
  ];

  static final $core.Map<$core.int, PenType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PenType? valueOf($core.int value) => _byValue[value];

  const PenType._($core.int v, $core.String n) : super(v, n);
}

class ImageType extends $pb.ProtobufEnum {
  static const ImageType IT_2BIT_1CHANNEL = ImageType._(0, _omitEnumNames ? '' : 'IT_2BIT_1CHANNEL');

  static const $core.List<ImageType> values = <ImageType> [
    IT_2BIT_1CHANNEL,
  ];

  static final $core.Map<$core.int, ImageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ImageType? valueOf($core.int value) => _byValue[value];

  const ImageType._($core.int v, $core.String n) : super(v, n);
}

class DecorationType extends $pb.ProtobufEnum {
  static const DecorationType DT_BG_RED = DecorationType._(0, _omitEnumNames ? '' : 'DT_BG_RED');
  static const DecorationType DT_BG_PURPLE = DecorationType._(1, _omitEnumNames ? '' : 'DT_BG_PURPLE');
  static const DecorationType DT_BG_BLUE = DecorationType._(2, _omitEnumNames ? '' : 'DT_BG_BLUE');
  static const DecorationType DT_BG_GREEN = DecorationType._(3, _omitEnumNames ? '' : 'DT_BG_GREEN');
  static const DecorationType DT_BG_YELLOW = DecorationType._(4, _omitEnumNames ? '' : 'DT_BG_YELLOW');
  static const DecorationType DT_UNDERLINE_RED = DecorationType._(10, _omitEnumNames ? '' : 'DT_UNDERLINE_RED');
  static const DecorationType DT_UNDERLINE_PURPLE = DecorationType._(11, _omitEnumNames ? '' : 'DT_UNDERLINE_PURPLE');
  static const DecorationType DT_UNDERLINE_BLUE = DecorationType._(12, _omitEnumNames ? '' : 'DT_UNDERLINE_BLUE');
  static const DecorationType DT_UNDERLINE_GREEN = DecorationType._(13, _omitEnumNames ? '' : 'DT_UNDERLINE_GREEN');
  static const DecorationType DT_UNDERLINE_YELLOW = DecorationType._(14, _omitEnumNames ? '' : 'DT_UNDERLINE_YELLOW');
  static const DecorationType DT_TILDE_RED = DecorationType._(20, _omitEnumNames ? '' : 'DT_TILDE_RED');
  static const DecorationType DT_TILDE_PURPLE = DecorationType._(21, _omitEnumNames ? '' : 'DT_TILDE_PURPLE');
  static const DecorationType DT_TILDE_BLUE = DecorationType._(22, _omitEnumNames ? '' : 'DT_TILDE_BLUE');
  static const DecorationType DT_TILDE_GREEN = DecorationType._(23, _omitEnumNames ? '' : 'DT_TILDE_GREEN');
  static const DecorationType DT_TILDE_YELLOW = DecorationType._(24, _omitEnumNames ? '' : 'DT_TILDE_YELLOW');

  static const $core.List<DecorationType> values = <DecorationType> [
    DT_BG_RED,
    DT_BG_PURPLE,
    DT_BG_BLUE,
    DT_BG_GREEN,
    DT_BG_YELLOW,
    DT_UNDERLINE_RED,
    DT_UNDERLINE_PURPLE,
    DT_UNDERLINE_BLUE,
    DT_UNDERLINE_GREEN,
    DT_UNDERLINE_YELLOW,
    DT_TILDE_RED,
    DT_TILDE_PURPLE,
    DT_TILDE_BLUE,
    DT_TILDE_GREEN,
    DT_TILDE_YELLOW,
  ];

  static final $core.Map<$core.int, DecorationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DecorationType? valueOf($core.int value) => _byValue[value];

  const DecorationType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
