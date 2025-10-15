part of 'users_bloc.dart';

@immutable
sealed class UsersState {}

final class UsersInitial extends UsersState {}

final class UsersLoading extends UsersState {}

final class UsersLoaded extends UsersState {
  final List<UserModel> users;

  UsersLoaded({required this.users});
}

final class UsersError extends UsersState {
  final String message;

  UsersError({required this.message});
}
