import 'dart:io';
import 'package:flutter/material.dart';
import '../photo_object.dart';

class PhotoDetailScreen extends StatelessWidget {
  final File photoFile;
  final PhotoInfo photoInfo;

  const PhotoDetailScreen({
    super.key,
    required this.photoFile,
    required this.photoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          photoInfo.name.isNotEmpty ? photoInfo.name : 'Детали',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(photoFile),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoInfo.name.isNotEmpty) Text(photoInfo.name),
                  if (photoInfo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(photoInfo.description),
                    ),
                  if (photoInfo.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 4,
                        children: photoInfo.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue[100],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Создано: ${photoInfo.createdDate.toString()}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
