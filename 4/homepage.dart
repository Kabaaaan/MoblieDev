import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'photo_object.dart';
import 'package:photo_app/screens/photo_datail.dart';
import 'package:photo_app/screens/photo_search.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  List<PhotoInfo> _photos = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  // освобождение ресурсов и предотвращения утечек памяти, вызывается, когда виджет уничтожается
  @override
  void dispose() {
    super.dispose();
  }

  // Вспомогательный метод для получения пути к директории, где хранятся файлы изображений.
  Future<Directory> _getPhotosDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory photosDir = Directory(path.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  // Вспомогательный метод для получения файла, в котором хранятся метаданные (сериализованный JSON) всех фотографий.
  Future<File> _getMetadataFile() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return File(path.join(appDir.path, 'photos_metadata.json'));
  }

  // Загружает сохраненные метаданные фотографий из JSON-файла в память.
  Future<void> _loadPhotos() async {
    try {
      final File metadataFile = await _getMetadataFile();
      if (await metadataFile.exists()) {
        final String content = await metadataFile.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        setState(() {
          _photos = jsonList.map((json) => PhotoInfo.fromMap(json)).toList();
        });
      }
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  // Сохраняет текущий список метаданных фотографий (_photos) в JSON-файл для постоянного хранения.
  Future<void> _savePhotos() async {
    try {
      final File metadataFile = await _getMetadataFile();
      final List<Map<String, dynamic>> jsonList = _photos
          .map((photo) => photo.toMap())
          .toList();
      await metadataFile.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving photos: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        await _savePhotoWithInfo(pickedFile);
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        await _savePhotoWithInfo(pickedFile);
      }
    } catch (e) {
      _showError('Error picking photo: $e');
    }
  }

  // Обрабатывает выбранный или снятый файл изображения: сохраняет его в постоянное хранилище и запрашивает у пользователя метаданные.
  Future<void> _savePhotoWithInfo(XFile pickedFile) async {
    final Directory photosDir = await _getPhotosDirectory();
    final String fileName =
        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File newFile = File(path.join(photosDir.path, fileName));

    final File tempFile = File(pickedFile.path);
    await tempFile.copy(newFile.path);

    final PhotoInfo? photoInfo = await _showPhotoInfoDialog(fileName);
    if (photoInfo != null) {
      setState(() {
        _photos.add(photoInfo);
      });
      await _savePhotos();
    } else {
      await newFile.delete();
    }
  }

  // Отображает модальное диалоговое окно (AlertDialog) для ввода информации о фотографии (название, описание, теги).
  Future<PhotoInfo?> _showPhotoInfoDialog(String fileName) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();

    return showDialog<PhotoInfo>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Данные фото'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Теги',
                    hintText: 'через запятую',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final List<String> tags = tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                final PhotoInfo photoInfo = PhotoInfo(
                  fileName: fileName,
                  name: nameController.text,
                  description: descController.text,
                  tags: tags,
                  createdDate: DateTime.now(),
                );
                Navigator.of(context).pop(photoInfo);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhoto(int index) async {
    final PhotoInfo photoInfo = _photos[index];
    final Directory photosDir = await _getPhotosDirectory();
    final File photoFile = File(path.join(photosDir.path, photoInfo.fileName));

    if (await photoFile.exists()) {
      await photoFile.delete();
    }

    setState(() {
      _photos.removeAt(index);
    });
    await _savePhotos();
  }

  List<PhotoInfo> get _filteredPhotos {
    if (_searchQuery.isEmpty) {
      return _photos;
    }
    return _photos
        .where(
          (photo) =>
              photo.name.toLowerCase().contains(_searchQuery) ||
              photo.description.toLowerCase().contains(_searchQuery) ||
              photo.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)),
        )
        .toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PhotoSearchDelegate(_photos),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Сделать фото'),
                  onTap: _takePhoto,
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Выбрать из галереи'),
                  onTap: _pickPhotoFromGallery,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredPhotos.isEmpty
                ? const Center(child: Text('Фото не найдено'))
                : ListView.builder(
                    itemCount: _filteredPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = _filteredPhotos[index];
                      return _buildPhotoListItem(photo, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Строит один элемент списка для конкретной фотографии.
  Widget _buildPhotoListItem(PhotoInfo photo, int index) {
    return FutureBuilder<File>(
      future: _getPhotoFile(photo.fileName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ListTile(
            leading: Image.file(
              snapshot.data!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(photo.name.isNotEmpty ? photo.name : 'Без имени'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.description.isNotEmpty) Text(photo.description),
                if (photo.tags.isNotEmpty)
                  Text(
                    'Теги: ${photo.tags.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                Text(
                  'Создано: ${photo.createdDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePhoto(_photos.indexOf(photo)),
            ),
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
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text('Ошибка загрузки: ${photo.name}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePhoto(_photos.indexOf(photo)),
            ),
          );
        }
        return const ListTile(
          title: Text('Загрузка...'),
          leading: CircularProgressIndicator(),
        );
      },
    );
  }

  // Вспомогательный метод для получения объекта File, указывающего на изображение в директории приложения.
  Future<File> _getPhotoFile(String fileName) async {
    final Directory photosDir = await _getPhotosDirectory();
    return File(path.join(photosDir.path, fileName));
  }
}
