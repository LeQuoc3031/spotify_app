import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/playlist/play_list_repository.dart';
import 'package:spotify_app/service_locator.dart';

class GetPlayListUseCase implements Usecase<Either, dynamic> {
  @override
  Future<Either> call({dynamic params}) async {
    return await sl<PlayListRepository>().getPlayList();
  }
}
