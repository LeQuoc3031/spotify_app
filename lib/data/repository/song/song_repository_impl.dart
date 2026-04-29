import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/models/song/song.dart';
import 'package:spotify_app/data/sources/song/song_firebase_service.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/repository/song/song_repository.dart';
import 'package:spotify_app/service_locator.dart';

class SongRepositoryImpl implements SongRepository {
  @override
  Future<Either> getNewSongs() async {
    return await sl<SongFirebaseService>().getNewSongs();
  }

  @override
  Future<Either> getPlayList({DocumentSnapshot? lastDoc}) async {
    return await sl<SongFirebaseService>().getPlayList(lastDoc: lastDoc);
  }

  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    return await sl<SongFirebaseService>().addOrRemoveFavoriteSongs(songId);
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().isFavoriteSong(songId);
  }

  @override
  Future<Either> getFavoriteSongs() async {
    return await sl<SongFirebaseService>().getFavoriteSongs();
  }

  @override
  Future<void> addRecentlyPlayed(SongEntity song) async {
    final songModel = SongModel.fromEntity(song);
    return await sl<SongFirebaseService>().addRecentlyPlayed(songModel);
  }

  @override
  Future<Either> getRecentlyPlayed() async {
    return await sl<SongFirebaseService>().getRecentlyPlayed();
  }
}
