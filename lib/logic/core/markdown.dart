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
    addFromAssets('Installing a Texture Pack', 'install_texture_packs.md');
    addFromAssets('Creating a Texture Pack', 'create_texture_packs.md');
    addFromAssets('How to make a Translation', 'translation.md');
    addFromAssets('Mechanical Cells', 'mechanical_cells.md');
    addFromAssets('Math Cells', 'math_cells.md');
    addFromAssets('Master Cells', 'master_cells.md');
  }
}

final markdownManager = MarkdownManager();
