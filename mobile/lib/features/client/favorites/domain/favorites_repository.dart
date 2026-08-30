import 'package:dartz/dartz.dart';
import 'package:mongez/core/error/failure.dart';
import 'package:mongez/features/client/favorites/data/models/favorite_model.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteModel>>> getFavorites();
  Future<Either<Failure, FavoriteModel>> addFavorite(int workerId);
  Future<Either<Failure, void>> removeFavorite(int id);
}
