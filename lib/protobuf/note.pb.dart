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

import 'note.pbenum.dart';

export 'note.pbenum.dart';

class NoteBookMeta extends $pb.GeneratedMessage {
  factory NoteBookMeta({
    $core.int? lastPageId,
    $core.Map<$core.int, $core.int>? pages,
  }) {
    final $result = create();
    if (lastPageId != null) {
      $result.lastPageId = lastPageId;
    }
    if (pages != null) {
      $result.pages.addAll(pages);
    }
    return $result;
  }
  NoteBookMeta._() : super();
  factory NoteBookMeta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NoteBookMeta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NoteBookMeta', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastPageId', $pb.PbFieldType.OU3, protoName: 'lastPageId')
    ..m<$core.int, $core.int>(2, _omitFieldNames ? '' : 'pages', entryClassName: 'NoteBookMeta.PagesEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NoteBookMeta clone() => NoteBookMeta()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NoteBookMeta copyWith(void Function(NoteBookMeta) updates) => super.copyWith((message) => updates(message as NoteBookMeta)) as NoteBookMeta;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NoteBookMeta create() => NoteBookMeta._();
  NoteBookMeta createEmptyInstance() => create();
  static $pb.PbList<NoteBookMeta> createRepeated() => $pb.PbList<NoteBookMeta>();
  @$core.pragma('dart2js:noInline')
  static NoteBookMeta getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NoteBookMeta>(create);
  static NoteBookMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lastPageId => $_getIZ(0);
  @$pb.TagNumber(1)
  set lastPageId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastPageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastPageId() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.int, $core.int> get pages => $_getMap(1);
}

enum NotePage_Content {
  independentNoteData, 
  markNoteData, 
  notSet
}

