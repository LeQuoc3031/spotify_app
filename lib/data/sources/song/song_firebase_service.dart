// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app/data/models/song/song.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';
import 'package:spotify_app/service_locator.dart';

abstract class SongFirebaseService {
  Future<Either> getNewSongs();
  Future<Either> getPlayList({DocumentSnapshot? lastDoc});
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getFavoriteSongs();
  Future<Either> getRecentlyPlayed();
  Future<void> addRecentlyPlayed(SongModel songModel);
  Future<Either> getSongSearch(String query);
}

class SongFirebaseServiceImpl implements SongFirebaseService {
  @override
  Future<Either> getNewSongs() async {
    try {
      List<SongEntity> songs = [];
      final data = await FirebaseFirestore.instance
          .collection('Songs')
          .orderBy('releaseDate', descending: true)
          .limit(3)
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
      print('getNewSongs ==> $e');
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<Either> getPlayList({DocumentSnapshot? lastDoc}) async {
    try {
      // 1. Tạo query cơ bản: Sắp xếp theo ngày phát hành giảm dần và giới hạn 10 bài
      Query query = FirebaseFirestore.instance
          .collection('Songs')
          .orderBy('releaseDate', descending: true)
          .limit(10);

      // 2. Nếu có bản ghi cuối của trang trước (lastDoc), bắt đầu lấy từ sau bản ghi đó
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      var data = await query.get();

      List<SongEntity> songs = [];
      for (var element in data.docs) {
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );

        songs.add(
          SongModel.fromJson(
            element.data() as Map<String, dynamic>,
          ).copyWith(isFavorite: isFavorite, songId: element.reference.id),
        );
      }
      return Right({
        'songs': songs,
        'lastDoc': data.docs.isNotEmpty ? data.docs.last : null,
      });
    } catch (e) {
      print(e);
      return const Left('An error occurred, please try again.');
    }
  }

  @override
  Future<Either> getSongSearch(String query) async {
    try {
      // String cleanQuery = removeDiacritics(query);
      // 1. Tạo query cơ bản: Sắp xếp theo ngày phát hành giảm dần và giới hạn 10 bài
      final data = await FirebaseFirestore.instance
          .collection('Songs')
          .where('searchKeywords', arrayContains: query)
          .get();

      List<SongEntity> songs = [];
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
      print('songs ==> $songs');
      return Right(songs);
    } catch (e) {
      print(e);
      return const Left('An error occurred, please try again.');
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();

      if (favoriteSongs.docs.isNotEmpty) {
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        await firebaseFirestore
            .collection('Users')
            .doc(uId)
            .collection('Favorites')
            .add({'songId': songId, 'addedDate': Timestamp.now()});
        isFavorite = true;
      }

      return Right(isFavorite);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();

      if (favoriteSongs.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either> getFavoriteSongs() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      List<SongEntity> favoriteSongs = [];
      final user = firebaseAuth.currentUser;

      String uId = user!.uid;

      QuerySnapshot favoriteSnapshot = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('Favorites')
          .get();
      for (var element in favoriteSnapshot.docs) {
        String songId = element['songId'];
        final song = await firebaseFirestore
            .collection('Songs')
            .doc(songId)
            .get();

        favoriteSongs.add(
          SongModel.fromJson(
            song.data()!,
          ).copyWith(isFavorite: true, songId: songId),
        );
      }
      return Right(favoriteSongs);
    } catch (e) {
      return const Left('An error occurred, Please try again');
    }
  }

  @override
  Future<void> addRecentlyPlayed(SongModel songModel) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;
      if (user == null) return;
      String uId = user.uid;
      final Map<String, dynamic> song = songModel.toJson();
      final recentCollection = firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('RecentlyPlayed');
      // 1. Thêm hoặc Cập nhật bài hát (dùng songId làm doc ID)
      // Khi bạn dùng doc(songId).set(...), nếu ID đã tồn tại,
      // nó sẽ tự động ghi đè (Update). Nếu chưa có, nó sẽ tạo mới (Add).
      // Điều này giải quyết ngay vấn đề "trùng ID".
      // Field 'playedAt' dùng để sắp xếp bài nào mới nghe nhất
      // await recentCollection.doc(song.songId).set({
      //   'songId': song.songId ,
      //   'artist': song.artist,
      //   'artistId': song.artistId,
      //   'artistVie': song.artistVie,
      //   'duration': song.duration,
      //   'title': song.title,
      //   'titleVie': song.titleVie,
      //   'playedAt': Timestamp.now(),
      // });

      await recentCollection.doc(songModel.songId).set(song);

      // 2. Kiểm tra số lượng và xóa bài cũ nhất nếu vượt quá 5
      final snapshot = await recentCollection
          .orderBy('playedAt', descending: true)
          .get();

      if (snapshot.docs.length > 5) {
        // Lấy tất cả các bài từ vị trí thứ 6 trở đi và xóa chúng
        for (var i = 5; i < snapshot.docs.length; i++) {
          await recentCollection.doc(snapshot.docs[i].id).delete();
        }
      }
    } catch (e) {
      print('error addRecentlyPlayed: $e');
    }
  }

  @override
  Future<Either> getRecentlyPlayed() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final user = firebaseAuth.currentUser;

      String uId = user!.uid;
      final recentCollection = await firebaseFirestore
          .collection('Users')
          .doc(uId)
          .collection('RecentlyPlayed')
          .orderBy('playedAt', descending: true)
          .limit(5)
          .get();

      List<SongEntity> recentlyPlayed = [];

      for (var element in recentCollection.docs) {
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );

        final song = await firebaseFirestore
            .collection('Songs')
            .doc(element.reference.id)
            .get();

        recentlyPlayed.add(
          SongModel.fromJson(
            song.data()!,
          ).copyWith(isFavorite: isFavorite, songId: element.reference.id),
        );
      }

      return Right(recentlyPlayed);
    } catch (e) {
      print('getRecentlySongs ==> $e');
      return const Left('An error occurred, Please try again');
    }
  }
}
