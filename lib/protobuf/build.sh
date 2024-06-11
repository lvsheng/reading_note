protoc -I=./ --dart_out=./ ./note.proto
sed -i '' '/class NotePageItem extends \$pb.GeneratedMessage {/a\
\  var selected = false;\
\  var iterateId = 0;\
' note.pb.dart
