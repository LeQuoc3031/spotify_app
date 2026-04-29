import 'package:spotify_app/data/models/lyric/lyric.dart';
import 'package:spotify_app/domain/entities/song/song.dart';

abstract class SongPlayerState {}

class SongPlayerInitial extends SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final List<LyricModel> lyrics;
  final int currentLyricIndex;
  final bool isPlaying;
  final SongEntity? songEntity;

  SongPlayerLoaded({
    required this.lyrics,
    this.currentLyricIndex = 0,
    this.isPlaying = false,
    this.songEntity,
});

  // Hàm copyWith để cập nhật từng phần mà không mất dữ liệu cũ
  SongPlayerLoaded copyWith({
    List<LyricModel>? lyrics,
    int? currentLyricIndex,
    bool? isPlaying,
    SongEntity? songEntity,
  }) {
    return SongPlayerLoaded(
      lyrics: lyrics ?? this.lyrics,
      currentLyricIndex: currentLyricIndex ?? this.currentLyricIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      songEntity: songEntity ?? this.songEntity,
    );
  }
}

class SongPlayerFailure extends SongPlayerState {}
