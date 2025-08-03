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
  late Future<List<PasswordEntry>> _passwordsFuture;
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
      
      // The response is already a List<Map<String, dynamic>>
      final data = response as List;
      return data.map((map) => PasswordEntry.fromMap(map)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching passwords: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _deleteEntry(int id) async {
    try {
      await _supabase.from('password_entries').delete().match({'id': id});
      setState(() {
        _passwordsFuture = _fetchPasswords();
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
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
              if (mounted) {
                context.go('/login');
              }
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
                    final result = await GoRouter.of(context).push<bool>('/edit', extra: entry);
                    if (result == true && mounted) {
                      setState(() {
                        _passwordsFuture = _fetchPasswords();
                      });
                    }
                  },
                  onLongPress: () {
                    if (entry.id != null) {
                      _deleteEntry(entry.id!);
                    }
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
          final result = await GoRouter.of(context).push<bool>('/add');
          if (result == true && mounted) {
            setState(() {
              _passwordsFuture = _fetchPasswords();
            });
          }
        },
      ),
    );
  }
}
