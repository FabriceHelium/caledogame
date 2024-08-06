import 'package:flutter/material.dart';

class Account {
  final String username;
  final String role;

  Account({required this.username, required this.role});
}

class AccountListPage extends StatelessWidget {
  final List<Account> accounts = [
    Account(username: 'admin1', role: 'Admin'),
    Account(username: 'tester1', role: 'Tester'),
    Account(username: 'user1', role: 'User'),
    Account(username: 'client1', role: 'Client'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comptes'),
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return ListTile(
            title: Text(account.username),
            subtitle: Text('Role: ${account.role}'),
          );
        },
      ),
    );
  }
}
