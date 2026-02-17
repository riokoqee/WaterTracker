import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/token_storage.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _api = ApiClient();
  final _tokens = TokenStorage();
  List users = [];
  bool loading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    // получаем текущего пользователя (его id и роль)
    final me = await _api.get('/api/profile');
    if (me.statusCode == 200) {
      currentUserId = jsonDecode(me.body)['id'];
    }

    final r = await _api.get('/api/admin/users');

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);
      if (decoded is List) {
        setState(() {
          users = decoded;
          loading = false;
        });
      } else {
        setState(() {
          users = [];
          loading = false;
        });
      }
    } else {
      setState(() {
        users = [];
        loading = false;
      });
      print("⚠️ Server returned: ${r.statusCode}, body: ${r.body}");
    }

  }

  Future<void> confirmDelete(int id) async {
    if (id == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нельзя удалить самого себя")),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _api.delete('/api/admin/users/$id');
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${u['firstName']} ${u['lastName']}'),
            subtitle: Text(u['email']),
            trailing: u['id'] == currentUserId
                ? const Icon(Icons.lock, color: Colors.grey) // показываем, что нельзя удалить
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(u['id']),
                  ),
          );
        },
      ),
    );
  }
}
