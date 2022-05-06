part of layout;

class LangsUI extends StatelessWidget {
  const LangsUI({Key? key}) : super(key: key);

  Widget langsList() {
    if (langs.isEmpty) {
      return Text(
        'You have no installed translations',
        style: TextStyle(
          fontSize: 15.sp,
        ),
      );
    }

    return SizedBox(
      width: 80.w,
      height: 60.h,
      child: ListView(
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
      ),
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
        child: langsList(),
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Padding(
              padding: EdgeInsets.all(0.3.w),
              child: Text(
                'Download Languages',
                style: TextStyle(
                  fontSize: 8.sp,
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => LangsDownloader(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LangsDownloader extends StatefulWidget {
  const LangsDownloader({Key? key}) : super(key: key);

  @override
  State<LangsDownloader> createState() => _LangsDownloaderState();
}

class _LangsDownloaderState extends State<LangsDownloader> {
  Widget versionTile(String name) {
    final f = File(path.join(langDir.path, '$name.json'));

    final locallyExists = f.existsSync();
    return ListTile(
      title: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 6.sp,
            ),
          ),
          Spacer(),
          MaterialButton(
            child: Text(
              locallyExists
                  ? lang('update', 'Update')
                  : lang('install', 'Install'),
              style: TextStyle(
                fontSize: 5.sp,
                color: Colors.white,
              ),
            ),
            color: locallyExists ? Colors.blue : Colors.green,
            onPressed: () {
              final f = downloadLanguage(name);

              f.then((v) {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return ContentDialog(
                      title: Text(
                        locallyExists
                            ? lang("local_update", "Locally updated $name",
                                {"name": name})
                            : lang("local_install", "Locally installed $name", {
                                "name": name,
                              }),
                      ),
                      content: Text(locallyExists
                          ? lang(
                              "local_update_content",
                              "The translation has updated to the newest available version",
                            )
                          : lang(
                              "local_install_content",
                              "You can click Update to update it, in case of any changes made",
                            )),
                      actions: [
                        Button(
                          child: Text('Ok'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                setState(() {});
                langEvents.sink.add(true);
              }).catchError((v) {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return ContentDialog(
                      title: Text(
                        lang(
                          "local_install_error",
                          "Error Installing $name",
                          {"name": name},
                        ),
                      ),
                      content: Text(
                        lang(
                          "local_install_error_content",
                          "Error: $v",
                          {"error": v.toString()},
                        ),
                      ),
                      actions: [
                        Button(
                          child: Text('Ok'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                setState(() {});
                langEvents.sink.add(true);
              });
            },
          ),
          if (locallyExists)
            MaterialButton(
              child: Text(
                lang("delete", "Delete"),
                style: TextStyle(
                  fontSize: 5.sp,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                f.deleteSync();
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return ContentDialog(
                      title: Text(
                        lang(
                          'locally_removed',
                          'Locally removed $name',
                          {"name": name},
                        ),
                      ),
                      content: Text(
                        lang(
                          'locally_removed_content',
                          'You can install it back whenever you want',
                        ),
                      ),
                      actions: [
                        Button(
                          child: Text("Ok"),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    );
                  },
                );
                currentLang = {};
                setState(() {});
                langEvents.sink.add(true);
              },
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget versionContent() {
    return FutureBuilder(
      future: downloadableLanguages(),
      builder: (ctx, snap) {
        if (snap.hasData) {
          return ListView(
            children: (snap.data as List<String>)
                .map((str) => versionTile(str))
                .toList(),
            itemExtent: 8.h,
          );
        } else if (snap.hasError) {
          return Text(
            snap.error.toString(),
            style: TextStyle(
              fontSize: 9.sp,
            ),
          );
        }

        return CircularProgressIndicator.adaptive();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(
              lang(
                'lang_download',
                'Language Downloader',
              ),
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: Center(
        child: Container(
          width: 90.w,
          height: 80.h,
          margin: EdgeInsets.symmetric(
            horizontal: 2.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[140],
            boxShadow: [
              BoxShadow(
                color: Colors.grey[150].withOpacity(0.3),
                spreadRadius: 1.w,
                blurRadius: 1.w,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: versionContent(),
          ),
        ),
      ),
    );
  }
}
