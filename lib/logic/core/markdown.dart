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

  void addFromAssets(String title, String file) {
    final fp = path.join(assetsPath, 'markdown', file);
    addFromFile(title, fp);
  }

  void init() {
    addFromAssets('Installing a Texture pack', 'install_texture_packs.md');
  }
}

final markdownManager = MarkdownManager();
