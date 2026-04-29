// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/data/models/playlist/play_list.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/data/models/song/song.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:collection/collection.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';
import 'package:spotify_app/service_locator.dart';

abstract class PlayListService {
  Future<Either> getPlayList();
  Future<void> createPlayList(String title);
  Future<void> deletePlayList(List<String> playlistIds);
  Future<void> addSongToPlayList(AddSongToPlaylistReq addSongtoPlaylistReq);
  Future<void> removeSongFromPlaylist(
    RemoveSongFromPlaylistReq removeSongFromPlaylistReq,
  );
  Future<Either> getSongsInPlayList(PlayListModel playListModel);
}

class PlayListServiceImpl implements PlayListService {
  @override
  Future<Either> getPlayList() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;
      List<PlayListEntity> playLists = []; // List<PlayListModel>

      final snapshot = await firebaseFirestore
          .collection('Playlists')
          .where('creatorId', isEqualTo: uId)
          .get();

      for (var element in snapshot.docs) {
        playLists.add(PlayListModel.fromJson(element.data()));
      }

      return Right(playLists);
    } catch (e) {
      print('getPlayList ==> $e');
      return const Left('An error occurred!');
    }
  }

  @override
  Future<void> createPlayList(String title) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;
      final playlistRef = firebaseFirestore.collection('Playlists').doc();

      await playlistRef.set({
        'playlistId': playlistRef.id,
        'title': title,
        'creatorId': uId,
        'songs': [], // Mới tạo thì danh sách bài hát rỗng
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('createPlayList error ==> $e');
    }
  }

  @override
  Future<void> deletePlayList(List<String> playlistIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (String id in playlistIds) {
        final docRef = FirebaseFirestore.instance
            .collection('Playlists')
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
  Future<void> addSongToPlayList(AddSongToPlaylistReq req) async {
    try {
      await FirebaseFirestore.instance
          .collection('Playlists')
          .doc(req.playlistId)
          .update({
            'songs': FieldValue.arrayUnion([
              req.songId,
            ]), // Thêm ID bài hát vào mảng
          });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> removeSongFromPlaylist(RemoveSongFromPlaylistReq req) async {
    try {
      await FirebaseFirestore.instance
          .collection('Playlists')
          .doc(req.playlistId)
          .update({
            'songs': FieldValue.arrayRemove([
              req.songId,
            ]), // Xoá đúng ID này khỏi mảng
          });
    } catch (e) {
      print('removeSongFromPlaylist error ==> $e');
    }
  }

  @override
  Future<Either> getSongsInPlayList(PlayListModel playListModel) async {
    try {
      List<SongEntity> songs = [];
      if (playListModel.songs.isEmpty) return  Right(songs);

      // Chia list ID thành các nhóm, mỗi nhóm tối đa 30 ID
      final chunks = playListModel.songs.slices(30);

      // Tạo danh sách các Future để gọi đồng thời
      final futures = chunks.map((chunk) {
        return FirebaseFirestore.instance
            .collection('Songs')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
      });

      // Chạy tất cả các query cùng lúc
      final snapshots = await Future.wait(futures);

      // Gộp tất cả các bài hát lại thành một danh sách duy nhất
      snapshots
          .expand((snapshot) => snapshot.docs)
          .map((doc) => SongModel.fromJson(doc.data()))
          .toList();

      
      for (var element in snapshots.first.docs) {
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        // print(isFavorite);
        // print(element.data());
        songs.add(
          SongModel.fromJson(
            element.data(),
          ).copyWith(isFavorite: isFavorite, songId: element.reference.id),
        );
      }

      // print('getSongsInPlayList ==> ${snapshots.first.docs.first.data()}');

      return Right(songs);
    } catch (e) {
      print('getSongsInPlayList error ==> $e');
      return const Left('An error occurred!');
    }
  }
}
