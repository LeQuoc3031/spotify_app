import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/data/sources/play_list/play_list_service.dart';
import 'package:spotify_app/service_locator.dart';

class AddSongToPlaylistUseCase
    implements Usecase<void, AddSongToPlaylistReq> {
  @override
  Future<void> call({AddSongToPlaylistReq? params}) async {
    return sl<PlayListService>().addSongToPlayList(params!);
  }
}
