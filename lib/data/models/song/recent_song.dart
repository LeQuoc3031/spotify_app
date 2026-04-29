import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_app/domain/entities/song/recent_song.dart';

class RecentSongModel extends RecentSongEntity {
  RecentSongModel({
    required super.songId,
    required super.artist,
    required super.artistId,
    required super.artistVie,
    required super.duration,
    required super.title,
    required super.titleVie,
    required super.playedAt,
    super.isFavorite,
  });

  factory RecentSongModel.fromJson(Map<String, dynamic> json) {
    return RecentSongModel(
      songId: json['songId'],
      artist: json['artist'],
      artistId: json['artistId'],
      artistVie: json['artistVie'],
      duration: json['duration'],
      title: json['title'],
      titleVie: json['titleVie'],
      playedAt: json['playedAt'],
    );
  }

  @override
  RecentSongModel copyWith({
    String? songId,
    String? artist,
    String? artistId,
    String? artistVie,
    num? duration,
    String? title,
    String? titleVie,
    Timestamp? playedAt,
    bool? isFavorite,
  }) {
    return RecentSongModel(
      songId: songId ?? this.songId,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      artistVie: artistVie ?? this.artistVie,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      titleVie: titleVie ?? this.titleVie,
      playedAt: playedAt ?? this.playedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
