import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_ci_cd/user/userBloc/users_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding; // handle status/nav bar
    return BlocProvider(
      create: (context) => UsersBloc()..add(FetchUsers()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Items List')),
        body: Padding(
          padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
          child: BlocConsumer<UsersBloc, UsersState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              if (state is UsersLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is UsersLoaded) {
                final items = state.users;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.body,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return Center(child: Text("NA"));
            },
          ),
        ),
      ),
    );
  }
}
