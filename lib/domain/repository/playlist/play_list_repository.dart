import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';

abstract class PlayListRepository {
  Future<Either> getPlayList();
  Future<void> createPlayList(String title);
  Future<void> deletePlayList(List<String> playlistIds);
  Future<void> addSongToPlayList(AddSongToPlaylistReq addSongtoPlaylistReq);
  Future<void> removeSongFromPlaylist(
    RemoveSongFromPlaylistReq addSongtoPlaylistReq,
  );

  Future<Either> getSongsInPlayList(PlayListEntity playListEntity);
}
