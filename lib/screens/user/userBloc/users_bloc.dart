import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_ci_cd/screens/user/user_model.dart';
import 'package:test_ci_cd/service/users_service.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  List<UserModel> userDate = [];

  UsersBloc() : super(UsersInitial()) {
    on<FetchUsers>(_fetchUsers);
  }

  FutureOr<void> _fetchUsers(FetchUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final Response response = await UsersService.fetchUsers();
      if (response.statusCode == 200) {
        final users = response.data;
        userDate = users
            .map<UserModel>((json) => UserModel.fromJson(json))
            .toList();
        emit(UsersLoaded(users: userDate));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      emit(UsersError(message: 'Failed to load users'));
    }
  }
}
