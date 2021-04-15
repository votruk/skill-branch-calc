import 'dart:async';

import 'package:calc_skill_branch/view/calc/calc_button.dart';
import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:calc_skill_branch/domain/interactor/calculations_interactor.dart';
import 'package:calc_skill_branch/view/calc/operand_and_operator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:calc_skill_branch/extension/extensions.dart';

class CalcBloc {
  final CalculationsInteractor _calculationsInteractor;

  final BehaviorSubject<String> _expressionSubject = BehaviorSubject.seeded("");
  final BehaviorSubject<String> _resultSubject = BehaviorSubject.seeded("");

  final BehaviorSubject<OperandAndOperator?> _stashedOperandAndOperatorSubject =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<String> _enteredTextSubject =
      BehaviorSubject.seeded("");
  final BehaviorSubject<bool> _shouldClearInputOnNewNumbersSubject =
      BehaviorSubject.seeded(false);

  StreamSubscription<dynamic>? _expressionSubscrpition;
  StreamSubscription<dynamic>? _resultSubscrpition;

  CalcBloc(this._calculationsInteractor) {
    _subscribeToUpdatingExpression();
    _subscribeToUpdatingResult();
  }

  void _subscribeToUpdatingExpression() {
    _expressionSubscrpition =
        Rx.combineLatest2<String, OperandAndOperator?, String>(
      _enteredTextSubject,
      _stashedOperandAndOperatorSubject,
      (enteredText, stashedOperandAndOperator) {
        if (stashedOperandAndOperator != null) {
          return "${stashedOperandAndOperator.operand.prettifyWithPrecision()} ${stashedOperandAndOperator.operator.text} $enteredText"
              .trim();
        } else {
          return enteredText;
        }
      },
    ).listen(
      (expression) {
        _expressionSubject.add(expression);
      },
      onError: (error, stackTrace) =>
          print("Got error in expression subscription: $error, $stackTrace"),
    );
  }

  void _subscribeToUpdatingResult() {
    _resultSubscrpition =
        Rx.combineLatest2<String, OperandAndOperator?, String>(
      _enteredTextSubject,
      _stashedOperandAndOperatorSubject,
      (enteredText, stashedOperandAndOperator) {
        final double? secondOperand =
            _convertEnteredTextIntoNumber(enteredText);
        if (stashedOperandAndOperator != null && secondOperand != null) {
          final double result = stashedOperandAndOperator.operator
              .operation(stashedOperandAndOperator.operand, secondOperand);
          return result.prettifyWithPrecision();
        } else {
          return "";
        }
      },
    ).listen(
      (result) {
        _resultSubject.add(result);
      },
      onError: (error, stackTrace) =>
          print("Got error in result subscription: $error, $stackTrace"),
    );
  }

  double? _convertEnteredTextIntoNumber(final String enteredText) {
    if (enteredText == "") {
      return null;
    } else if (enteredText.endsWith(".")) {
      final String correctedNumber =
          enteredText.substring(0, enteredText.length - 1);
      return double.parse(correctedNumber);
    } else if (enteredText == "-") {
      return -0;
    } else {
      return double.parse(enteredText);
    }
  }

  void onCalcButtonClicked(final CalcButton calcButton) {
    print("Bloc. On calc button clicked: $calcButton");
    if (calcButton is NumberButton) {
      _processNumberButtonClicked(calcButton);
    } else if (calcButton is ActionButton) {
      _processActionButtonClicked(calcButton);
    } else if (calcButton is OperatorButton) {
      _processOperatorButtonClicked(calcButton);
    } else if (calcButton is EqualsButton) {
      _processEqualsButtonClicked(calcButton);
    } else {
      print("Unknown calc button: $calcButton");
    }
  }

  void _processNumberButtonClicked(final NumberButton calcButton) {
    final bool shouldClearInputOnNewNumbers =
        _shouldClearInputOnNewNumbersSubject.value!;
    final String enteredText = _enteredTextSubject.value!;
    final double? secondOperand = _convertEnteredTextIntoNumber(enteredText);
    final int newDigit = calcButton.number.value;
    if (shouldClearInputOnNewNumbers) {
      _enteredTextSubject.add(newDigit.toString());
    } else if (secondOperand == null || enteredText == "0") {
      _enteredTextSubject.add(newDigit.toString());
    } else if (enteredText == "-0") {
      _enteredTextSubject.add("-${newDigit.toString()}");
    } else {
      _enteredTextSubject.add(enteredText + newDigit.toString());
    }
    _shouldClearInputOnNewNumbersSubject.add(false);
  }

  void _processActionButtonClicked(final ActionButton actionButton) {
    _shouldClearInputOnNewNumbersSubject.add(false);
    if (actionButton.actionType == ActionType.dot) {
      final String currentNumber = _enteredTextSubject.value!;
      final bool dotEntered = currentNumber.contains(".");
      if (dotEntered) {
        //do nothing
      } else {
        if (currentNumber == "") {
          _enteredTextSubject.add("0.");
        } else if (currentNumber == "-") {
          _enteredTextSubject.add("-0.");
        } else {
          _enteredTextSubject.add(currentNumber + ".");
        }
      }
    } else if (actionButton.actionType == ActionType.percent) {
      final double? secondOperand =
          _convertEnteredTextIntoNumber(_enteredTextSubject.value!);
      if (secondOperand == null) {
        //do nothing
      } else {
        _enteredTextSubject.add((secondOperand / 100).toString());
      }
    } else if (actionButton.actionType == ActionType.erase) {
      final String currentNumber = _enteredTextSubject.value!;
      if (currentNumber.length == 0) {
        //do nothing
      } else {
        _enteredTextSubject
            .add(currentNumber.substring(0, currentNumber.length - 1));
      }
    } else if (actionButton.actionType == ActionType.clear) {
      _stashedOperandAndOperatorSubject.add(null);
      _enteredTextSubject.add("");
    } else {
      print("Unknown actionType: ${actionButton.actionType}");
    }
  }

