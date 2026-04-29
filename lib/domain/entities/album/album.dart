class AlbumEntity {
  final String artistId;
  final String artist;
  final String artistVie;
  final String title;
  final String titleVie;
  final String? albumId;
  final bool? isFavorite;
  final String? albumFavoriteId;

  AlbumEntity({
    required this.artistId,
    required this.artist,
    required this.artistVie,
    required this.title,
    required this.titleVie,
    this.albumId,
    this.isFavorite,
    this.albumFavoriteId,
  });

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
    return AlbumEntity(
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
