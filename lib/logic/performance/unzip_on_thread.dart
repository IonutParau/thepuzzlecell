import "dart:io" show File, Directory;
import "package:archive/archive.dart" show ZipDecoder, ArchiveFile;
import 'package:flutter/foundation.dart' show compute;
import "package:path/path.dart" as path show join, joinAll, split;

// Code for unzipping on another thread (VERY useful for performance)
// Most of this code was hippity-hoppity'd from https://stackoverflow.com/questions/52520744/how-can-i-extract-a-zip-file-archive-in-dart-asynchronously

class ZipInfo {
  Directory unzipIn;
  File zip;

  ZipInfo(this.unzipIn, this.zip);
}

// Tells the file to do the decompression calculation using the content getter. This *should* be ran on other threads cuz it can be slow
List<int> decompressArchiveFile(ArchiveFile file) {
  return file.content;
}

// Run this on another thread using unzipOnThread(), it'll be faster and make the experience feel more smooth
// It also does multithreading for the file decompression to keep the thread as fast as it can be
Future<bool> unzip(ZipInfo info) async {
  try {
    final dir = info.unzipIn;
    final zip = info.zip;

    var foldername = path.split(zip.path).last;

    foldername = foldername.substring(0, foldername.length - 4);

    final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());

    for (var file in archive) {
      final filename = path.join(
        dir.path,
        foldername,
        // Thanks Windows, very cool
        path.joinAll(
          file.name.split("/"),
        ),
      );
      if (file.isFile) {
        final decompressed = await compute(decompressArchiveFile, file);
        var outFile = File(filename);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(decompressed);
      } else {
        await Directory(filename).create(recursive: true);
      }
      print(filename);
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future unzipOnThread(Directory unzipIn, File zip) {
  return compute(unzip, ZipInfo(unzipIn, zip));
}
