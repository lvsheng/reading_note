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

enum NoteBookMeta_Content {
  independentNoteBookMeta, 
  bookMarkNoteBookMeta, 
  notSet
}

class NoteBookMeta extends $pb.GeneratedMessage {
  factory NoteBookMeta({
    IndependentNoteBookMeta? independentNoteBookMeta,
    BookMarkNoteBookMeta? bookMarkNoteBookMeta,
  }) {
    final $result = create();
    if (independentNoteBookMeta != null) {
      $result.independentNoteBookMeta = independentNoteBookMeta;
    }
    if (bookMarkNoteBookMeta != null) {
      $result.bookMarkNoteBookMeta = bookMarkNoteBookMeta;
    }
    return $result;
  }
  NoteBookMeta._() : super();
  factory NoteBookMeta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NoteBookMeta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, NoteBookMeta_Content> _NoteBookMeta_ContentByTag = {
    1 : NoteBookMeta_Content.independentNoteBookMeta,
    2 : NoteBookMeta_Content.bookMarkNoteBookMeta,
    0 : NoteBookMeta_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NoteBookMeta', createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<IndependentNoteBookMeta>(1, _omitFieldNames ? '' : 'independentNoteBookMeta', protoName: 'independentNoteBookMeta', subBuilder: IndependentNoteBookMeta.create)
    ..aOM<BookMarkNoteBookMeta>(2, _omitFieldNames ? '' : 'bookMarkNoteBookMeta', protoName: 'bookMarkNoteBookMeta', subBuilder: BookMarkNoteBookMeta.create)
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

  NoteBookMeta_Content whichContent() => _NoteBookMeta_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  IndependentNoteBookMeta get independentNoteBookMeta => $_getN(0);
  @$pb.TagNumber(1)
  set independentNoteBookMeta(IndependentNoteBookMeta v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndependentNoteBookMeta() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndependentNoteBookMeta() => clearField(1);
  @$pb.TagNumber(1)
  IndependentNoteBookMeta ensureIndependentNoteBookMeta() => $_ensure(0);

  @$pb.TagNumber(2)
  BookMarkNoteBookMeta get bookMarkNoteBookMeta => $_getN(1);
  @$pb.TagNumber(2)
  set bookMarkNoteBookMeta(BookMarkNoteBookMeta v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBookMarkNoteBookMeta() => $_has(1);
  @$pb.TagNumber(2)
  void clearBookMarkNoteBookMeta() => clearField(2);
  @$pb.TagNumber(2)
  BookMarkNoteBookMeta ensureBookMarkNoteBookMeta() => $_ensure(1);
}

class IndependentNoteBookMeta extends $pb.GeneratedMessage {
  factory IndependentNoteBookMeta({
    $core.int? lastPageId,
    $core.Iterable<$core.int>? pages,
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
  IndependentNoteBookMeta._() : super();
  factory IndependentNoteBookMeta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IndependentNoteBookMeta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IndependentNoteBookMeta', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastPageId', $pb.PbFieldType.OU3, protoName: 'lastPageId')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'pages', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  IndependentNoteBookMeta clone() => IndependentNoteBookMeta()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  IndependentNoteBookMeta copyWith(void Function(IndependentNoteBookMeta) updates) => super.copyWith((message) => updates(message as IndependentNoteBookMeta)) as IndependentNoteBookMeta;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndependentNoteBookMeta create() => IndependentNoteBookMeta._();
  IndependentNoteBookMeta createEmptyInstance() => create();
  static $pb.PbList<IndependentNoteBookMeta> createRepeated() => $pb.PbList<IndependentNoteBookMeta>();
  @$core.pragma('dart2js:noInline')
  static IndependentNoteBookMeta getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IndependentNoteBookMeta>(create);
  static IndependentNoteBookMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lastPageId => $_getIZ(0);
  @$pb.TagNumber(1)
  set lastPageId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLastPageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastPageId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get pages => $_getList(1);
}

class BookMarkNoteBookMeta extends $pb.GeneratedMessage {
  factory BookMarkNoteBookMeta({
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
  BookMarkNoteBookMeta._() : super();
  factory BookMarkNoteBookMeta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BookMarkNoteBookMeta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BookMarkNoteBookMeta', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'lastPageId', $pb.PbFieldType.OU3, protoName: 'lastPageId')
    ..m<$core.int, $core.int>(2, _omitFieldNames ? '' : 'pages', entryClassName: 'BookMarkNoteBookMeta.PagesEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BookMarkNoteBookMeta clone() => BookMarkNoteBookMeta()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BookMarkNoteBookMeta copyWith(void Function(BookMarkNoteBookMeta) updates) => super.copyWith((message) => updates(message as BookMarkNoteBookMeta)) as BookMarkNoteBookMeta;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BookMarkNoteBookMeta create() => BookMarkNoteBookMeta._();
  BookMarkNoteBookMeta createEmptyInstance() => create();
  static $pb.PbList<BookMarkNoteBookMeta> createRepeated() => $pb.PbList<BookMarkNoteBookMeta>();
  @$core.pragma('dart2js:noInline')
  static BookMarkNoteBookMeta getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BookMarkNoteBookMeta>(create);
  static BookMarkNoteBookMeta? _defaultInstance;

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

class NotePage extends $pb.GeneratedMessage {
  factory NotePage({
    $core.double? width,
    $core.double? height,
    $core.Iterable<NotePageItem>? items,
    $core.Map<$core.int, MattingResult>? mattingResultPool,
    $core.Map<$core.int, MattingMark>? mattingMarkPool,
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
    if (mattingResultPool != null) {
      $result.mattingResultPool.addAll(mattingResultPool);
    }
    if (mattingMarkPool != null) {
      $result.mattingMarkPool.addAll(mattingMarkPool);
    }
    if (penPool != null) {
      $result.penPool.addAll(penPool);
    }
    return $result;
  }
  NotePage._() : super();
  factory NotePage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NotePage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotePage', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'width', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OD)
    ..pc<NotePageItem>(3, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: NotePageItem.create)
    ..m<$core.int, MattingResult>(4, _omitFieldNames ? '' : 'mattingResultPool', protoName: 'mattingResultPool', entryClassName: 'NotePage.MattingResultPoolEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: MattingResult.create, valueDefaultOrMaker: MattingResult.getDefault)
    ..m<$core.int, MattingMark>(5, _omitFieldNames ? '' : 'mattingMarkPool', protoName: 'mattingMarkPool', entryClassName: 'NotePage.MattingMarkPoolEntry', keyFieldType: $pb.PbFieldType.OU3, valueFieldType: $pb.PbFieldType.OM, valueCreator: MattingMark.create, valueDefaultOrMaker: MattingMark.getDefault)
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

  @$pb.TagNumber(1)
  $core.double get width => $_getN(0);
  @$pb.TagNumber(1)
  set width($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get height => $_getN(1);
  @$pb.TagNumber(2)
  set height($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<NotePageItem> get items => $_getList(2);

  @$pb.TagNumber(4)
  $core.Map<$core.int, MattingResult> get mattingResultPool => $_getMap(3);

  @$pb.TagNumber(5)
  $core.Map<$core.int, MattingMark> get mattingMarkPool => $_getMap(4);

  @$pb.TagNumber(6)
  $core.Map<$core.int, Pen> get penPool => $_getMap(5);
}

enum NotePageItem_Content {
  path, 
  mattingMarkId, 
  mattingResultId, 
  notSet
}

class NotePageItem extends $pb.GeneratedMessage {
  factory NotePageItem({
    Path? path,
    $core.int? mattingMarkId,
    $core.int? mattingResultId,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (mattingMarkId != null) {
      $result.mattingMarkId = mattingMarkId;
    }
    if (mattingResultId != null) {
      $result.mattingResultId = mattingResultId;
    }
    return $result;
  }
  NotePageItem._() : super();
  factory NotePageItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NotePageItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, NotePageItem_Content> _NotePageItem_ContentByTag = {
    1 : NotePageItem_Content.path,
    2 : NotePageItem_Content.mattingMarkId,
    3 : NotePageItem_Content.mattingResultId,
    0 : NotePageItem_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotePageItem', createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<Path>(1, _omitFieldNames ? '' : 'path', subBuilder: Path.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'mattingMarkId', $pb.PbFieldType.OU3, protoName: 'mattingMarkId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'mattingResultId', $pb.PbFieldType.OU3, protoName: 'mattingResultId')
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
  Path get path => $_getN(0);
  @$pb.TagNumber(1)
  set path(Path v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);
  @$pb.TagNumber(1)
  Path ensurePath() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get mattingMarkId => $_getIZ(1);
  @$pb.TagNumber(2)
  set mattingMarkId($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMattingMarkId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMattingMarkId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get mattingResultId => $_getIZ(2);
  @$pb.TagNumber(3)
  set mattingResultId($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMattingResultId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMattingResultId() => clearField(3);
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
    PenType? penType,
    $core.int? color,
    $core.double? strokeWidth,
  }) {
    final $result = create();
    if (penType != null) {
      $result.penType = penType;
    }
    if (color != null) {
      $result.color = color;
    }
    if (strokeWidth != null) {
      $result.strokeWidth = strokeWidth;
    }
    return $result;
  }
  Pen._() : super();
  factory Pen.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Pen.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Pen', createEmptyInstance: create)
    ..e<PenType>(1, _omitFieldNames ? '' : 'penType', $pb.PbFieldType.OE, protoName: 'penType', defaultOrMaker: PenType.PT_BALL_POINT_PEN, valueOf: PenType.valueOf, enumValues: PenType.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'color', $pb.PbFieldType.OU3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'strokeWidth', $pb.PbFieldType.OF, protoName: 'strokeWidth')
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
  PenType get penType => $_getN(0);
  @$pb.TagNumber(1)
  set penType(PenType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPenType() => $_has(0);
  @$pb.TagNumber(1)
  void clearPenType() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get color => $_getIZ(1);
  @$pb.TagNumber(2)
  set color($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearColor() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get strokeWidth => $_getN(2);
  @$pb.TagNumber(3)
  set strokeWidth($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStrokeWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearStrokeWidth() => clearField(3);
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
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OD)
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
  set x($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => clearField(2);
}

class MattingResult extends $pb.GeneratedMessage {
  factory MattingResult({
    $core.int? bookPageNumber,
    $core.int? bookPageMattingMarkId,
    ImageType? imageType,
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
    if (imageData != null) {
      $result.imageData = imageData;
    }
    return $result;
  }
  MattingResult._() : super();
  factory MattingResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingResult', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'bookPageNumber', $pb.PbFieldType.OU3, protoName: 'bookPageNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'bookPageMattingMarkId', $pb.PbFieldType.OU3, protoName: 'bookPageMattingMarkId')
    ..e<ImageType>(3, _omitFieldNames ? '' : 'imageType', $pb.PbFieldType.OE, protoName: 'imageType', defaultOrMaker: ImageType.IT_PNG, valueOf: ImageType.valueOf, enumValues: ImageType.values)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'imageData', $pb.PbFieldType.OY, protoName: 'imageData')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MattingResult clone() => MattingResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MattingResult copyWith(void Function(MattingResult) updates) => super.copyWith((message) => updates(message as MattingResult)) as MattingResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MattingResult create() => MattingResult._();
  MattingResult createEmptyInstance() => create();
  static $pb.PbList<MattingResult> createRepeated() => $pb.PbList<MattingResult>();
  @$core.pragma('dart2js:noInline')
  static MattingResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MattingResult>(create);
  static MattingResult? _defaultInstance;

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
  $core.List<$core.int> get imageData => $_getN(3);
  @$pb.TagNumber(4)
  set imageData($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasImageData() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageData() => clearField(4);
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
}

class MattingMarkHorizontal extends $pb.GeneratedMessage {
  factory MattingMarkHorizontal({
    $core.double? startX,
    $core.double? endX,
    $core.double? height,
  }) {
    final $result = create();
    if (startX != null) {
      $result.startX = startX;
    }
    if (endX != null) {
      $result.endX = endX;
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
    ..a<$core.double>(1, _omitFieldNames ? '' : 'startX', $pb.PbFieldType.OD, protoName: 'startX')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'endX', $pb.PbFieldType.OD, protoName: 'endX')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OF)
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
  $core.double get startX => $_getN(0);
  @$pb.TagNumber(1)
  set startX($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartX() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get endX => $_getN(1);
  @$pb.TagNumber(2)
  set endX($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEndX() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndX() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get height => $_getN(2);
  @$pb.TagNumber(3)
  set height($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);
}

class MattingMarkVertical extends $pb.GeneratedMessage {
  factory MattingMarkVertical({
    $core.double? startY,
    $core.double? endY,
    $core.double? width,
  }) {
    final $result = create();
    if (startY != null) {
      $result.startY = startY;
    }
    if (endY != null) {
      $result.endY = endY;
    }
    if (width != null) {
      $result.width = width;
    }
    return $result;
  }
  MattingMarkVertical._() : super();
  factory MattingMarkVertical.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkVertical.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkVertical', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'startY', $pb.PbFieldType.OD, protoName: 'startY')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'endY', $pb.PbFieldType.OD, protoName: 'endY')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'width', $pb.PbFieldType.OF)
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
  $core.double get startY => $_getN(0);
  @$pb.TagNumber(1)
  set startY($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartY() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartY() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get endY => $_getN(1);
  @$pb.TagNumber(2)
  set endY($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEndY() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndY() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get width => $_getN(2);
  @$pb.TagNumber(3)
  set width($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => clearField(3);
}

class MattingMarkLine extends $pb.GeneratedMessage {
  factory MattingMarkLine({
    $core.double? startX,
    $core.double? endX,
    $core.double? startY,
    $core.double? endY,
    $core.double? width,
  }) {
    final $result = create();
    if (startX != null) {
      $result.startX = startX;
    }
    if (endX != null) {
      $result.endX = endX;
    }
    if (startY != null) {
      $result.startY = startY;
    }
    if (endY != null) {
      $result.endY = endY;
    }
    if (width != null) {
      $result.width = width;
    }
    return $result;
  }
  MattingMarkLine._() : super();
  factory MattingMarkLine.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MattingMarkLine.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MattingMarkLine', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'startX', $pb.PbFieldType.OD, protoName: 'startX')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'endX', $pb.PbFieldType.OD, protoName: 'endX')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'startY', $pb.PbFieldType.OD, protoName: 'startY')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'endY', $pb.PbFieldType.OD, protoName: 'endY')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'width', $pb.PbFieldType.OF)
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
  set startX($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartX() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get endX => $_getN(1);
  @$pb.TagNumber(2)
  set endX($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEndX() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndX() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get startY => $_getN(2);
  @$pb.TagNumber(3)
  set startY($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStartY() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartY() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get endY => $_getN(3);
  @$pb.TagNumber(4)
  set endY($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEndY() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndY() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get width => $_getN(4);
  @$pb.TagNumber(5)
  set width($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearWidth() => clearField(5);
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
    ..a<$core.double>(1, _omitFieldNames ? '' : 'leftTopX', $pb.PbFieldType.OD, protoName: 'leftTopX')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'leftTopY', $pb.PbFieldType.OD, protoName: 'leftTopY')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'rightBottomX', $pb.PbFieldType.OD, protoName: 'rightBottomX')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'rightBottomY', $pb.PbFieldType.OD, protoName: 'rightBottomY')
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
  set leftTopX($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLeftTopX() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeftTopX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get leftTopY => $_getN(1);
  @$pb.TagNumber(2)
  set leftTopY($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLeftTopY() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeftTopY() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get rightBottomX => $_getN(2);
  @$pb.TagNumber(3)
  set rightBottomX($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRightBottomX() => $_has(2);
  @$pb.TagNumber(3)
  void clearRightBottomX() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get rightBottomY => $_getN(3);
  @$pb.TagNumber(4)
  set rightBottomY($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRightBottomY() => $_has(3);
  @$pb.TagNumber(4)
  void clearRightBottomY() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
