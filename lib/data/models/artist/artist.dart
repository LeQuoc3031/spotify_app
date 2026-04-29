import 'package:spotify_app/domain/entities/artist/artist.dart';

class ArtistModel extends ArtistEntity {
  ArtistModel({
    required super.id,
    required super.name,
    required super.nameVie,
    required super.description,
    required super.totalAlbums,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'],
      name: json['name'],
      nameVie: json['nameVie'],
      description: json['description'],
      totalAlbums: json['totalAlbums'],
    );
  }

  @override
  ArtistEntity copyWith({
    String? id,
    String? name,
    String? nameVie,
    String? description,
    num? totalAlbums,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVie: nameVie ?? this.nameVie,
      description: description ?? this.description,
      totalAlbums: totalAlbums ?? this.totalAlbums,
    );
  }
}
