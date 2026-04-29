// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot, Timestamp;
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app/data/models/album/album.dart';
import 'package:spotify_app/data/models/song/song.dart';
import 'package:spotify_app/domain/entities/album/album.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';
import 'package:spotify_app/service_locator.dart';

abstract class AlbumFirebaseService {
  Future<Either> getAlbumSongs(String albumId);
  Future<Either> addOrRemoveFavoriteAlbums(String albumId);
  Future<void> deleteAlbums(List<String> albumIds);
  Future<bool> isFavoriteAlbum(String albumId);
  Future<Either> getFavoriteAlbums();
}

class AlbumFirebaseServiceImpl implements AlbumFirebaseService {
  @override
  Future<Either> getAlbumSongs(String albumId) async {
    try {
      List<SongEntity> songs = [];
      final data = await FirebaseFirestore.instance
          .collection('Songs')
          .where('albumId', isEqualTo: albumId)
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

  @override
  Future<Either> addOrRemoveFavoriteAlbums(String albumId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteAlbums = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('FavoriteAlbums')
          .where('albumId', isEqualTo: albumId)
          .get();

      if (favoriteAlbums.docs.isNotEmpty) {
        await favoriteAlbums.docs.first.reference.delete();
        isFavorite = false;
      } else {
        final albumFavoriteRef = firebaseFirestore
            .collection('Users')
            .doc(uId)
            .collection('FavoriteAlbums')
            .doc();
        await albumFavoriteRef.set({
          'id': albumFavoriteRef.id,
          'albumId': albumId,
          'addedDate': Timestamp.now(),
        });
        isFavorite = true;
      }

      return Right(isFavorite);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<void> deleteAlbums(List<String> albumIds) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;
      final batch = FirebaseFirestore.instance.batch();

      for (String id in albumIds) {
        final docRef = firebaseFirestore
            .collection('Users')
            .doc(uId)
            .collection('FavoriteAlbums')
            .doc(id);
        batch.delete(docRef);
      }

      // Thực thi toàn bộ lệnh xoá trong 1 lần
      await batch.commit();
    } catch (e) {
      print('deletePlayList error ==> $e');
    }
  }

  @override
  Future<bool> isFavoriteAlbum(String albumId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteAlbums = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('FavoriteAlbums')
          .where('albumId', isEqualTo: albumId)
          .get();

      if (favoriteAlbums.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either> getFavoriteAlbums() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      List<AlbumEntity> favoriteAlbums = [];
      final user = firebaseAuth.currentUser;

      String uId = user!.uid;

      QuerySnapshot favoriteSnapshot = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('FavoriteAlbums')
          .get();
      for (var element in favoriteSnapshot.docs) {
        String albumId = element['albumId'];
        final song = await firebaseFirestore
            .collection('Albums')
            .doc(albumId)
            .get();

        favoriteAlbums.add(
          AlbumModel.fromJson(song.data()!).copyWith(
            isFavorite: true,
            albumId: albumId,
            albumFavoriteId: element.id,
          ),
        );
      }
      return Right(favoriteAlbums);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }
}
