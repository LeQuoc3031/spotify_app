import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/repository/song/song_repository.dart';
import 'package:spotify_app/service_locator.dart';

class AddRecentlyPlayedUseCase implements Usecase<void, SongEntity> {
  @override
  Future<void> call({SongEntity? params}) async {
    return await sl<SongRepository>().addRecentlyPlayed(params!);
  }
}
