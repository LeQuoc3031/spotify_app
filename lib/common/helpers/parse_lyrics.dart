import 'package:spotify_app/data/models/lyric/lyric.dart';

List<LyricModel> parseLyrics(String lrcContent) {
  List<LyricModel> lyrics = [];
  RegExp regExp = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');

  for (var line in lrcContent.split('\n')) {
    var match = regExp.firstMatch(line);
    if (match != null) {
      int min = int.parse(match.group(1)!);
      double sec = double.parse(match.group(2)!);
      Duration time = Duration(
        minutes: min,
        seconds: sec.toInt(),
        milliseconds: ((sec % 1) * 1000).toInt(),
      );
      lyrics.add(LyricModel(text: match.group(3)!.trim(), startTime: time));
    }
  }
  return lyrics;
}
