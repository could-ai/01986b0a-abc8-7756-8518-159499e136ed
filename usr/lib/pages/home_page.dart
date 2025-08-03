import 'package:couldai_user_app/models/password_entry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<PasswordEntry>> _passwordsFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _passwordsFuture = _fetchPasswords();
  }

  Future<List<PasswordEntry>> _fetchPasswords() async {
    try {
      final response = await _supabase
          .from('password_entries')
          .select()
          .order('created_at', ascending: false);
      final data = response as List;
      return data.map((e) => PasswordEntry.fromMap(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching passwords: $e')),
      );
      return [];
    }
  }

  Future<void> _deleteEntry(int id) async {
    try {
      await _supabase.from('password_entries').delete().match({'id': id});
      setState(() {
        // Re-fetch passwords after deletion
        // A better approach for larger apps would be to remove the item from the local list
        _passwordsFuture = _fetchPasswords();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PasswordEntry>>(
        future: _passwordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final passwords = snapshot.data;
          if (passwords == null || passwords.isEmpty) {
            return const Center(
              child: Text('No passwords saved. Click + to add.'),
            );
          }
          return ListView.builder(
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final entry = passwords[index];
              return Card(
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Clipboard logic here
                    },
                  ),
                  onTap: () async {
                    // Navigate to edit page and refresh list on return
                    final result = await context.push<bool>('/edit', extra: entry);
                    if (result == true) {
                      setState(() {
                        _passwordsFuture = _fetchPasswords();
                      });
                    }
                  },
                  onLongPress: () {
                    _deleteEntry(entry.id!);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigate to add page and refresh list on return
          final result = await context.push<bool>('/add');
          if (result == true) {
            setState(() {
              _passwordsFuture = _fetchPasswords();
            });
          }
        },
      ),
    );
  }
}
