abstract class CalcButton {
  const CalcButton();

  String get text;
}

class EmptyButton extends CalcButton {
  const EmptyButton();

  @override
  String get text => "";
}

class NumberButton extends CalcButton {
  final Number number;

  const NumberButton(this.number);

  @override
  String get text => number.value.toString();

  @override
  String toString() {
    return 'NumberButton{number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberButton &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}

class Number {
  final int value;

  const Number._(this.value);

  static const Number zero = Number._(0);
  static const Number one = Number._(1);
  static const Number two = Number._(2);
  static const Number three = Number._(3);
  static const Number four = Number._(4);
  static const Number five = Number._(5);
  static const Number six = Number._(6);
  static const Number seven = Number._(7);
  static const Number eight = Number._(8);
  static const Number nine = Number._(9);

  @override
  String toString() {
    return 'Number{value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class OperatorButton extends CalcButton {
  final Operator operator;

  const OperatorButton(this.operator);

  @override
  String get text => operator.text;

  @override
  String toString() {
    return 'OperatorButton{operator: $operator}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatorButton &&
          runtimeType == other.runtimeType &&
          operator == other.operator;

  @override
  int get hashCode => operator.hashCode;
}

class Operator {
  final String text;
  final MathOperation operation;

  const Operator._(this.text, this.operation);

  static Operator plus = Operator._(
    "+",
    (firstOperand, secondOperand) => firstOperand + secondOperand,
  );
  static Operator minus = Operator._(
    "-",
    (firstOperand, secondOperand) => firstOperand - secondOperand,
  );
  static Operator multiply = Operator._(
    "x",
    (firstOperand, secondOperand) => firstOperand * secondOperand,
  );
  static Operator divide = Operator._(
    "/",
    (firstOperand, secondOperand) => firstOperand / secondOperand,
  );

  @override
  String toString() {
    return 'Operator{text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Operator &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

typedef MathOperation = double Function(
  double firstOperand,
  double secondOperand,
);

class ActionButton extends CalcButton {
  final ActionType actionType;

  const ActionButton(this.actionType);

  @override
  String get text => actionType.text;

  @override
  String toString() {
    return 'ActionButton{actionType: $actionType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionButton &&
          runtimeType == other.runtimeType &&
          actionType == other.actionType;

  @override
  int get hashCode => actionType.hashCode;
}

class ActionType {
  final String text;

  const ActionType._(this.text);

  static const ActionType clear = ActionType._("C");
  static const ActionType percent = ActionType._("%");
  static const ActionType erase = ActionType._("⌫");
  static const ActionType dot = ActionType._(".");

  @override
  String toString() {
    return 'ActionType{text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionType &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

class EqualsButton extends CalcButton {
  const EqualsButton();

  @override
  String get text => "=";

  @override
  String toString() {
    return 'EqualsButton{}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EqualsButton && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
