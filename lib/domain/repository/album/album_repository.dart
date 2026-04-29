import 'package:dartz/dartz.dart';

abstract class AlbumRepository {
  Future<Either> getAlbumSongs(String albumId);
  Future<Either> addOrRemoveFavoriteAlbums(String albumId);
  Future<void> deleteAlbums(List<String> albumIds);
  Future<bool> isFavoriteAlbum(String albumId);
  Future<Either> getFavoriteAlbums();
}
