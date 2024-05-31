//
//  Generated code. Do not modify.
//  source: note.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use penTypeDescriptor instead')
const PenType$json = {
  '1': 'PenType',
  '2': [
    {'1': 'PT_BALL_POINT_PEN', '2': 0},
    {'1': 'PT_MARK_PEN', '2': 1},
  ],
};

/// Descriptor for `PenType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List penTypeDescriptor = $convert.base64Decode(
    'CgdQZW5UeXBlEhUKEVBUX0JBTExfUE9JTlRfUEVOEAASDwoLUFRfTUFSS19QRU4QAQ==');

@$core.Deprecated('Use imageTypeDescriptor instead')
const ImageType$json = {
  '1': 'ImageType',
  '2': [
    {'1': 'IT_2BIT_1CHANNEL', '2': 0},
  ],
};

/// Descriptor for `ImageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List imageTypeDescriptor = $convert.base64Decode(
    'CglJbWFnZVR5cGUSFAoQSVRfMkJJVF8xQ0hBTk5FTBAA');

@$core.Deprecated('Use noteBookMetaDescriptor instead')
const NoteBookMeta$json = {
  '1': 'NoteBookMeta',
  '2': [
    {'1': 'lastPageId', '3': 1, '4': 1, '5': 13, '10': 'lastPageId'},
    {'1': 'pages', '3': 2, '4': 3, '5': 11, '6': '.NoteBookMeta.PagesEntry', '10': 'pages'},
  ],
  '3': [NoteBookMeta_PagesEntry$json],
};

@$core.Deprecated('Use noteBookMetaDescriptor instead')
const NoteBookMeta_PagesEntry$json = {
  '1': 'PagesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `NoteBookMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteBookMetaDescriptor = $convert.base64Decode(
    'CgxOb3RlQm9va01ldGESHgoKbGFzdFBhZ2VJZBgBIAEoDVIKbGFzdFBhZ2VJZBIuCgVwYWdlcx'
    'gCIAMoCzIYLk5vdGVCb29rTWV0YS5QYWdlc0VudHJ5UgVwYWdlcxo4CgpQYWdlc0VudHJ5EhAK'
    'A2tleRgBIAEoDVIDa2V5EhQKBXZhbHVlGAIgASgNUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use notePageDescriptor instead')
const NotePage$json = {
  '1': 'NotePage',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 2, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 2, '10': 'height'},
    {'1': 'items', '3': 3, '4': 3, '5': 11, '6': '.NotePageItem', '10': 'items'},
    {'1': 'independentNoteData', '3': 4, '4': 1, '5': 11, '6': '.IndependentNotePageData', '9': 0, '10': 'independentNoteData'},
    {'1': 'markNoteData', '3': 5, '4': 1, '5': 11, '6': '.MarkNotePageData', '9': 0, '10': 'markNoteData'},
    {'1': 'penPool', '3': 6, '4': 3, '5': 11, '6': '.NotePage.PenPoolEntry', '10': 'penPool'},
  ],
  '3': [NotePage_PenPoolEntry$json],
  '8': [
    {'1': 'content'},
  ],
};

