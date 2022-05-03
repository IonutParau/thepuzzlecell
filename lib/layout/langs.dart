part of layout;

class LangsUI extends StatelessWidget {
  const LangsUI({Key? key}) : super(key: key);

  Widget langsList() {
    if (langs.isEmpty) {
      return Text(
        'You have no\ninstalled translations',
        style: TextStyle(
          fontSize: 15.sp,
        ),
      );
    }

    return ListView(
      children: [
        Align(
          child: SizedBox(
            width: 30.w,
            child: Button(
              child: Text(
                'English',
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              onPressed: resetLang,
            ),
          ),
        ),
        for (var f in langs)
          Align(
            child: SizedBox(
              width: 30.w,
              child: Button(
                child: Text(
                  jsonDecode(f.readAsStringSync())['title'] ?? 'Untitled',
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                ),
                onPressed: () => loadLang(f),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              "Languages",
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: Center(
        child: SizedBox(
          width: 50.w,
          height: 60.h,
          child: langsList(),
        ),
      ),
    );
  }
}
