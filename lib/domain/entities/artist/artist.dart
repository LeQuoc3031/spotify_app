class ArtistEntity {
  final String id;
  final String name;
  final String nameVie;
  final String description;
  final num totalAlbums;

  ArtistEntity({
    required this.id,
    required this.name,
    required this.nameVie,
    required this.description,
    required this.totalAlbums,
  });

  ArtistEntity copyWith({
    String? id,
    String? name,
    String? nameVie,
    String? description,
    num? totalAlbums,
  }) {
    return ArtistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVie: nameVie ?? this.nameVie,
      description: description ?? this.description,
      totalAlbums: totalAlbums ?? this.totalAlbums,
    );
  }
}
