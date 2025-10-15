// lib/calculator/view/calculator_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'calculatorBloc/calculator_bloc.dart';
// Update with your app name

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalculatorBloc(),
      child: const CalculatorView(),
    );
  }
}

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Flutter BLoC Calculator')),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Number Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'First Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      context.read<CalculatorBloc>().add(Number1Changed(value));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Operator Dropdown
                  _OperatorDropdown(),
                  const SizedBox(height: 16),

                  // Second Number Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Second Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      context.read<CalculatorBloc>().add(Number2Changed(value));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Calculate Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalculatorBloc>().add(
                        const CalculatePressed(),
                      );
                    },
                    child: const Text('Calculate'),
                  ),
                  const SizedBox(height: 24),

                  // Result Display
                  if (state.errorMessage != null &&
                      state.errorMessage!.isNotEmpty)
                    Text(
                      'Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                  else if (state.result != null)
                    Text(
                      'Result: ${state.result}',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OperatorDropdown extends StatelessWidget {
  final List<String> operators = const ['+', '-', '*', '/'];

  @override
  Widget build(BuildContext context) {
    final selectedOperator = context.select(
      (CalculatorBloc bloc) => bloc.state.operator,
    );

    return DropdownButtonFormField<String>(
      value: selectedOperator,
      decoration: const InputDecoration(
        labelText: 'Operator',
        border: OutlineInputBorder(),
      ),
      items: operators.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<CalculatorBloc>().add(OperatorChanged(newValue));
        }
      },
    );
  }
}
