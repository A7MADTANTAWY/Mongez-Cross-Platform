import 'package:dartz/dartz.dart';
import 'package:mongez/core/error/failure.dart';
import 'package:mongez/features/client/home/data/models/categories.dart';

abstract class HomeRepo {
  Future<Either<Failure, List<CategoriesModel>>> getAllCategories({
    bool force = false,
  });
}

