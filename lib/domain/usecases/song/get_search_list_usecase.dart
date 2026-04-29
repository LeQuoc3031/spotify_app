import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/song/song_repository.dart';
import 'package:spotify_app/service_locator.dart';

class GetSearchListUseCase implements Usecase<Either, DocumentSnapshot> {
  @override
  Future<Either> call({DocumentSnapshot? params}) async {
    return await sl<SongRepository>().getPlayList(lastDoc: params);
  }
}
