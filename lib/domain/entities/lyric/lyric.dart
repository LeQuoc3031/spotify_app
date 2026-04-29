class LyricEntity {
  final String text;
  final Duration startTime;

  LyricEntity({required this.text, required this.startTime});

  LyricEntity copyWith({String? text, Duration? startTime}) {
    return LyricEntity(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
    );
  }
}
