import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'status_provider.dart';
import 'dart:io';

class ChatsTab extends StatelessWidget {
  final String myName;
  const ChatsTab({super.key, required this.myName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Add Status from Chats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            children: List.generate(5, (i) => ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFiles = await picker.pickMultiImage();
                if (pickedFiles.isNotEmpty) {
                  final images = pickedFiles.map((f) => File(f.path)).toList();
                  final status = StatusItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
                    userName: 'User Status ${i+1}',
                    images: images,
                    timestamp: DateTime.now(),
                  );
                  Provider.of<StatusProvider>(context, listen: false).addStatus(status);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status Added!')));
                }
              },
              child: Text('Add Status ${i+1}'),
            )),
          ),
        ],
      ),
    );
  }
}
