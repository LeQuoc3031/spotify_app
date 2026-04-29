import 'package:spotify_app/domain/entities/album/album.dart';

class AlbumModel extends AlbumEntity {
  AlbumModel({
    required super.artistId,
    required super.artist,
    required super.artistVie,
    required super.title,
    required super.titleVie,
    super.albumId,
    super.isFavorite,
    super.albumFavoriteId,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      artistId: json['artistId'],
      artist: json['artist'],
      artistVie: json['artistVie'],
      title: json['title'],
      titleVie: json['titleVie'],
    );
  }

  @override
  AlbumEntity copyWith({
    String? artistId,
    String? artist,
    String? artistVie,
    String? title,
    String? titleVie,
    String? albumId,
    bool? isFavorite,
    String? albumFavoriteId,
  }) {
    return AlbumModel(
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      artistVie: artistVie ?? this.artistVie,
      title: title ?? this.title,
      titleVie: titleVie ?? this.titleVie,
      albumId: albumId ?? this.albumId,
      isFavorite: isFavorite ?? this.isFavorite,
      albumFavoriteId: albumFavoriteId ?? this.albumFavoriteId,
    );
  }
}