class NotePage extends $pb.GeneratedMessage {
  factory NotePage({
    $core.double? width,
    $core.double? height,
    $core.Iterable<NotePageItem>? items,
    IndependentNotePageData? independentNoteData,
    MarkNotePageData? markNoteData,
    $core.Map<$core.int, Pen>? penPool,
  }) {
    final $result = create();
    if (width != null) {
      $result.width = width;
    }
    if (height != null) {
      $result.height = height;
    }
    if (items != null) {
      $result.items.addAll(items);
    }
    if (independentNoteData != null) {
      $result.independentNoteData = independentNoteData;
    }
    if (markNoteData != null) {
      $result.markNoteData = markNoteData;
    }
    if (penPool != null) {
      $result.penPool.addAll(penPool);
    }
    return $result;
  }
  NotePage._() : super();
  factory NotePage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NotePage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, NotePage_Content> _NotePage_ContentByTag = {
    4 : NotePage_Content.independentNoteData,
    5 : NotePage_Content.markNoteData,
    0 : NotePage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotePage', createEmptyInstance: create)
    ..oo(0, [4, 5])
    ..a<$core.double>(1, _omitFieldNames ? '' : 'width', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OF)
    ..pc<NotePageItem>(3, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: NotePageItem.create)
    ..aOM<IndependentNotePageData>(4, _omitFieldNames ? '' : 'independentNoteData', protoName: 'independentNoteData', subBuilder: IndependentNotePageData.create)
    ..aOM<MarkNotePageData>(5, _omitFieldNames ? '' : 'markNoteData', protoName: 'markNoteData', subBuilder: MarkNotePageData.create)
    ..m<$core.int, Pen>(6, _omitFieldNames ? '' : 'penPool', protoName: 'penPool', entryClassName: 'NotePage.PenPoolEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Pen.create, valueDefaultOrMaker: Pen.getDefault)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NotePage clone() => NotePage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NotePage copyWith(void Function(NotePage) updates) => super.copyWith((message) => updates(message as NotePage)) as NotePage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotePage create() => NotePage._();
  NotePage createEmptyInstance() => create();
  static $pb.PbList<NotePage> createRepeated() => $pb.PbList<NotePage>();
  @$core.pragma('dart2js:noInline')
  static NotePage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NotePage>(create);
  static NotePage? _defaultInstance;

  NotePage_Content whichContent() => _NotePage_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.double get width => $_getN(0);
  @$pb.TagNumber(1)
  set width($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get height => $_getN(1);
  @$pb.TagNumber(2)
  set height($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<NotePageItem> get items => $_getList(2);

  @$pb.TagNumber(4)
  IndependentNotePageData get independentNoteData => $_getN(3);
  @$pb.TagNumber(4)
  set independentNoteData(IndependentNotePageData v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasIndependentNoteData() => $_has(3);
  @$pb.TagNumber(4)
  void clearIndependentNoteData() => clearField(4);
  @$pb.TagNumber(4)
  IndependentNotePageData ensureIndependentNoteData() => $_ensure(3);

  @$pb.TagNumber(5)
  MarkNotePageData get markNoteData => $_getN(4);
  @$pb.TagNumber(5)
  set markNoteData(MarkNotePageData v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasMarkNoteData() => $_has(4);
  @$pb.TagNumber(5)
  void clearMarkNoteData() => clearField(5);
  @$pb.TagNumber(5)
  MarkNotePageData ensureMarkNoteData() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.Map<$core.int, Pen> get penPool => $_getMap(5);
}

class IndependentNotePageData extends $pb.GeneratedMessage {
  factory IndependentNotePageData({
    $core.int? lastMatteId,
    $core.Map<$core.int, Matte>? mattePool,
  }) {
    final $result = create();
    if (lastMatteId != null) {
      $result.lastMatteId = lastMatteId;
    }
    if (mattePool != null) {
      $result.mattePool.addAll(mattePool);
    }
    return $result;
  }
  IndependentNotePageData._() : super();
  factory IndependentNotePageData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IndependentNotePageData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IndependentNotePageData', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastMatteId', $pb.PbFieldType.OU3, protoName: 'lastMatteId')
    ..m<$core.int, Matte>(2, _omitFieldNames ? '' : 'mattePool', protoName: 'mattePool', entryClassName: 'IndependentNotePageData.MattePoolEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: Matte.create, valueDefaultOrMaker: Matte.getDefault)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IndependentNotePageData clone() => IndependentNotePageData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IndependentNotePageData copyWith(void Function(IndependentNotePageData) updates) => super.copyWith((message) => updates(message as IndependentNotePageData)) as IndependentNotePageData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndependentNotePageData create() => IndependentNotePageData._();
  IndependentNotePageData createEmptyInstance() => create();
  static $pb.PbList<IndependentNotePageData> createRepeated() => $pb.PbList<IndependentNotePageData>();
  @$core.pragma('dart2js:noInline')
  static IndependentNotePageData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IndependentNotePageData>(create);
  static IndependentNotePageData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lastMatteId => $_getIZ(0);
  @$pb.TagNumber(1)
  set lastMatteId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastMatteId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastMatteId() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.int, Matte> get mattePool => $_getMap(1);
}

class MarkNotePageData extends $pb.GeneratedMessage {
  factory MarkNotePageData({
    $core.int? lastMattingMarkId,
    $core.Map<$core.int, MattingMark>? mattingMarkPool,
  }) {
    final $result = create();
    if (lastMattingMarkId != null) {
      $result.lastMattingMarkId = lastMattingMarkId;
    }
    if (mattingMarkPool != null) {
      $result.mattingMarkPool.addAll(mattingMarkPool);
    }
    return $result;
  }
  MarkNotePageData._() : super();
  factory MarkNotePageData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MarkNotePageData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MarkNotePageData', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastMattingMarkId', $pb.PbFieldType.OU3, protoName: 'lastMattingMarkId')
    ..m<$core.int, MattingMark>(2, _omitFieldNames ? '' : 'mattingMarkPool', protoName: 'mattingMarkPool', entryClassName: 'MarkNotePageData.MattingMarkPoolEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: MattingMark.create, valueDefaultOrMaker: MattingMark.getDefault)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MarkNotePageData clone() => MarkNotePageData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MarkNotePageData copyWith(void Function(MarkNotePageData) updates) => super.copyWith((message) => updates(message as MarkNotePageData)) as MarkNotePageData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkNotePageData create() => MarkNotePageData._();
  MarkNotePageData createEmptyInstance() => create();
  static $pb.PbList<MarkNotePageData> createRepeated() => $pb.PbList<MarkNotePageData>();
  @$core.pragma('dart2js:noInline')
  static MarkNotePageData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarkNotePageData>(create);
  static MarkNotePageData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lastMattingMarkId => $_getIZ(0);
  @$pb.TagNumber(1)
  set lastMattingMarkId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastMattingMarkId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastMattingMarkId() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.int, MattingMark> get mattingMarkPool => $_getMap(1);
}

enum NotePageItem_Content {
  path, 
  mattingMarkId, 
  matteId, 
  notSet
}

class NotePageItem extends $pb.GeneratedMessage {
  factory NotePageItem({
    $core.double? x,
    $core.double? y,
    Path? path,
    $core.int? mattingMarkId,
    $core.int? matteId,
    $core.double? scale,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    if (path != null) {
      $result.path = path;
    }
    if (mattingMarkId != null) {
      $result.mattingMarkId = mattingMarkId;
    }
    if (matteId != null) {
      $result.matteId = matteId;
    }
    if (scale != null) {
      $result.scale = scale;
    }
    return $result;
  }
  NotePageItem._() : super();
  factory NotePageItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NotePageItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, NotePageItem_Content> _NotePageItem_ContentByTag = {
    3 : NotePageItem_Content.path,
    4 : NotePageItem_Content.mattingMarkId,
    5 : NotePageItem_Content.matteId,
    0 : NotePageItem_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotePageItem', createEmptyInstance: create)
    ..oo(0, [3, 4, 5])
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..aOM<Path>(3, _omitFieldNames ? '' : 'path', subBuilder: Path.create)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'mattingMarkId', $pb.PbFieldType.OU3, protoName: 'mattingMarkId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'matteId', $pb.PbFieldType.OU3, protoName: 'matteId')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'scale', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NotePageItem clone() => NotePageItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NotePageItem copyWith(void Function(NotePageItem) updates) => super.copyWith((message) => updates(message as NotePageItem)) as NotePageItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotePageItem create() => NotePageItem._();
  NotePageItem createEmptyInstance() => create();
  static $pb.PbList<NotePageItem> createRepeated() => $pb.PbList<NotePageItem>();
  @$core.pragma('dart2js:noInline')
  static NotePageItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NotePageItem>(create);
  static NotePageItem? _defaultInstance;

  NotePageItem_Content whichContent() => _NotePageItem_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);

  @$pb.TagNumber(3)
  Path get path => $_getN(2);
  @$pb.TagNumber(3)
  set path(Path v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => clearField(3);
  @$pb.TagNumber(3)
  Path ensurePath() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get mattingMarkId => $_getIZ(3);
  @$pb.TagNumber(4)
  set mattingMarkId($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMattingMarkId() => $_has(3);
  @$pb.TagNumber(4)
  void clearMattingMarkId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get matteId => $_getIZ(4);
  @$pb.TagNumber(5)
  set matteId($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMatteId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMatteId() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get scale => $_getN(5);
  @$pb.TagNumber(6)
  set scale($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScale() => $_has(5);
  @$pb.TagNumber(6)
  void clearScale() => clearField(6);
}

class Path extends $pb.GeneratedMessage {
  factory Path({
    $core.int? penId,
    $core.Iterable<Point>? points,
  }) {
    final $result = create();
    if (penId != null) {
      $result.penId = penId;
    }
    if (points != null) {
      $result.points.addAll(points);
    }
    return $result;
  }
  Path._() : super();
  factory Path.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Path.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Path', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'penId', $pb.PbFieldType.OU3, protoName: 'penId')
    ..pc<Point>(2, _omitFieldNames ? '' : 'points', $pb.PbFieldType.PM, subBuilder: Point.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Path clone() => Path()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Path copyWith(void Function(Path) updates) => super.copyWith((message) => updates(message as Path)) as Path;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Path create() => Path._();
  Path createEmptyInstance() => create();
  static $pb.PbList<Path> createRepeated() => $pb.PbList<Path>();
  @$core.pragma('dart2js:noInline')
  static Path getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Path>(create);
  static Path? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get penId => $_getIZ(0);
  @$pb.TagNumber(1)
  set penId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPenId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPenId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Point> get points => $_getList(1);
}

class Pen extends $pb.GeneratedMessage {
  factory Pen({
    PenType? type,
    $core.int? color,
    $core.double? lineWidth,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (color != null) {
      $result.color = color;
    }
    if (lineWidth != null) {
      $result.lineWidth = lineWidth;
    }
    return $result;
  }
  Pen._() : super();
  factory Pen.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Pen.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Pen', createEmptyInstance: create)
    ..e<PenType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: PenType.PT_BALL_POINT_PEN, valueOf: PenType.valueOf, enumValues: PenType.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'lineWidth', $pb.PbFieldType.OF, protoName: 'lineWidth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Pen clone() => Pen()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Pen copyWith(void Function(Pen) updates) => super.copyWith((message) => updates(message as Pen)) as Pen;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Pen create() => Pen._();
  Pen createEmptyInstance() => create();
  static $pb.PbList<Pen> createRepeated() => $pb.PbList<Pen>();
  @$core.pragma('dart2js:noInline')
  static Pen getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pen>(create);
  static Pen? _defaultInstance;

  @$pb.TagNumber(1)
  PenType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(PenType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get color => $_getIZ(1);
  @$pb.TagNumber(2)
  set color($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearColor() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get lineWidth => $_getN(2);
  @$pb.TagNumber(3)
  set lineWidth($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLineWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearLineWidth() => clearField(3);
}

class Point extends $pb.GeneratedMessage {
  factory Point({
    $core.double? x,
    $core.double? y,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    return $result;
  }
  Point._() : super();
  factory Point.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Point.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Point', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Point clone() => Point()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Point copyWith(void Function(Point) updates) => super.copyWith((message) => updates(message as Point)) as Point;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Point create() => Point._();
  Point createEmptyInstance() => create();
  static $pb.PbList<Point> createRepeated() => $pb.PbList<Point>();
  @$core.pragma('dart2js:noInline')
  static Point getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Point>(create);
  static Point? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);
}

class Matte extends $pb.GeneratedMessage {
  factory Matte({
    $core.int? bookPageNumber,
    $core.int? bookPageMattingMarkId,
    ImageType? imageType,
    $core.int? imageWidth,
    $core.int? imageHeight,
    $core.List<$core.int>? imageData,
  }) {
    final $result = create();
    if (bookPageNumber != null) {
      $result.bookPageNumber = bookPageNumber;
    }
    if (bookPageMattingMarkId != null) {
      $result.bookPageMattingMarkId = bookPageMattingMarkId;
    }
    if (imageType != null) {
      $result.imageType = imageType;
    }
    if (imageWidth != null) {
      $result.imageWidth = imageWidth;
    }
    if (imageHeight != null) {
      $result.imageHeight = imageHeight;
    }
    if (imageData != null) {
      $result.imageData = imageData;
    }
    return $result;
  }
  Matte._() : super();
  factory Matte.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Matte.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Matte', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'bookPageNumber', $pb.PbFieldType.OU3, protoName: 'bookPageNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'bookPageMattingMarkId', $pb.PbFieldType.OU3, protoName: 'bookPageMattingMarkId')
    ..e<ImageType>(3, _omitFieldNames ? '' : 'imageType', $pb.PbFieldType.OE, protoName: 'imageType', defaultOrMaker: ImageType.IT_2BIT_1CHANNEL, valueOf: ImageType.valueOf, enumValues: ImageType.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'imageWidth', $pb.PbFieldType.OU3, protoName: 'imageWidth')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'imageHeight', $pb.PbFieldType.OU3, protoName: 'imageHeight')
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'imageData', $pb.PbFieldType.OY, protoName: 'imageData')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Matte clone() => Matte()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Matte copyWith(void Function(Matte) updates) => super.copyWith((message) => updates(message as Matte)) as Matte;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Matte create() => Matte._();
  Matte createEmptyInstance() => create();
  static $pb.PbList<Matte> createRepeated() => $pb.PbList<Matte>();
  @$core.pragma('dart2js:noInline')
  static Matte getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Matte>(create);
  static Matte? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get bookPageNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set bookPageNumber($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBookPageNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearBookPageNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get bookPageMattingMarkId => $_getIZ(1);
  @$pb.TagNumber(2)
  set bookPageMattingMarkId($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBookPageMattingMarkId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBookPageMattingMarkId() => clearField(2);

  @$pb.TagNumber(3)
  ImageType get imageType => $_getN(2);
  @$pb.TagNumber(3)
  set imageType(ImageType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasImageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearImageType() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get imageWidth => $_getIZ(3);
  @$pb.TagNumber(4)
  set imageWidth($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasImageWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageWidth() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get imageHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set imageHeight($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasImageHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearImageHeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get imageData => $_getN(5);
  @$pb.TagNumber(6)
  set imageData($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasImageData() => $_has(5);
  @$pb.TagNumber(6)
  void clearImageData() => clearField(6);
}

enum MattingMark_Content {
  horizontal, 
  vertical, 
  line, 
  rectangle, 
  notSet
}

class MattingMark extends $pb.GeneratedMessage {
  factory MattingMark({
    $core.int? color,
    MattingMarkHorizontal? horizontal,
    MattingMarkVertical? vertical,
    MattingMarkLine? line,
    MattingMarkRectangle? rectangle,
    $core.Iterable<$core.int>? linkingIndependentNoteId,
  }) {
    final $result = create();
    if (color != null) {
      $result.color = color;
    }
    if (horizontal != null) {
      $result.horizontal = horizontal;
    }
    if (vertical != null) {
      $result.vertical = vertical;
    }
    if (line != null) {
      $result.line = line;
    }
    if (rectangle != null) {
      $result.rectangle = rectangle;
    }
    if (linkingIndependentNoteId != null) {
      $result.linkingIndependentNoteId.addAll(linkingIndependentNoteId);
    }
    return $result;
  }
  MattingMark._() : super();
  factory MattingMark.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMark.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MattingMark_Content> _MattingMark_ContentByTag = {
    2 : MattingMark_Content.horizontal,
    3 : MattingMark_Content.vertical,
    4 : MattingMark_Content.line,
    5 : MattingMark_Content.rectangle,
    0 : MattingMark_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMark', createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..aOM<MattingMarkHorizontal>(2, _omitFieldNames ? '' : 'horizontal', subBuilder: MattingMarkHorizontal.create)
    ..aOM<MattingMarkVertical>(3, _omitFieldNames ? '' : 'vertical', subBuilder: MattingMarkVertical.create)
    ..aOM<MattingMarkLine>(4, _omitFieldNames ? '' : 'line', subBuilder: MattingMarkLine.create)
    ..aOM<MattingMarkRectangle>(5, _omitFieldNames ? '' : 'rectangle', subBuilder: MattingMarkRectangle.create)
    ..p<$core.int>(6, _omitFieldNames ? '' : 'linkingIndependentNoteId', $pb.PbFieldType.KU3, protoName: 'linkingIndependentNoteId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingMark clone() => MattingMark()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingMark copyWith(void Function(MattingMark) updates) => super.copyWith((message) => updates(message as MattingMark)) as MattingMark;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingMark create() => MattingMark._();
  MattingMark createEmptyInstance() => create();
  static $pb.PbList<MattingMark> createRepeated() => $pb.PbList<MattingMark>();
  @$core.pragma('dart2js:noInline')
  static MattingMark getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingMark>(create);
  static MattingMark? _defaultInstance;

  MattingMark_Content whichContent() => _MattingMark_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get color => $_getIZ(0);
  @$pb.TagNumber(1)
  set color($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasColor() => $_has(0);
  @$pb.TagNumber(1)
  void clearColor() => clearField(1);

  @$pb.TagNumber(2)
  MattingMarkHorizontal get horizontal => $_getN(1);
  @$pb.TagNumber(2)
  set horizontal(MattingMarkHorizontal v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHorizontal() => $_has(1);
  @$pb.TagNumber(2)
  void clearHorizontal() => clearField(2);
  @$pb.TagNumber(2)
  MattingMarkHorizontal ensureHorizontal() => $_ensure(1);

  @$pb.TagNumber(3)
  MattingMarkVertical get vertical => $_getN(2);
  @$pb.TagNumber(3)
  set vertical(MattingMarkVertical v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVertical() => $_has(2);
  @$pb.TagNumber(3)
  void clearVertical() => clearField(3);
  @$pb.TagNumber(3)
  MattingMarkVertical ensureVertical() => $_ensure(2);

  @$pb.TagNumber(4)
  MattingMarkLine get line => $_getN(3);
  @$pb.TagNumber(4)
  set line(MattingMarkLine v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasLine() => $_has(3);
  @$pb.TagNumber(4)
  void clearLine() => clearField(4);
  @$pb.TagNumber(4)
  MattingMarkLine ensureLine() => $_ensure(3);

  @$pb.TagNumber(5)
  MattingMarkRectangle get rectangle => $_getN(4);
  @$pb.TagNumber(5)
  set rectangle(MattingMarkRectangle v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRectangle() => $_has(4);
  @$pb.TagNumber(5)
  void clearRectangle() => clearField(5);
  @$pb.TagNumber(5)
  MattingMarkRectangle ensureRectangle() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.List<$core.int> get linkingIndependentNoteId => $_getList(5);
}

class MattingMarkHorizontal extends $pb.GeneratedMessage {
  factory MattingMarkHorizontal({
    $core.double? left,
    $core.double? right,
    $core.double? y,
    $core.double? height,
  }) {
    final $result = create();
    if (left != null) {
      $result.left = left;
    }
    if (right != null) {
      $result.right = right;
    }
    if (y != null) {
      $result.y = y;
    }
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  MattingMarkHorizontal._() : super();
  factory MattingMarkHorizontal.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkHorizontal.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkHorizontal', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'left', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'right', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingMarkHorizontal clone() => MattingMarkHorizontal()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingMarkHorizontal copyWith(void Function(MattingMarkHorizontal) updates) => super.copyWith((message) => updates(message as MattingMarkHorizontal)) as MattingMarkHorizontal;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingMarkHorizontal create() => MattingMarkHorizontal._();
  MattingMarkHorizontal createEmptyInstance() => create();
  static $pb.PbList<MattingMarkHorizontal> createRepeated() => $pb.PbList<MattingMarkHorizontal>();
  @$core.pragma('dart2js:noInline')
  static MattingMarkHorizontal getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingMarkHorizontal>(create);
  static MattingMarkHorizontal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get left => $_getN(0);
  @$pb.TagNumber(1)
  set left($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get right => $_getN(1);
  @$pb.TagNumber(2)
  set right($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRight() => $_has(1);
  @$pb.TagNumber(2)
  void clearRight() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get y => $_getN(2);
  @$pb.TagNumber(3)
  set y($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasY() => $_has(2);
  @$pb.TagNumber(3)
  void clearY() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get height => $_getN(3);
  @$pb.TagNumber(4)
  set height($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => clearField(4);
}

class MattingMarkVertical extends $pb.GeneratedMessage {
  factory MattingMarkVertical({
    $core.double? x,
    $core.double? top,
    $core.double? bottom,
    $core.double? lineWidth,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (top != null) {
      $result.top = top;
    }
    if (bottom != null) {
      $result.bottom = bottom;
    }
    if (lineWidth != null) {
      $result.lineWidth = lineWidth;
    }
    return $result;
  }
  MattingMarkVertical._() : super();
  factory MattingMarkVertical.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkVertical.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkVertical', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'top', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'bottom', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'lineWidth', $pb.PbFieldType.OF, protoName: 'lineWidth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingMarkVertical clone() => MattingMarkVertical()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingMarkVertical copyWith(void Function(MattingMarkVertical) updates) => super.copyWith((message) => updates(message as MattingMarkVertical)) as MattingMarkVertical;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingMarkVertical create() => MattingMarkVertical._();
  MattingMarkVertical createEmptyInstance() => create();
  static $pb.PbList<MattingMarkVertical> createRepeated() => $pb.PbList<MattingMarkVertical>();
  @$core.pragma('dart2js:noInline')
  static MattingMarkVertical getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingMarkVertical>(create);
  static MattingMarkVertical? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get top => $_getN(1);
  @$pb.TagNumber(2)
  set top($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTop() => $_has(1);
  @$pb.TagNumber(2)
  void clearTop() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get bottom => $_getN(2);
  @$pb.TagNumber(3)
  set bottom($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBottom() => $_has(2);
  @$pb.TagNumber(3)
  void clearBottom() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get lineWidth => $_getN(3);
  @$pb.TagNumber(4)
  set lineWidth($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLineWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearLineWidth() => clearField(4);
}

class MattingMarkLine extends $pb.GeneratedMessage {
  factory MattingMarkLine({
    $core.double? startX,
    $core.double? startY,
    $core.double? endX,
    $core.double? endY,
    $core.double? lineWidth,
  }) {
    final $result = create();
    if (startX != null) {
      $result.startX = startX;
    }
    if (startY != null) {
      $result.startY = startY;
    }
    if (endX != null) {
      $result.endX = endX;
    }
    if (endY != null) {
      $result.endY = endY;
    }
    if (lineWidth != null) {
      $result.lineWidth = lineWidth;
    }
    return $result;
  }
  MattingMarkLine._() : super();
  factory MattingMarkLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkLine', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'startX', $pb.PbFieldType.OF, protoName: 'startX')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'startY', $pb.PbFieldType.OF, protoName: 'startY')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'endX', $pb.PbFieldType.OF, protoName: 'endX')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'endY', $pb.PbFieldType.OF, protoName: 'endY')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'lineWidth', $pb.PbFieldType.OF, protoName: 'lineWidth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingMarkLine clone() => MattingMarkLine()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingMarkLine copyWith(void Function(MattingMarkLine) updates) => super.copyWith((message) => updates(message as MattingMarkLine)) as MattingMarkLine;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingMarkLine create() => MattingMarkLine._();
  MattingMarkLine createEmptyInstance() => create();
  static $pb.PbList<MattingMarkLine> createRepeated() => $pb.PbList<MattingMarkLine>();
  @$core.pragma('dart2js:noInline')
  static MattingMarkLine getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingMarkLine>(create);
  static MattingMarkLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get startX => $_getN(0);
  @$pb.TagNumber(1)
  set startX($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartX() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get startY => $_getN(1);
  @$pb.TagNumber(2)
  set startY($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartY() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartY() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get endX => $_getN(2);
  @$pb.TagNumber(3)
  set endX($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndX() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndX() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get endY => $_getN(3);
  @$pb.TagNumber(4)
  set endY($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEndY() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndY() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get lineWidth => $_getN(4);
  @$pb.TagNumber(5)
  set lineWidth($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLineWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearLineWidth() => clearField(5);
}

class MattingMarkRectangle extends $pb.GeneratedMessage {
  factory MattingMarkRectangle({
    $core.double? leftTopX,
    $core.double? leftTopY,
    $core.double? rightBottomX,
    $core.double? rightBottomY,
  }) {
    final $result = create();
    if (leftTopX != null) {
      $result.leftTopX = leftTopX;
    }
    if (leftTopY != null) {
      $result.leftTopY = leftTopY;
    }
    if (rightBottomX != null) {
      $result.rightBottomX = rightBottomX;
    }
    if (rightBottomY != null) {
      $result.rightBottomY = rightBottomY;
    }
    return $result;
  }
  MattingMarkRectangle._() : super();
  factory MattingMarkRectangle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkRectangle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkRectangle', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'leftTopX', $pb.PbFieldType.OF, protoName: 'leftTopX')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'leftTopY', $pb.PbFieldType.OF, protoName: 'leftTopY')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'rightBottomX', $pb.PbFieldType.OF, protoName: 'rightBottomX')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'rightBottomY', $pb.PbFieldType.OF, protoName: 'rightBottomY')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingMarkRectangle clone() => MattingMarkRectangle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingMarkRectangle copyWith(void Function(MattingMarkRectangle) updates) => super.copyWith((message) => updates(message as MattingMarkRectangle)) as MattingMarkRectangle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingMarkRectangle create() => MattingMarkRectangle._();
  MattingMarkRectangle createEmptyInstance() => create();
  static $pb.PbList<MattingMarkRectangle> createRepeated() => $pb.PbList<MattingMarkRectangle>();
  @$core.pragma('dart2js:noInline')
  static MattingMarkRectangle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingMarkRectangle>(create);
  static MattingMarkRectangle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get leftTopX => $_getN(0);
  @$pb.TagNumber(1)
  set leftTopX($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLeftTopX() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeftTopX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get leftTopY => $_getN(1);
  @$pb.TagNumber(2)
  set leftTopY($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLeftTopY() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeftTopY() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get rightBottomX => $_getN(2);
  @$pb.TagNumber(3)
  set rightBottomX($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRightBottomX() => $_has(2);
  @$pb.TagNumber(3)
  void clearRightBottomX() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get rightBottomY => $_getN(3);
  @$pb.TagNumber(4)
  set rightBottomY($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRightBottomY() => $_has(3);
  @$pb.TagNumber(4)
  void clearRightBottomY() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
