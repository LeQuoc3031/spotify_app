import 'package:spotify_app/domain/entities/album/album.dart';

abstract class ArtistAlbumState {}

class ArtistAlbumInitial extends ArtistAlbumState {}

class ArtistAlbumLoading extends ArtistAlbumState {}

class ArtistAlbumLoaded extends ArtistAlbumState {
  final List<AlbumEntity> albums;
  ArtistAlbumLoaded({required this.albums});
}

class ArtistAlbumFailure extends ArtistAlbumState {}