  void _processOperatorButtonClicked(final OperatorButton operatorButton) {
    _shouldClearInputOnNewNumbersSubject.add(false);
    final double? secondOperand =
        _convertEnteredTextIntoNumber(_enteredTextSubject.value!);
    final OperandAndOperator? stashedOperandAndOperator =
        _stashedOperandAndOperatorSubject.value;
    final Operator newOperator = operatorButton.operator;
    if (stashedOperandAndOperator == null && secondOperand == null) {
      if (newOperator == Operator.minus) {
        _enteredTextSubject.add("-");
      }
    } else if (stashedOperandAndOperator == null && secondOperand != null) {
      _stashedOperandAndOperatorSubject
          .add(OperandAndOperator(secondOperand, newOperator));
      _enteredTextSubject.add("");
    } else if (stashedOperandAndOperator != null && secondOperand == null) {
      _stashedOperandAndOperatorSubject.add(
          OperandAndOperator(stashedOperandAndOperator.operand, newOperator));
    } else if (stashedOperandAndOperator != null && secondOperand != null) {
      final double result = stashedOperandAndOperator.operator
          .operation(stashedOperandAndOperator.operand, secondOperand);
      _addCalculation(stashedOperandAndOperator, secondOperand, result);
      _stashedOperandAndOperatorSubject
          .add(OperandAndOperator(result, newOperator));
      _enteredTextSubject.add("");
    }
  }

  void _processEqualsButtonClicked(final EqualsButton equalsButton) {
    final double? secondOperand =
        _convertEnteredTextIntoNumber(_enteredTextSubject.value!);
    final OperandAndOperator? stashedOperandAndOperator =
        _stashedOperandAndOperatorSubject.value;
    if (stashedOperandAndOperator == null || secondOperand == null) {
      //do nothing
    } else {
      final double result = stashedOperandAndOperator.operator
          .operation(stashedOperandAndOperator.operand, secondOperand);
      _addCalculation(stashedOperandAndOperator, secondOperand, result);
      _stashedOperandAndOperatorSubject.add(null);
      _enteredTextSubject.add(result.prettifyWithPrecision());
      _shouldClearInputOnNewNumbersSubject.add(true);
    }
  }

  void _addCalculation(final OperandAndOperator stashedOperandAndOperator,
      final double secondOperand, final double result) {
    _calculationsInteractor.addCalculationWithLimit(
      Calculation(
          expression:
              "${stashedOperandAndOperator.operand.prettifyWithPrecision()} ${stashedOperandAndOperator.operator.text} ${secondOperand.prettifyWithPrecision()}",
          result: result),
    );
  }

  void onCalculationClicked(final Calculation calculation) {
    if (!calculation.result.isFinite) {
      return;
    }
    final OperandAndOperator? stashedOperandAndOperator =
        _stashedOperandAndOperatorSubject.value;
    final String enteredText = _enteredTextSubject.value!;
    final double? secondOperand = _convertEnteredTextIntoNumber(enteredText);
    if (secondOperand == null) {
      _enteredTextSubject.add(calculation.result.prettifyWithPrecision());
      return;
    }
    if (calculation.result.isNegative) {
      if (stashedOperandAndOperator != null) {
        final double result = stashedOperandAndOperator.operator
            .operation(stashedOperandAndOperator.operand, secondOperand);
        _addCalculation(stashedOperandAndOperator, secondOperand, result);
        _stashedOperandAndOperatorSubject
            .add(OperandAndOperator(result, Operator.minus));
      } else {
        _stashedOperandAndOperatorSubject
            .add(OperandAndOperator(secondOperand, Operator.minus));
      }
      _enteredTextSubject
          .add((calculation.result * (-1)).prettifyWithPrecision());
    } else {
      final String calculationResultText =
          calculation.result.prettifyWithPrecision();
      if (enteredText.contains(".") && calculationResultText.contains(".")) {
        if (stashedOperandAndOperator != null) {
          final double result = stashedOperandAndOperator.operator
              .operation(stashedOperandAndOperator.operand, secondOperand);
          _addCalculation(stashedOperandAndOperator, secondOperand, result);
          _stashedOperandAndOperatorSubject.add(null);
        }
        _enteredTextSubject.add(calculation.result.prettifyWithPrecision());
      } else {
        _enteredTextSubject.add("calculationResultText");
      }
    }
  }

  Stream<String> observeExpression() => _expressionSubject;

  Stream<String> observeResult() => _resultSubject;

  Stream<List<Calculation>> observeCalculations() =>
      _calculationsInteractor.observeCalculations();

  void dispose() {
    _expressionSubject.close();
    _resultSubject.close();

    _stashedOperandAndOperatorSubject.close();
    _enteredTextSubject.close();
    _shouldClearInputOnNewNumbersSubject.close();

    _expressionSubscrpition?.cancel();
    _resultSubscrpition?.cancel();
  }
}
