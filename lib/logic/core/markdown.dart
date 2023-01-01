part of logic;

class MarkdownData {
  String title;
  String content;

  MarkdownData(this.title, this.content);
}

class MarkdownManager {
  final docs = <MarkdownData>[];

  void addDocument(String title, String content) {
    docs.add(MarkdownData(title, content));
  }

  void addFromFile(String title, String filePath) {
    final f = File(path.joinAll(filePath.split('/')));

    if (!f.existsSync()) return;

    addDocument(title, f.readAsStringSync());
  }
}

final markdownManager = MarkdownManager();
