import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:FotoApp/main.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePath extends StatefulWidget {
  final String imgPath;
  ImagePath(this.imgPath);

  @override
  _ImagePathState createState() => _ImagePathState();
}

class _ImagePathState extends State<ImagePath> {
  String localPath;

  Future<String> get localpath async {
    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      final localPath =
          (await findLocalPath()) + Platform.pathSeparator + 'Download';
      final savedDir = Directory(localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      return localPath;
    } else
      return null;
  }

  Future<String> findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        actions: [
          IconButton(
              color: Colors.white,
              icon: Icon(Icons.file_download),
              onPressed: () async => DownloadTask(
                  taskId: await FlutterDownloader.enqueue(
                      url: widget.imgPath,
                      savedDir: await localpath,
                      showNotification: true,
                      openFileFromNotification: true)))
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Hero(
                    tag: widget.imgPath, child: Image.network(widget.imgPath)),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: bgColor,
    );
  }
}
