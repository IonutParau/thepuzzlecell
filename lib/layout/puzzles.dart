part of layout;

final puzzles = [
  "easy/level1.json",
  "easy/level2.json",
  "easy/level3.json",
  "easy/level4.json",
  "easy/level5.json",
  "medium/level1.json",
  "medium/level2.json",
  "medium/level3.json",
  "medium/level4.json",
  "medium/level5.json",
  "medium/level6.json",
  "hard/level1.json",
  "hard/level2.json",
  "hard/level3.json",
];

int? puzzleIndex;

Future<String> loadJsonData(String path) async {
  var jsonText = await rootBundle.loadString(path);
  return jsonText;
}

class Puzzles extends StatefulWidget {
  const Puzzles({Key? key}) : super(key: key);

  @override
  _PuzzlesState createState() => _PuzzlesState();
}

Future<void> loadPuzzle(int index) async {
  final data =
      jsonDecode(await loadJsonData('assets/puzzles/${puzzles[index]}'));
  grid = loadGrid(data);
  puzzleIndex = index;
}

class _PuzzlesState extends State<Puzzles> {
  Icon tierToIcon(String tier, [double? size]) {
    if (tier == "hard") {
      return Icon(
        Icons.cancel_outlined,
        color: Colors.red,
        size: size,
      );
    }
    if (tier == "medium") {
      return Icon(
        Icons.hourglass_bottom,
        color: Colors.orange[400],
        size: size,
      );
    }
    return Icon(
      Icons.help_outline,
      color: Colors.blue,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Puzzles", style: fontSize(10.sp)),
      ),
      body: ListView.builder(
        itemCount: puzzles.length,
        itemBuilder: (ctx, i) {
          return FutureBuilder<String>(
            future: loadJsonData('assets/puzzles/${puzzles[i]}'),
            builder: (ctx, snap) {
              if (snap.hasData) {
                final data = jsonDecode(snap.data!);
                return ListTile(
                  title: Text(data['title']!),
                  subtitle: Text(data['description'] ?? 'No description'),
                  leading: tierToIcon(puzzles[i].split('/').first),
                  onTap: () {
                    loadPuzzle(i).then(
                      (_) => Navigator.of(context).pushNamed('/game-loaded'),
                    );
                  },
                );
              } else {
                return SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator.adaptive(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
