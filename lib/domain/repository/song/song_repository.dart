import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:spotify_app/domain/entities/song/song.dart';

abstract class SongRepository {
  Future<Either> getNewSongs();
  Future<Either> getPlayList({DocumentSnapshot? lastDoc});
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getFavoriteSongs();
  Future<void> addRecentlyPlayed(SongEntity song);
  Future<Either> getRecentlyPlayed();
}
