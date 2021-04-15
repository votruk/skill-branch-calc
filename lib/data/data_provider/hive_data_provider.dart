import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:hive/hive.dart';

class HiveDataProvider {
  HiveBoxProvider<Calculation> get calculationsBoxProvider =>
      () => Hive.openBox<Calculation>("calculations");
}

typedef HiveBoxProvider<T extends HiveObject> = Future<Box<T>> Function();
