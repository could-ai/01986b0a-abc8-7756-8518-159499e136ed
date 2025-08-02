import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<PasswordEntry> passwordBox;

  @override
  void initState() {
    super.initState();
    passwordBox = Hive.box<PasswordEntry>('passwords');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
      ),
      body: ValueListenableBuilder(
        valueListenable: passwordBox.listenable(),
        builder: (context, Box<PasswordEntry> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No passwords saved. Click + to add.'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index)!;
              return ListTile(
                title: Text(entry.title),
                subtitle: Text(entry.username),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: entry.password),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password copied to clipboard')),
                    );
                  },
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditPage(entry: entry, index: index),
                    ),
                  );
                },
                onLongPress: () {
                  box.deleteAt(index);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditPage(),
            ),
          );
        },
      ),
    );
  }
}
