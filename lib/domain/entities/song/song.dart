// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class SongEntity {
  final String title;
  final String titleVie;
  final String artist;
  final String artistVie;
  final num duration;
  final Timestamp releaseDate;
  final String artistId;
  final String albumId;
  final String? songId;
  final bool? isFavorite;
  final String? lyrics;

  const SongEntity({
    required this.title,
    required this.titleVie,
    required this.artist,
    required this.artistVie,
    required this.duration,
    required this.releaseDate,
    required this.artistId,
    required this.albumId,
    this.songId,
    this.isFavorite,
    this.lyrics,
  });

  SongEntity copyWith({
    String? title,
    String? titleVie,
    String? artist,
    String? artistVie,
    num? duration,
    Timestamp? releaseDate,
    String ? artistId,
    String ? albumId,
    String? songId,
    bool? isFavorite,
    String? lyrics,
  }) {
    return SongEntity(
      title: title ?? this.title,
      titleVie: titleVie ?? this.titleVie,
      artist: artist ?? this.artist,
      artistVie: artistVie ?? this.artistVie,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      artistId: artistId ?? this.artistId,
      albumId: albumId ?? this.albumId,
      songId: songId ?? this.songId,
      isFavorite: isFavorite ?? this.isFavorite,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
