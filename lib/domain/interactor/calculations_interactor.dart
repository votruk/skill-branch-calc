import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:calc_skill_branch/domain/repository/calculations_repository.dart';

class CalculationsInteractor {
  static const int _maxItemsInHistoryCount = 50;

  final CalculationsRepository _calculationsRepository;

  CalculationsInteractor(this._calculationsRepository);

  Stream<List<Calculation>> observeCalculations() =>
      _calculationsRepository.observeCalculations();

  Future<void> addCalculationWithLimit(final Calculation calculation) async {
    await _calculationsRepository.addCalculation(calculation);
    final List<Calculation> calculations =
        await _calculationsRepository.getCalculations();
    if (calculations.length > _maxItemsInHistoryCount) {
      await _calculationsRepository.removeAt(0);
    }
  }
}
