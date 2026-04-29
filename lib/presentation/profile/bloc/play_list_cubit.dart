// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/playlist/add_song_to_playlist_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/delete_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/get_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/get_song_in_playlist_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/remove_song_from_playlist_usecase.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_state.dart';
import 'package:spotify_app/service_locator.dart';

class PlayListCubit extends Cubit<PlayListState> {
  List<SongEntity> playlistSongs = [];
  List<PlayListEntity> playListsEntity = [];
  PlayListCubit() : super(PlayListInitial()) {
    // getPlayList();
  }

  Future<void> getPlayList() async {
    if (!isClosed) {
      emit(PlayListLoading());
    }
    final playLists = await sl<GetPlayListUseCase>().call();

    playLists.fold((l) => emit(PlayListLoadFailure()), (data) {
      if (!isClosed) {
        print('data: $data');
        emit(PlayListLoaded(playLists: data));
      }
    });
  }

  Future<void> addSongToPlaylist({required AddSongToPlaylistReq params}) async {
    // Không nhất thiết phải emit Loading nếu bạn không muốn hiện loading spinner
    try {
      await sl<AddSongToPlaylistUseCase>().call(params: params);
      emit(AddSongToPlaylistSuccess("Đã thêm vào playlist thành công!"));
    } catch (e) {
      emit(AddSongToPlaylistFailure("Lỗi: ${e.toString()}"));
    }
  }

  Future<void> deletePlaylist({required List<String> selectedIds}) async {
    try {
      await sl<DeletePlayListUseCase>().call(params: selectedIds.toList());
      // playListsEntity.removeWhere(
      //   (playlist) => selectedIds.contains(playlist.playlistId),
      // );

       emit(PlayListLoaded(playLists: playListsEntity));
    } catch (e) {
      // Emit lỗi hoặc hiển thị thông báo
      print('removeSongFromPlaylist error ==> $e');
    }
  }

  Future<void> removeSongFromPlaylist({
    required RemoveSongFromPlaylistReq req,
  }) async {
    try {
      await sl<RemoveSongFromPlaylistUseCase>().call(params: req);
      playlistSongs.removeWhere((song) => song.songId == req.songId);
      emit(LoadedSongInPlayList(songs: playlistSongs));
    } catch (e) {
      // Emit lỗi hoặc hiển thị thông báo
      print('removeSongFromPlaylist error ==> $e');
    }
  }

  Future<void> getSongInPlayList(PlayListEntity playlistEntity) async {
    try {
      emit(LoadingSongInPlayList());

      final songs = await sl<GetSongInPlaylistUseCase>().call(
        params: playlistEntity,
      );

      print('songs: $songs');

      songs.fold(
        (l) {
          if (!isClosed) {
            emit(FailureSongInPlayList());
          }
        },
        (data) {
          if (!isClosed) {
            print('data: $data');
            playlistSongs = data;

            emit(LoadedSongInPlayList(songs: playlistSongs));
          }
        },
      );
    } catch (e) {
      // print('getSongInPlayList error ==> $e');
    }
  }
}
