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

  static const $core.List<PenType> values = <PenType> [
    PT_BALL_POINT_PEN,
  ];

  static final $core.Map<$core.int, PenType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PenType? valueOf($core.int value) => _byValue[value];

  const PenType._($core.int v, $core.String n) : super(v, n);
}

class ImageType extends $pb.ProtobufEnum {
  static const ImageType IT_PNG = ImageType._(0, _omitEnumNames ? '' : 'IT_PNG');

  static const $core.List<ImageType> values = <ImageType> [
    IT_PNG,
  ];

  static final $core.Map<$core.int, ImageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ImageType? valueOf($core.int value) => _byValue[value];

  const ImageType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
