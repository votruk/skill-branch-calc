import 'package:calc_skill_branch/view/calc/calc_bloc.dart';
import 'package:calc_skill_branch/view/calc/calc_button.dart';
import 'package:calc_skill_branch/resource/calc_colors.dart';
import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:calc_skill_branch/domain/interactor/calculations_interactor.dart';
import 'package:calc_skill_branch/domain/repository/calculations_repository.dart';
import 'package:calc_skill_branch/data/data_provider/hive_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calc_skill_branch/extension/extensions.dart';

class CalculationsPage extends StatefulWidget {
  @override
  _CalculationsPageState createState() => _CalculationsPageState();
}

class _CalculationsPageState extends State<CalculationsPage> {
  late CalcBloc _calcBloc;

  @override
  void initState() {
    //TODO should be replaced with di
    final HiveDataProvider hiveDataProvider = HiveDataProvider();
    final CalculationsRepository calculationsRepository =
        CalculationsRepository(hiveDataProvider.calculationsBoxProvider);
    final CalculationsInteractor calculationsInteractor =
        CalculationsInteractor(calculationsRepository);
    _calcBloc = CalcBloc(calculationsInteractor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _calcBloc,
      child: Scaffold(
        backgroundColor: CalcColors.whiteBackground,
        body: _CalcPageBody(),
      ),
    );
  }

  @override
  void dispose() {
    _calcBloc.dispose();
    super.dispose();
  }
}

class _CalcPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).viewPadding.top,
          color: CalcColors.whiteBackground,
        ),
        Expanded(child: _TopWidget()),
        Expanded(child: _BottomWidget()),
        const SizedBox(height: 1),
        Container(
          height: MediaQuery.of(context).viewPadding.bottom,
          color: CalcColors.greyBackground,
        ),
      ],
    );
  }
}

class _TopWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _CalculationsWidget()),
        _HalfScreenDivider(),
        _ExpressionWidget(),
        _ResultWidget(),
      ],
    );
  }
}

class _CalculationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CalcBloc bloc = context.read<CalcBloc>();
    return StreamBuilder<List<Calculation>>(
        initialData: [],
        stream: bloc.observeCalculations(),
        builder: (context, snapshot) {
          final List<Calculation> calculations = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: calculations.length,
            reverse: true,
            itemBuilder: (context, index) {
              final Calculation item =
                  calculations[calculations.length - index - 1];
              return GestureDetector(
                onTap: () => bloc.onCalculationClicked(item),
                child: Container(
                  color: CalcColors.whiteBackground,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${item.expression} =",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: CalcColors.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${item.result.prettifyWithPrecision()}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: CalcColors.secondaryTextColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}

class _HalfScreenDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SizedBox()),
        Expanded(child: Container(height: 2, color: CalcColors.greyBackground)),
      ],
    );
  }
}

class _ExpressionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CalcBloc bloc = context.read<CalcBloc>();
    return StreamBuilder<String>(
      initialData: "",
      stream: bloc.observeExpression(),
      builder: (context, snapshot) {
        final String expression = snapshot.data!;
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Text(
            expression,
            style: TextStyle(fontSize: 32, color: CalcColors.primaryTextColor),
          ),
        );
      },
    );
  }
}

class _ResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CalcBloc bloc = context.read<CalcBloc>();
    return StreamBuilder<String>(
      initialData: "",
      stream: bloc.observeResult(),
      builder: (context, snapshot) {
        final String result = snapshot.data!;
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Text(
            result,
            style: TextStyle(fontSize: 40, color: CalcColors.primaryTextColor),
          ),
        );
      },
    );
  }
}

class _BottomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: ActionButton(ActionType.percent),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: ActionButton(ActionType.clear),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: ActionButton(ActionType.erase),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: OperatorButton(Operator.divide),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.seven),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.eight),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.nine),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: OperatorButton(Operator.multiply),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.four),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.five),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.six),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: OperatorButton(Operator.minus),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.one),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.two),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.three),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: OperatorButton(Operator.plus),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _CalcButtonWidget()),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: NumberButton(Number.zero),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: ActionButton(ActionType.dot),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _CalcButtonWidget(
                  calcButton: EqualsButton(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalcButtonWidget extends StatelessWidget {
  final CalcButton calcButton;

  const _CalcButtonWidget({Key? key, this.calcButton = const EmptyButton()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CalcBloc bloc = context.read<CalcBloc>();
    return GestureDetector(
      onTap: () => bloc.onCalcButtonClicked(calcButton),
      child: Container(
        alignment: Alignment.center,
        color: CalcColors.greyBackground,
        child: Text(
          calcButton.text,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }

  Color _getTextColor() {
    if (calcButton is EqualsButton) {
      return CalcColors.blueText;
    } else if (calcButton is OperatorButton || calcButton is ActionButton) {
      return CalcColors.orangeText;
    } else {
      return CalcColors.blackText;
    }
  }
}
