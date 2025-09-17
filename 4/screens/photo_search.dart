import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../photo_object.dart';
import 'photo_datail.dart';


// SearchDelegate - Специальный класс для реализации поиска
class PhotoSearchDelegate extends SearchDelegate {
  final List<PhotoInfo> photos;

  PhotoSearchDelegate(this.photos);

  // Очистить фильтр
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // Вызывается при подтверждении поиска
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  // Вызывается при каждом изменении текста в поисковой строке
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<PhotoInfo> results = query.isEmpty
        ? photos
        : photos
              .where(
                (photo) =>
                    photo.name.toLowerCase().contains(query.toLowerCase()) ||
                    photo.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    photo.tags.any(
                      (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                    ),
              )
              .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final photo = results[index];
        return FutureBuilder<File>(
          future: _getPhotoFile(photo.fileName),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                leading: Image.file(
                  snapshot.data!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(photo.name),
                subtitle: Text(photo.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoDetailScreen(
                        photoFile: snapshot.data!,
                        photoInfo: photo,
                      ),
                    ),
                  );
                },
              );
            }
            return const ListTile(title: Text('Загрузка...'));
          },
        );
      },
    );
  }

  // Получение данных о файлике
  Future<File> _getPhotoFile(String fileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory photosDir = Directory(path.join(appDir.path, 'photos'));
    return File(path.join(photosDir.path, fileName));
  }
}
