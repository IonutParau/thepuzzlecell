part of layout;

var puzzles = <String>[];

int? puzzleIndex;

Future loadAllPuzzles() async {
  puzzles = (await loadJsonData('assets/puzzles.txt')).split('\n');
}

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
  final data = puzzles[index];
  game = PuzzleGame();
  grid = loadStr(data);
  puzzleIndex = index;
}

class _PuzzlesState extends State<Puzzles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(lang("puzzles", "Puzzles"), style: fontSize(12.sp)),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: puzzles.length,
        itemBuilder: (ctx, i) {
          final data = puzzles[i];
          if (data != "") {
            final isP1 = data.startsWith('P1;');
            final title = isP1 ? data.split(';')[5] : data.split(';')[1];
            final desc = isP1 ? data.split(';')[6] : data.split(';')[2];
            return Padding(
              padding: EdgeInsets.all(0.1.w),
              child: GestureDetector(
                onTap: () {
                  loadPuzzle(i).then(
                    (_) => Navigator.of(context).pushNamed('/game-loaded'),
                  );
                },
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(desc),
                  leading: Image.asset(
                    'assets/images/logo.png',
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.fill,
                    width: 2.w,
                    height: 2.w,
                  ),
                  tileColor: Colors.grey[130],
                ),
              ),
            );
          } else {
            return Text("");
          }
        },
      ),
    );
  }
}
