// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/models/album/album.dart';
import 'package:spotify_app/data/models/artist/artist.dart';
import 'package:spotify_app/data/models/song/song.dart';
import 'package:spotify_app/domain/entities/album/album.dart';
import 'package:spotify_app/domain/entities/artist/artist.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/album/is_favorite_album_usecase.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';
import 'package:spotify_app/service_locator.dart';

abstract class ArtistFirebaseService {
  Future<Either> getArtists();
  Future<Either> getArtistAlbums(String artistId);
  Future<Either> getArtistSongs(String artistId);
}

class ArtistFirebaseServiceImpl implements ArtistFirebaseService {
  @override
  Future<Either> getArtists() async {
    try {
      List<ArtistEntity> artists = [];
      final data = await FirebaseFirestore.instance.collection('Artists').get();

      for (var element in data.docs) {
        artists.add(ArtistModel.fromJson(element.data()));
      }

      return Right(artists);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either> getArtistAlbums(String artistId) async {
    try {
      List<AlbumEntity> albums = [];
      final data = await FirebaseFirestore.instance
          .collection('Albums')
          .where('artistId', isEqualTo: artistId)
          .get();

      for (var element in data.docs) {
        bool isFavorite = await sl<IsFavoriteAlbumUseCase>().call(
          params: element.reference.id,
        );
        albums.add(
          AlbumModel.fromJson(
            element.data(),
          ).copyWith(albumId: element.reference.id, isFavorite: isFavorite),
        );
      }
      return Right(albums);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either> getArtistSongs(String artistId) async {
    try {
      List<SongEntity> songs = [];
      final data = await FirebaseFirestore.instance
          .collection('Songs')
          .where('artistId', isEqualTo: artistId)
          .get();

      for (var element in data.docs) {
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );

        songs.add(
          SongModel.fromJson(
            element.data(),
          ).copyWith(isFavorite: isFavorite, songId: element.reference.id),
        );
      }

      return Right(songs);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }
}