@$core.Deprecated('Use notePageDescriptor instead')
const NotePage_PenPoolEntry$json = {
  '1': 'PenPoolEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.Pen', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `NotePage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notePageDescriptor = $convert.base64Decode(
    'CghOb3RlUGFnZRIUCgV3aWR0aBgBIAEoAlIFd2lkdGgSFgoGaGVpZ2h0GAIgASgCUgZoZWlnaH'
    'QSIwoFaXRlbXMYAyADKAsyDS5Ob3RlUGFnZUl0ZW1SBWl0ZW1zEkwKE2luZGVwZW5kZW50Tm90'
    'ZURhdGEYBCABKAsyGC5JbmRlcGVuZGVudE5vdGVQYWdlRGF0YUgAUhNpbmRlcGVuZGVudE5vdG'
    'VEYXRhEjcKDG1hcmtOb3RlRGF0YRgFIAEoCzIRLk1hcmtOb3RlUGFnZURhdGFIAFIMbWFya05v'
    'dGVEYXRhEjAKB3BlblBvb2wYBiADKAsyFi5Ob3RlUGFnZS5QZW5Qb29sRW50cnlSB3BlblBvb2'
    'waQAoMUGVuUG9vbEVudHJ5EhAKA2tleRgBIAEoDVIDa2V5EhoKBXZhbHVlGAIgASgLMgQuUGVu'
    'UgV2YWx1ZToCOAFCCQoHY29udGVudA==');

@$core.Deprecated('Use independentNotePageDataDescriptor instead')
const IndependentNotePageData$json = {
  '1': 'IndependentNotePageData',
  '2': [
    {'1': 'lastMatteId', '3': 1, '4': 1, '5': 13, '10': 'lastMatteId'},
    {'1': 'mattePool', '3': 2, '4': 3, '5': 11, '6': '.IndependentNotePageData.MattePoolEntry', '10': 'mattePool'},
  ],
  '3': [IndependentNotePageData_MattePoolEntry$json],
};

@$core.Deprecated('Use independentNotePageDataDescriptor instead')
const IndependentNotePageData_MattePoolEntry$json = {
  '1': 'MattePoolEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.Matte', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `IndependentNotePageData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List independentNotePageDataDescriptor = $convert.base64Decode(
    'ChdJbmRlcGVuZGVudE5vdGVQYWdlRGF0YRIgCgtsYXN0TWF0dGVJZBgBIAEoDVILbGFzdE1hdH'
    'RlSWQSRQoJbWF0dGVQb29sGAIgAygLMicuSW5kZXBlbmRlbnROb3RlUGFnZURhdGEuTWF0dGVQ'
    'b29sRW50cnlSCW1hdHRlUG9vbBpECg5NYXR0ZVBvb2xFbnRyeRIQCgNrZXkYASABKA1SA2tleR'
    'IcCgV2YWx1ZRgCIAEoCzIGLk1hdHRlUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use markNotePageDataDescriptor instead')
const MarkNotePageData$json = {
  '1': 'MarkNotePageData',
  '2': [
    {'1': 'lastMattingMarkId', '3': 1, '4': 1, '5': 13, '10': 'lastMattingMarkId'},
    {'1': 'mattingMarkPool', '3': 2, '4': 3, '5': 11, '6': '.MarkNotePageData.MattingMarkPoolEntry', '10': 'mattingMarkPool'},
  ],
  '3': [MarkNotePageData_MattingMarkPoolEntry$json],
};

@$core.Deprecated('Use markNotePageDataDescriptor instead')
const MarkNotePageData_MattingMarkPoolEntry$json = {
  '1': 'MattingMarkPoolEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.MattingMark', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MarkNotePageData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markNotePageDataDescriptor = $convert.base64Decode(
    'ChBNYXJrTm90ZVBhZ2VEYXRhEiwKEWxhc3RNYXR0aW5nTWFya0lkGAEgASgNUhFsYXN0TWF0dG'
    'luZ01hcmtJZBJQCg9tYXR0aW5nTWFya1Bvb2wYAiADKAsyJi5NYXJrTm90ZVBhZ2VEYXRhLk1h'
    'dHRpbmdNYXJrUG9vbEVudHJ5Ug9tYXR0aW5nTWFya1Bvb2waUAoUTWF0dGluZ01hcmtQb29sRW'
    '50cnkSEAoDa2V5GAEgASgNUgNrZXkSIgoFdmFsdWUYAiABKAsyDC5NYXR0aW5nTWFya1IFdmFs'
    'dWU6AjgB');

@$core.Deprecated('Use notePageItemDescriptor instead')
const NotePageItem$json = {
  '1': 'NotePageItem',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
    {'1': 'path', '3': 3, '4': 1, '5': 11, '6': '.Path', '9': 0, '10': 'path'},
    {'1': 'mattingMarkId', '3': 4, '4': 1, '5': 13, '9': 0, '10': 'mattingMarkId'},
    {'1': 'matteId', '3': 5, '4': 1, '5': 13, '9': 0, '10': 'matteId'},
    {'1': 'scale', '3': 6, '4': 1, '5': 2, '9': 1, '10': 'scale', '17': true},
  ],
  '8': [
    {'1': 'content'},
    {'1': '_scale'},
  ],
};

/// Descriptor for `NotePageItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notePageItemDescriptor = $convert.base64Decode(
    'CgxOb3RlUGFnZUl0ZW0SDAoBeBgBIAEoAlIBeBIMCgF5GAIgASgCUgF5EhsKBHBhdGgYAyABKA'
    'syBS5QYXRoSABSBHBhdGgSJgoNbWF0dGluZ01hcmtJZBgEIAEoDUgAUg1tYXR0aW5nTWFya0lk'
    'EhoKB21hdHRlSWQYBSABKA1IAFIHbWF0dGVJZBIZCgVzY2FsZRgGIAEoAkgBUgVzY2FsZYgBAU'
    'IJCgdjb250ZW50QggKBl9zY2FsZQ==');

