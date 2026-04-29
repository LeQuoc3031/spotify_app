// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentSongEntity {
  final String songId;
  final String artist;
  final String artistId;
  final String artistVie;
  final num duration;
  final String title;
  final String titleVie;
  final Timestamp playedAt;
  final bool? isFavorite;
  RecentSongEntity({
    required this.songId,
    required this.artist,
    required this.artistId,
    required this.artistVie,
    required this.duration,
    required this.title,
    required this.titleVie,
    required this.playedAt,
    this.isFavorite,
  });

  RecentSongEntity copyWith({
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
    return RecentSongEntity(
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
