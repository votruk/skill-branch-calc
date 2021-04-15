import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:calc_skill_branch/data/data_provider/hive_data_provider.dart';
import 'package:hive/hive.dart';

class CalculationsRepository {
  final HiveBoxProvider<Calculation> _calculationsBoxProvider;

  CalculationsRepository(this._calculationsBoxProvider);

  Stream<List<Calculation>> observeCalculations() async* {
    final Box<Calculation> box = await _calculationsBoxProvider();
    yield box.values.toList();
    await for (BoxEvent _ in box.watch()) {
      yield box.values.toList();
    }
  }

  Future<List<Calculation>> getCalculations() async {
    final Box<Calculation> box = await _calculationsBoxProvider();
    return box.values.toList();
  }

  Future<void> addCalculation(final Calculation calculation) async {
    final Box<Calculation> box = await _calculationsBoxProvider();
    box.add(calculation);
  }

  Future<void> removeAt(final int index) async {
    final Box<Calculation> box = await _calculationsBoxProvider();
    box.deleteAt(index);
  }
}
