// lib/calculator/bloc/calculator_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc() : super(const CalculatorState()) {
    // Register event handlers
    on<Number1Changed>(_onNumber1Changed);
    on<Number2Changed>(_onNumber2Changed);
    on<OperatorChanged>(_onOperatorChanged);
    on<CalculatePressed>(_onCalculatePressed);
  }

  void _onNumber1Changed(Number1Changed event, Emitter<CalculatorState> emit) {
    emit(state.copyWith(number1: event.number1, clearResult: true));
  }

  void _onNumber2Changed(Number2Changed event, Emitter<CalculatorState> emit) {
    emit(state.copyWith(number2: event.number2, clearResult: true));
  }

  void _onOperatorChanged(
    OperatorChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(state.copyWith(operator: event.operator, clearResult: true));
  }

  void _onCalculatePressed(
    CalculatePressed event,
    Emitter<CalculatorState> emit,
  ) {
    final double? num1 = double.tryParse(state.number1);
    final double? num2 = double.tryParse(state.number2);

    if (num1 == null || num2 == null) {
      emit(state.copyWith(errorMessage: 'Please enter valid numbers.'));
      return;
    }

    double result = 0;
    switch (state.operator) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '*':
        result = num1 * num2;
        break;
      case '/':
        if (num2 == 0) {
          emit(state.copyWith(errorMessage: 'Cannot divide by zero.'));
          return;
        }
        result = num1 / num2;
        break;
    }
    emit(state.copyWith(result: result));
  }
}
