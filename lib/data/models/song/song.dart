import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_app/domain/entities/song/song.dart';

class SongModel extends SongEntity {
  SongModel({
    required super.title,
    required super.titleVie,
    required super.artist,
    required super.artistVie,
    required super.duration,
    required super.releaseDate,
    required super.artistId,
    required super.albumId,
    super.songId,
    super.isFavorite,
    super.lyrics,
  });

  // Chuyển từ Firebase Map sang Model
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      title: json['title'],
      titleVie: json['titleVie'],
      artist: json['artist'],
      artistVie: json['artistVie'],
      duration: json['duration'],
      releaseDate: json['releaseDate'],
      artistId: json['artistId'],
      albumId: json['albumId'],
    );
  }
  // Chuyển từ Entity sang Model
  factory SongModel.fromEntity(SongEntity entity) {
    return SongModel(
      songId: entity.songId,
      title: entity.title,
      titleVie: entity.titleVie,
      artist: entity.artist,
      artistId: entity.artistId,
      artistVie: entity.artistVie,
      duration: entity.duration,
      releaseDate: entity.releaseDate,
      albumId: entity.albumId,
    );
  }
  // Chuyển từ Model sang Map để đẩy lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'title': title,
      'titleVie': titleVie,
      'artist': artist,
      'artistId': artistId,
      'artistVie': artistVie,
      'duration': duration,
      'playedAt': Timestamp.now(),
    };
  }

  @override
  SongModel copyWith({
    String? title,
    String? titleVie,
    String? artist,
    String? artistVie,
    num? duration,
    Timestamp? releaseDate,
    String? artistId,
    String? albumId,
    String? songId,
    bool? isFavorite,
    String? lyrics,
  }) {
    return SongModel(
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
