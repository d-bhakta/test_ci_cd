// lib/calculator/bloc/calculator_state.dart

part of 'calculator_bloc.dart';

class CalculatorState extends Equatable {
  const CalculatorState({
    this.number1 = '',
    this.number2 = '',
    this.operator = '+',
    this.result,
    this.errorMessage,
  });

  final String number1;
  final String number2;
  final String operator;
  final double? result;
  final String? errorMessage;

  CalculatorState copyWith({
    String? number1,
    String? number2,
    String? operator,
    double? result,
    String? errorMessage,
    bool clearResult = false, // Helper to clear the result explicitly
  }) {
    return CalculatorState(
      number1: number1 ?? this.number1,
      number2: number2 ?? this.number2,
      operator: operator ?? this.operator,
      result: clearResult ? null : result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [number1, number2, operator, result, errorMessage];
}
