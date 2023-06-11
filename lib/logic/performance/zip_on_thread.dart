import "dart:io" show Directory, File;
import "package:archive/archive.dart" show Archive, ArchiveFile, ZipEncoder;
import "package:path/path.dart" as path show relative;

Stream<String> packageDirectory(String whereToSave, Directory dir) async* {
  try {
    final encoder = ZipEncoder();
    final archive = Archive();

    final contents = dir.list(recursive: true);

    await for (var file in contents) {
      if (file is File) {
        final bytes = await file.readAsBytes();
        final archiveFile = ArchiveFile(
          path.relative(file.path, from: dir.path),
          bytes.length,
          bytes,
        );

        yield "Packaged ${archiveFile.name}";

        archive.addFile(archiveFile);

        await Future<void>.delayed(Duration(milliseconds: 50));
      }
    }

    yield "Started encoding...";

    final bytes = encoder.encode(archive);

    if (bytes == null) {
      yield "Encoding Failed!";
      return;
    }

    var byteCount = bytes.length.toDouble();
    var currFormat = 0;
    final byteFormats = <String>["B", "KB", "MB", "GB", "TB", "PB"];

    while (byteCount > 1000) {
      byteCount /= 1000;
      currFormat++;
    }

    yield "Finished encoding! (${byteCount.toStringAsFixed(1)} ${byteFormats[currFormat]})";

    File(whereToSave)
      ..createSync()
      ..writeAsBytesSync(bytes);
  } catch (e) {
    print(e);
  }
}
