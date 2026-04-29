import 'package:spotify_app/domain/entities/album/album.dart';

abstract class FavoriteAlbumState {}

class FavoriteAlbumInitial extends FavoriteAlbumState {}

class FavoriteAlbumLoading extends FavoriteAlbumState {}

class FavoriteAlbumLoaded extends FavoriteAlbumState {
  final List<AlbumEntity> albums;

  FavoriteAlbumLoaded({required this.albums});
}

class FavoriteAlbumFailure extends FavoriteAlbumState {}
