import 'package:spotify_app/domain/entities/lyric/lyric.dart';

class LyricModel extends LyricEntity {
  LyricModel({required super.text, required super.startTime});

  @override
  LyricModel copyWith({String? text, Duration? startTime}) {
    return LyricModel(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
    );
  }
}
