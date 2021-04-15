
import 'package:hive/hive.dart';

part 'calculation.g.dart';

@HiveType(typeId: 0)
class Calculation extends HiveObject {
  @HiveField(0)
  final String expression;
  @HiveField(1)
  final double result;

  Calculation({required this.expression, required this.result});

  @override
  String toString() {
    return 'Calculation{expression: $expression, result: $result}';
  }
}