@$core.Deprecated('Use pathDescriptor instead')
const Path$json = {
  '1': 'Path',
  '2': [
    {'1': 'penId', '3': 1, '4': 1, '5': 13, '10': 'penId'},
    {'1': 'points', '3': 2, '4': 3, '5': 11, '6': '.Point', '10': 'points'},
  ],
};

/// Descriptor for `Path`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pathDescriptor = $convert.base64Decode(
    'CgRQYXRoEhQKBXBlbklkGAEgASgNUgVwZW5JZBIeCgZwb2ludHMYAiADKAsyBi5Qb2ludFIGcG'
    '9pbnRz');

@$core.Deprecated('Use penDescriptor instead')
const Pen$json = {
  '1': 'Pen',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.PenType', '10': 'type'},
    {'1': 'color', '3': 2, '4': 1, '5': 13, '10': 'color'},
    {'1': 'lineWidth', '3': 3, '4': 1, '5': 2, '10': 'lineWidth'},
  ],
};

/// Descriptor for `Pen`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penDescriptor = $convert.base64Decode(
    'CgNQZW4SHAoEdHlwZRgBIAEoDjIILlBlblR5cGVSBHR5cGUSFAoFY29sb3IYAiABKA1SBWNvbG'
    '9yEhwKCWxpbmVXaWR0aBgDIAEoAlIJbGluZVdpZHRo');

@$core.Deprecated('Use pointDescriptor instead')
const Point$json = {
  '1': 'Point',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
  ],
};

/// Descriptor for `Point`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointDescriptor = $convert.base64Decode(
    'CgVQb2ludBIMCgF4GAEgASgCUgF4EgwKAXkYAiABKAJSAXk=');

@$core.Deprecated('Use matteDescriptor instead')
const Matte$json = {
  '1': 'Matte',
  '2': [
    {'1': 'bookPageNumber', '3': 1, '4': 1, '5': 13, '10': 'bookPageNumber'},
    {'1': 'bookPageMattingMarkId', '3': 2, '4': 1, '5': 13, '10': 'bookPageMattingMarkId'},
    {'1': 'imageType', '3': 3, '4': 1, '5': 14, '6': '.ImageType', '9': 0, '10': 'imageType', '17': true},
    {'1': 'imageWidth', '3': 4, '4': 1, '5': 13, '10': 'imageWidth'},
    {'1': 'imageHeight', '3': 5, '4': 1, '5': 13, '10': 'imageHeight'},
    {'1': 'imageData', '3': 6, '4': 1, '5': 12, '10': 'imageData'},
    {'1': 'bookPath', '3': 7, '4': 1, '5': 9, '9': 1, '10': 'bookPath', '17': true},
  ],
  '8': [
    {'1': '_imageType'},
    {'1': '_bookPath'},
  ],
};

