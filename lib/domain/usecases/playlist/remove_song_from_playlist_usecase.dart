import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/data/sources/play_list/play_list_service.dart';
import 'package:spotify_app/service_locator.dart';

class RemoveSongFromPlaylistUseCase
    implements Usecase<void, RemoveSongFromPlaylistReq> {
  @override
  Future<void> call({RemoveSongFromPlaylistReq? params}) async {
    return sl<PlayListService>().removeSongFromPlaylist(params!);
  }
}
