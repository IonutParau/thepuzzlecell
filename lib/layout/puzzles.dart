part of layout;

final puzzles = [
  "easy/level1.txt",
  "easy/level2.txt",
  "easy/level3.txt",
  "easy/level4.txt",
  "easy/level5.txt",
  "medium/level1.txt",
  "medium/level2.txt",
  "medium/level3.txt",
  "medium/level4.txt",
  "medium/level5.txt",
  "medium/level6.txt",
  "hard/level1.txt",
  "hard/level2.txt",
  "hard/level3.txt",
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
  final data = await loadJsonData('assets/puzzles/${puzzles[index]}');
  grid = loadStr(data);
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
                final isP1 = snap.data!.startsWith('P1;');
                final title =
                    isP1 ? snap.data!.split(';')[5] : snap.data!.split(';')[1];
                final desc =
                    isP1 ? snap.data!.split(';')[6] : snap.data!.split(';')[2];
                return ListTile(
                  title: Text(title),
                  subtitle: Text(desc),
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
