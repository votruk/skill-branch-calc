import 'package:calc_skill_branch/view/calc/calc_button.dart';

class OperandAndOperator {
  final double operand;
  final Operator operator;

  OperandAndOperator(this.operand, this.operator);

  @override
  String toString() {
    return 'OperandAndOperator{operand: $operand, operator: $operator}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperandAndOperator &&
          runtimeType == other.runtimeType &&
          operand == other.operand &&
          operator == other.operator;

  @override
  int get hashCode => operand.hashCode ^ operator.hashCode;
}
