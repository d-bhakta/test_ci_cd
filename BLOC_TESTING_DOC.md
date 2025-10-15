# Bloc Test documentation

example:

```dart
blocTest<CalculatorBloc, CalculatorState>
('First number changed
'
,build: () => CalculatorBloc(),
act: (bloc) => bloc.add(Number1Changed("5")),
expect: () => [const CalculatorState(number1: "5")
]
,
);
```

bloc test parameters:

1. build
   Builds your BLoC. Creates a fresh instance of your bloc
   ```dart
   build: () => CalculatorBloc(),
   ```

2. act
   Dispatches one or more events to it. Simulates what your app (UI) would do — dispatch events or
   call methods.
   ```dart
    act: (bloc) => bloc.add(Number1Changed("5")),
   ```

3. expect
   Collects emitted states
   ```dart
    expect: () => [const CalculatorState(number1: "5")],
   ```

4. verify
   Optionally validates side effects. Runs extra assertions after the bloc finishes emitting states.
   If your BLoC calls other services (analytics, local storage), verify() is your friend.
   ```dart
   verify(() => analytics.logEvent('calc_add', {'value': 5})).called(1);
   ```

5. seed
   Defines the initial state before the bloc runs any events

6. expect
   Defines what sequence of states you expect the bloc to emit after the act runs.

7. wait
   Defines a duration to wait after the act before verifying the emitted states.

8. skip
   Defines the number of states to skip from the start of the emitted states before comparing with
   the expected states.

9. errors
   Defines the expected errors that should be thrown by the bloc during the act.

## How It Works Internally

Here’s what happens under the hood:

1. blocTest runs build() → gets new bloc.
2. Subscribes to bloc.stream (listens for all emitted states).
3. Applies seed() if provided.
4. Executes act() — your simulated user interactions.
5. Collects all emitted states.
6. Compares them against your expect() list.
7. Runs verify() at the end.
8. Tears down bloc and asserts all expectations.
9. If anything doesn’t match → test fails, showing the exact emitted sequence vs expected sequence.