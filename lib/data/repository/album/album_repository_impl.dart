import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/sources/album/album_firebase_service.dart';
import 'package:spotify_app/domain/repository/album/album_repository.dart';
import 'package:spotify_app/service_locator.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  @override
  Future<Either> getAlbumSongs(String albumId) {
    return sl<AlbumFirebaseService>().getAlbumSongs(albumId);
  }

  @override
  Future<Either> addOrRemoveFavoriteAlbums(String albumId) async {
    return await sl<AlbumFirebaseService>().addOrRemoveFavoriteAlbums(albumId);
  }

  @override
  Future<bool> isFavoriteAlbum(String albumId) async {
    return await sl<AlbumFirebaseService>().isFavoriteAlbum(albumId);
  }

  @override
  Future<Either> getFavoriteAlbums() async {
    return await sl<AlbumFirebaseService>().getFavoriteAlbums();
  }

  @override
  Future<void> deleteAlbums(List<String> albumIds) async {
    return await sl<AlbumFirebaseService>().deleteAlbums(albumIds);
  }
}
