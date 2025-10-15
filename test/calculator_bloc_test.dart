import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_ci_cd/screens/calculator/calculatorBloc/calculator_bloc.dart';

void main() {
  group('CalculatorBloc', () {
    blocTest<CalculatorBloc, CalculatorState>(
      'First number changed',
      build: () => CalculatorBloc(),
      act: (bloc) => bloc.add(Number1Changed("5")),
      expect: () => [const CalculatorState(number1: "5")],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      "Second number changed",
      build: () => CalculatorBloc(),
      act: (calBloc) => calBloc.add(Number2Changed("10.5")),
      expect: () => [const CalculatorState(number2: "10.5")],
    );

    blocTest(
      "Operator changed",
      build: () => CalculatorBloc(),
      act: (bloc) => bloc.add(OperatorChanged("/")),
      expect: () => [const CalculatorState(operator: "/")],
    );

    blocTest(
      "Calculate addition",
      build: () => CalculatorBloc(),
      act: (bloc) {
        bloc.add(Number1Changed("6"));
        bloc.add(Number2Changed("4"));
        bloc.add(CalculatePressed());
      },
      expect: () => [
        const CalculatorState(number1: "6"),
        const CalculatorState(number1: "6", number2: "4"),
        const CalculatorState(
          number1: "6",
          number2: "4",
          operator: "+",
          result: 10.0,
        ),
      ],
    );

    /*
    blocTest<CalculatorBloc, CalculatorState>(
      'subtracts numbers correctly',
      build: () => CalculatorBloc(),
      seed: () => const CalculatorState(value: 10),
      act: (bloc) => bloc.add(const SubtractEvent(4)),
      expect: () => [const CalculatorState(value: 6)],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'multiplies numbers correctly',
      build: () => CalculatorBloc(),
      seed: () => const CalculatorState(value: 3),
      act: (bloc) => bloc.add(const MultiplyEvent(5)),
      expect: () => [const CalculatorState(value: 15)],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'handles division correctly',
      build: () => CalculatorBloc(),
      seed: () => const CalculatorState(value: 20),
      act: (bloc) => bloc.add(const DivideEvent(5)),
      expect: () => [const CalculatorState(value: 4)],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'handles division by zero',
      build: () => CalculatorBloc(),
      seed: () => const CalculatorState(value: 10),
      act: (bloc) => bloc.add(const DivideEvent(0)),
      expect: () => [
        const CalculatorState(value: 10, error: 'Division by zero'),
      ],
    );
    */
  });
}