/// Descriptor for `Matte`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matteDescriptor = $convert.base64Decode(
    'CgVNYXR0ZRImCg5ib29rUGFnZU51bWJlchgBIAEoDVIOYm9va1BhZ2VOdW1iZXISNAoVYm9va1'
    'BhZ2VNYXR0aW5nTWFya0lkGAIgASgNUhVib29rUGFnZU1hdHRpbmdNYXJrSWQSLQoJaW1hZ2VU'
    'eXBlGAMgASgOMgouSW1hZ2VUeXBlSABSCWltYWdlVHlwZYgBARIeCgppbWFnZVdpZHRoGAQgAS'
    'gNUgppbWFnZVdpZHRoEiAKC2ltYWdlSGVpZ2h0GAUgASgNUgtpbWFnZUhlaWdodBIcCglpbWFn'
    'ZURhdGEYBiABKAxSCWltYWdlRGF0YRIfCghib29rUGF0aBgHIAEoCUgBUghib29rUGF0aIgBAU'
    'IMCgpfaW1hZ2VUeXBlQgsKCV9ib29rUGF0aA==');

@$core.Deprecated('Use mattingMarkDescriptor instead')
const MattingMark$json = {
  '1': 'MattingMark',
  '2': [
    {'1': 'color', '3': 1, '4': 1, '5': 13, '9': 1, '10': 'color', '17': true},
    {'1': 'horizontal', '3': 2, '4': 1, '5': 11, '6': '.MattingMarkHorizontal', '9': 0, '10': 'horizontal'},
    {'1': 'vertical', '3': 3, '4': 1, '5': 11, '6': '.MattingMarkVertical', '9': 0, '10': 'vertical'},
    {'1': 'line', '3': 4, '4': 1, '5': 11, '6': '.MattingMarkLine', '9': 0, '10': 'line'},
    {'1': 'rectangle', '3': 5, '4': 1, '5': 11, '6': '.MattingMarkRectangle', '9': 0, '10': 'rectangle'},
    {'1': 'linkingIndependentNoteId', '3': 6, '4': 3, '5': 13, '10': 'linkingIndependentNoteId'},
  ],
  '8': [
    {'1': 'content'},
    {'1': '_color'},
  ],
};

/// Descriptor for `MattingMark`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mattingMarkDescriptor = $convert.base64Decode(
    'CgtNYXR0aW5nTWFyaxIZCgVjb2xvchgBIAEoDUgBUgVjb2xvcogBARI4Cgpob3Jpem9udGFsGA'
    'IgASgLMhYuTWF0dGluZ01hcmtIb3Jpem9udGFsSABSCmhvcml6b250YWwSMgoIdmVydGljYWwY'
    'AyABKAsyFC5NYXR0aW5nTWFya1ZlcnRpY2FsSABSCHZlcnRpY2FsEiYKBGxpbmUYBCABKAsyEC'
    '5NYXR0aW5nTWFya0xpbmVIAFIEbGluZRI1CglyZWN0YW5nbGUYBSABKAsyFS5NYXR0aW5nTWFy'
    'a1JlY3RhbmdsZUgAUglyZWN0YW5nbGUSOgoYbGlua2luZ0luZGVwZW5kZW50Tm90ZUlkGAYgAy'
    'gNUhhsaW5raW5nSW5kZXBlbmRlbnROb3RlSWRCCQoHY29udGVudEIICgZfY29sb3I=');

@$core.Deprecated('Use mattingMarkHorizontalDescriptor instead')
const MattingMarkHorizontal$json = {
  '1': 'MattingMarkHorizontal',
  '2': [
    {'1': 'left', '3': 1, '4': 1, '5': 2, '10': 'left'},
    {'1': 'right', '3': 2, '4': 1, '5': 2, '10': 'right'},
    {'1': 'y', '3': 3, '4': 1, '5': 2, '10': 'y'},
    {'1': 'height', '3': 4, '4': 1, '5': 2, '10': 'height'},
  ],
};

