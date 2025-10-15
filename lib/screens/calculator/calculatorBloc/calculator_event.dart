part of 'calculator_bloc.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

/// Event for when the first number input changes.
class Number1Changed extends CalculatorEvent {
  const Number1Changed(this.number1);

  final String number1;

  @override
  List<Object> get props => [number1];
}

/// Event for when the second number input changes.
class Number2Changed extends CalculatorEvent {
  const Number2Changed(this.number2);

  final String number2;

  @override
  List<Object> get props => [number2];
}

/// Event for when the operator is changed.
class OperatorChanged extends CalculatorEvent {
  const OperatorChanged(this.operator);

  final String operator;

  @override
  List<Object> get props => [operator];
}

/// Event for when the calculate button is pressed.
class CalculatePressed extends CalculatorEvent {
  const CalculatePressed();
}
