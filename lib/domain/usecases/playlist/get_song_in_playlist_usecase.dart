import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/service_locator.dart';

class GetSongInPlaylistUseCase implements Usecase<Either, PlayListEntity> {
  @override
  Future<Either> call({PlayListEntity? params}) async {
    return await sl<PlayListRepository>().getSongsInPlayList(params!);
  }
}
