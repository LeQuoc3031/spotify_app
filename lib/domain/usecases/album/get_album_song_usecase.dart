import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/album/album_repository.dart';
import 'package:spotify_app/service_locator.dart';

class GetAlbumSongUseCase implements Usecase<Either, String> {
  @override
  Future<Either> call({String? params}) async {
    return await sl<AlbumRepository>().getAlbumSongs(params!);
  }
}
