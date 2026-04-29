import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/data/models/playlist/play_list.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/data/sources/play_list/play_list_service.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/service_locator.dart';

class PlayListRepositoryImpl implements PlayListRepository {
  @override
  Future<Either> getPlayList() async {
    return await sl<PlayListService>().getPlayList();
  }

  @override
  Future<void> createPlayList(String title) async {
    return await sl<PlayListService>().createPlayList(title);
  }

  @override
  Future<void> deletePlayList(List<String> playlistIds) async {
    return await sl<PlayListService>().deletePlayList(playlistIds);
  }

  @override
  Future<void> addSongToPlayList(
    AddSongToPlaylistReq addSongtoPlaylistReq,
  ) async {
    return await sl<PlayListService>().addSongToPlayList(addSongtoPlaylistReq);
  }

  @override
  Future<void> removeSongFromPlaylist(
    RemoveSongFromPlaylistReq addSongtoPlaylistReq,
  ) async {
    return await sl<PlayListService>().removeSongFromPlaylist(
      addSongtoPlaylistReq,
    );
  }

  @override
  Future<Either> getSongsInPlayList(PlayListEntity playListEntity) async {
    final playListModel = PlayListModel.fromEntity(playListEntity);
    return await sl<PlayListService>().getSongsInPlayList(playListModel);
  }
}