/// Descriptor for `MattingMarkHorizontal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mattingMarkHorizontalDescriptor = $convert.base64Decode(
    'ChVNYXR0aW5nTWFya0hvcml6b250YWwSEgoEbGVmdBgBIAEoAlIEbGVmdBIUCgVyaWdodBgCIA'
    'EoAlIFcmlnaHQSDAoBeRgDIAEoAlIBeRIWCgZoZWlnaHQYBCABKAJSBmhlaWdodA==');

@$core.Deprecated('Use mattingMarkVerticalDescriptor instead')
const MattingMarkVertical$json = {
  '1': 'MattingMarkVertical',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'top', '3': 2, '4': 1, '5': 2, '10': 'top'},
    {'1': 'bottom', '3': 3, '4': 1, '5': 2, '10': 'bottom'},
    {'1': 'lineWidth', '3': 4, '4': 1, '5': 2, '10': 'lineWidth'},
  ],
};

/// Descriptor for `MattingMarkVertical`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mattingMarkVerticalDescriptor = $convert.base64Decode(
    'ChNNYXR0aW5nTWFya1ZlcnRpY2FsEgwKAXgYASABKAJSAXgSEAoDdG9wGAIgASgCUgN0b3ASFg'
    'oGYm90dG9tGAMgASgCUgZib3R0b20SHAoJbGluZVdpZHRoGAQgASgCUglsaW5lV2lkdGg=');

@$core.Deprecated('Use mattingMarkLineDescriptor instead')
const MattingMarkLine$json = {
  '1': 'MattingMarkLine',
  '2': [
    {'1': 'startX', '3': 1, '4': 1, '5': 2, '10': 'startX'},
    {'1': 'startY', '3': 2, '4': 1, '5': 2, '10': 'startY'},
    {'1': 'endX', '3': 3, '4': 1, '5': 2, '10': 'endX'},
    {'1': 'endY', '3': 4, '4': 1, '5': 2, '10': 'endY'},
    {'1': 'lineWidth', '3': 5, '4': 1, '5': 2, '10': 'lineWidth'},
  ],
};

/// Descriptor for `MattingMarkLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mattingMarkLineDescriptor = $convert.base64Decode(
    'Cg9NYXR0aW5nTWFya0xpbmUSFgoGc3RhcnRYGAEgASgCUgZzdGFydFgSFgoGc3RhcnRZGAIgAS'
    'gCUgZzdGFydFkSEgoEZW5kWBgDIAEoAlIEZW5kWBISCgRlbmRZGAQgASgCUgRlbmRZEhwKCWxp'
    'bmVXaWR0aBgFIAEoAlIJbGluZVdpZHRo');

@$core.Deprecated('Use mattingMarkRectangleDescriptor instead')
const MattingMarkRectangle$json = {
  '1': 'MattingMarkRectangle',
  '2': [
    {'1': 'leftTopX', '3': 1, '4': 1, '5': 2, '10': 'leftTopX'},
    {'1': 'leftTopY', '3': 2, '4': 1, '5': 2, '10': 'leftTopY'},
    {'1': 'rightBottomX', '3': 3, '4': 1, '5': 2, '10': 'rightBottomX'},
    {'1': 'rightBottomY', '3': 4, '4': 1, '5': 2, '10': 'rightBottomY'},
  ],
};

/// Descriptor for `MattingMarkRectangle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mattingMarkRectangleDescriptor = $convert.base64Decode(
    'ChRNYXR0aW5nTWFya1JlY3RhbmdsZRIaCghsZWZ0VG9wWBgBIAEoAlIIbGVmdFRvcFgSGgoIbG'
    'VmdFRvcFkYAiABKAJSCGxlZnRUb3BZEiIKDHJpZ2h0Qm90dG9tWBgDIAEoAlIMcmlnaHRCb3R0'
    'b21YEiIKDHJpZ2h0Qm90dG9tWRgEIAEoAlIMcmlnaHRCb3R0b21Z');

