part of layout;

String encodeColor(Color color) {
  return "${color.red}:${color.green}:${color.blue}:${color.alpha}";
}

Color decodeColor(String string) {
  final parts = string.split(":");
  return Color.fromARGB(int.parse(parts[3]), int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

Color settingsColor(String id, Color defaultColor) {
  final color = storage.getString(id);
  if (color == null) {
    return defaultColor;
  }
  return decodeColor(color);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final TextEditingController _delayController = TextEditingController();
  final TextEditingController _updateQueueRunsController = TextEditingController();
  final TextEditingController _clientIDController = TextEditingController();
  final textStyle = TextStyle(
    fontSize: 9.sp,
  );

  final textBoxStyle = TextStyle(
    fontSize: 7.sp,
  );

  Widget colorSetting(String id, String langKey, String title, Color defaultValue) {
    return Row(
      children: [
        Text(
          '${lang(langKey, title)}: ',
          style: textStyle,
        ),
        SizedBox(
          child: Button(
            child: Container(
              width: 2.5.w,
              height: 2.5.w,
              color: decodeColor(storage.getString(id) ?? encodeColor(defaultValue)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(lang('choose_color', 'Choose a Color')),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: decodeColor(storage.getString(id) ?? encodeColor(defaultValue)),
                        onColorChanged: (color) {
                          storage.setString(id, encodeColor(color)).then((v) => setState(() {}));
                        },
                      ),
                    ),
                    actions: [
                      Button(
                        child: Text(lang('restore_default', 'Restore to Default')),
                        onPressed: () {
                          storage.setString(id, encodeColor(defaultValue)).then((v) => setState(() {}));
                          Navigator.of(context).pop();
                        },
                      ),
                      Button(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget checkboxSetting(String id, String langKey, String title, bool defaultValue, [void Function(bool v)? callback]) {
    return Row(
      children: [
        Text(
          '${lang(langKey, title)}: ',
          style: textStyle,
        ),
        SizedBox(
          width: 3.w,
          height: 5.h,
          child: Align(
            child: ToggleSwitch(
              checked: storage.getBool(id) ?? defaultValue,
              onChanged: (newValue) {
                storage
                    .setBool(
                      id,
                      newValue,
                    )
                    .then((e) => setState(() => callback?.call(newValue)));
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _delayController.text = (storage.getDouble("delay") ?? 0.15).toString();
    _updateQueueRunsController.text = storage.getInt("update_queue_runs").toString();
    _clientIDController.text = storage.getString("clientID") ?? "@uuid";
    _tabController = TabController(vsync: this, length: 1);
  }

  @override
  void dispose() {
    _delayController.dispose();
    _clientIDController.dispose();
    _tabController.dispose();

    super.dispose();
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              lang("settings", "Settings"),
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: TabBar(
            indicatorColor: Colors.grey[100],
            isScrollable: true,
            tabs: [
              Tab(
                text: lang('general', 'General'),
              ),
              Tab(
                text: lang('audio', 'Audio'),
              ),
              Tab(
                text: lang('theme', 'Theme'),
              ),
              Tab(
                text: lang('graphics', 'Graphics'),
              ),
              Tab(
                text: lang('multiplayer', 'Multiplayer'),
              ),
              Tab(
                text: lang('performance', 'Performance'),
              ),
            ],
          ),
          body: Container(
            padding: EdgeInsets.all(2.w),
            child: TabBarView(
              children: [
                ListView(
                  children: [
                    checkboxSetting(
                      'middle_move',
                      'middle_move',
                      'Middle Click Moving',
                      false,
                    ),
                    if (isDesktop)
                      checkboxSetting(
                        'fullscreen',
                        'fullscreen',
                        'Fullscreen Window',
                        false,
                        (v) {
                          windowManager.setFullScreen(v);
                        },
                      ),
                    checkboxSetting(
                      'invert_zoom_scroll',
                      'invert_zoom_scroll',
                      'Invert Zoom Scrolling',
                      true,
                    ),
                    checkboxSetting(
                      'debug',
                      'debug_mode',
                      'Debug Mode',
                      false,
                    ),
                    checkboxSetting(
                      'translator_mode',
                      'translator_mode',
                      'Translator Mode',
                      false,
                    ),
                    checkboxSetting(
                      'save_on_exit',
                      'save_on_exit',
                      "Save Grid In History Upon Exit",
                      false,
                    ),
                    SizedBox(
                      width: 60.w,
                      child: Row(
                        children: [
                          Text(
                            lang('current_saving_format', 'Current Saving Format') + ': ',
                            style: textStyle,
                          ),
                          SizedBox(
                            height: 5.h,
                            child: DropDownButton(
                              leading: Icon(FluentIcons.save),
                              title: Text(currentSavingFormat.name),
                              placement: FlyoutPlacement.start,
                              items: [
                                for (var format in CurrentSavingFormat.values)
                                  MenuFlyoutItem(
                                    text: Text(format.name),
                                    leading: Icon(FluentIcons.save),
                                    onPressed: () async {
                                      await setCurrentSavingFormat(format);
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    Row(
                      children: [
                        Text(
                          lang('music_volume', 'Music Volume') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("music_volume")!,
                            min: 0,
                            max: 1,
                            onChanged: (v) async {
                              await storage.setDouble("music_volume", (v * 100 ~/ 1) / 100);
                              await setLoopSoundVolume(music, storage.getDouble("music_volume")!);
                              setState(() {});
                            },
                            label: '${storage.getDouble('music_volume')! * 100}%',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('sfx_volume', 'SFX Volume') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("sfx_volume") ?? 1,
                            min: 0,
                            max: 1,
                            onChanged: (v) => storage
                                .setDouble(
                                  "sfx_volume",
                                  (v * 100 ~/ 1) / 100,
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${(storage.getDouble('sfx_volume') ?? 1) * 100}%',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 60.w,
                      child: Row(
                        children: [
                          Text(
                            lang('music_type', 'Music') + ': ',
                            style: textStyle,
                          ),
                          SizedBox(
                            height: 5.h,
                            child: DropDownButton(
                              leading: Icon(FluentIcons.music_note),
                              title: Text(getCurrentMusicData().name),
                              placement: FlyoutPlacement.start,
                              items: [
                                for (var music in musics)
                                  MenuFlyoutItem(
                                    text: Text(music.name),
                                    leading: Icon(FluentIcons.music_note),
                                    onPressed: () async {
                                      await changeMusic(music.id);
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    Row(
                      children: [
                        Text(
                          lang('grid_opacity', 'Grid Opacity') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("grid_opacity")!,
                            min: 0,
                            max: 1,
                            onChanged: (v) => storage
                                .setDouble(
                                  "grid_opacity",
                                  v,
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getDouble("grid_opacity")! * 100 ~/ 1}%',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('ui_button_opacity', 'UI Button Opacity') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("ui_button_opacity")!,
                            min: 0,
                            max: 1,
                            onChanged: (v) => storage
                                .setDouble(
                                  "ui_button_opacity",
                                  v,
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getDouble("ui_button_opacity")! * 100 ~/ 1}%',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('cell_button_opacity', 'Cell Button Opacity') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("cell_button_opacity")!,
                            min: 0,
                            max: 1,
                            onChanged: (v) => storage
                                .setDouble(
                                  "cell_button_opacity",
                                  v,
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getDouble("cell_button_opacity")! * 100 ~/ 1}%',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('editor_menu_button_opacity', 'Editor Menu Button Opacity') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("editor_menu_button_opacity")!,
                            min: 0,
                            max: 1,
                            onChanged: (v) => storage
                                .setDouble(
                                  "editor_menu_button_opacity",
                                  v,
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getDouble("editor_menu_button_opacity")! * 100 ~/ 1}%',
                          ),
                        ),
                      ],
                    ),
                    colorSetting('game_bg', 'game_bg', 'Game Background', Color.fromARGB(255, 27, 27, 27)),
                    colorSetting('cellbar_background', 'cellbar_background', 'Cell Bar Background', Colors.grey[180]),
                    colorSetting('cellbar_border', 'cellbar_border', 'Cell Bar Border', Colors.grey[60]),
                    colorSetting('infobox_background', 'infobox_background', 'Info Box Background', Colors.grey[180]),
                    colorSetting('infobox_border', 'infobox_border', 'Info Box Border', Colors.white),
                    colorSetting('infobox_title', 'infobox_title', 'Info Box Title', Colors.white),
                    colorSetting('infobox_desc', 'infobox_desc', 'Info Box Description', Colors.white),
                    colorSetting('editor_menu_bg', 'editor_menu_bg', 'Editor Menu Background', Colors.grey.withOpacity(0.7)),
                    colorSetting('editor_menu_slider_active', 'editor_menu_slider_active', 'Editor Menu Slider Active Color', Colors.blue),
                    colorSetting('editor_menu_slider_inactive', 'editor_menu_slider_inactive', 'Editor Menu Slider Inactive Color', Colors.black),
                  ],
                ),
                ListView(
                  children: [
                    checkboxSetting(
                      'realistic_render',
                      'realistic_render',
                      'Realistic Rendering',
                      true,
                    ),
                    if ((storage.getBool('realistic_render') ?? true) == true)
                      Row(
                        children: [
                          Text(
                            lang('lerp_speed', 'Lerp Speed') + ': ',
                            style: textStyle,
                          ),
                          SizedBox(
                            width: 20.w,
                            height: 5.h,
                            child: Slider(
                              value: storage.getDouble("lerp_speed") ?? 10.0,
                              min: 0.1,
                              max: 50,
                              divisions: 500,
                              onChanged: (v) => storage
                                  .setDouble(
                                    "lerp_speed",
                                    (v * 10 ~/ 1) / 10,
                                  )
                                  .then((v) => setState(() {})),
                              label: '${storage.getDouble('lerp_speed') ?? 10.0}x',
                            ),
                          ),
                        ],
                      ),
                    checkboxSetting(
                      'show_titles',
                      'titles_descriptions',
                      'Titles & Descriptions',
                      true,
                    ),
                    Row(
                      children: [
                        Text(
                          lang('ui_scale', 'UI Scale') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getDouble("ui_scale")!,
                            min: 0.1,
                            max: 5,
                            onChanged: (v) => storage
                                .setDouble(
                                  "ui_scale",
                                  (v * 100 ~/ 1) / 100,
                                )
                                .then((v) => setState(() {})),
                            label: '${storage.getDouble('ui_scale')! * 100}%',
                          ),
                        ),
                      ],
                    ),
                    checkboxSetting(
                      'interpolation',
                      'interpolation',
                      'Interpolation',
                      true,
                    ),
                    checkboxSetting(
                      'cellbar',
                      'cellbar',
                      'Cell Bar',
                      false,
                    ),
                  ],
                ),
                ListView(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${lang('constant_clientID', 'Client ID')}: ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: TextBox(
                            style: textBoxStyle,
                            controller: _clientIDController,
                            onChanged: (str) {
                              storage
                                  .setString(
                                    "clientID",
                                    str.replaceAll(' ', ''),
                                  )
                                  .then(
                                    (e) => setState(
                                      () {},
                                    ),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                    checkboxSetting('local_packet_mirror', 'preprocess_packets', 'Preprocess Sent Packets', false),
                    SizedBox(
                      width: 60.w,
                      child: Row(
                        children: [
                          Text(
                            lang('cursor_texture', 'Cursor Texture: '),
                            style: textStyle,
                          ),
                          SizedBox(
                            height: 5.h,
                            child: DropDownButton(
                              leading: Image.asset(
                                "assets/images/" +
                                    ((storage.getString("cursor_texture") ?? "cursor") == "cursor"
                                        ? "interface/cursor.png"
                                        : (textureMap["${storage.getString("cursor_texture")!}.png"] ?? "${storage.getString("cursor_texture")!}.png")),
                                fit: BoxFit.fill,
                                colorBlendMode: BlendMode.clear,
                                filterQuality: FilterQuality.none,
                                isAntiAlias: true,
                                width: 3.h,
                                height: 3.h,
                              ),
                              title: Text((storage.getString("cursor_texture") ?? "cursor") == "cursor" ? "Default" : (idToString(storage.getString("cursor_texture")!))),
                              placement: FlyoutPlacement.start,
                              items: [
                                for (var texture in cursorTextures)
                                  MenuFlyoutItem(
                                    text: Text(texture == "cursor" ? "Default" : idToString(texture)),
                                    leading: Image.asset(
                                      "assets/images/" + (texture == "cursor" ? "interface/cursor.png" : (textureMap["$texture.png"] ?? "$texture.png")),
                                      fit: BoxFit.fill,
                                      colorBlendMode: BlendMode.clear,
                                      filterQuality: FilterQuality.none,
                                      isAntiAlias: true,
                                      width: 3.h,
                                      height: 3.h,
                                    ),
                                    onPressed: () async {
                                      await storage.setString("cursor_texture", texture);
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          lang('cursor_precision', 'Cursor Precision') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getInt("cursor_precision")!.toDouble(),
                            min: 1,
                            max: 9,
                            divisions: 9,
                            onChanged: (v) => storage
                                .setInt(
                                  "cursor_precision",
                                  (v + 0.5).toInt(),
                                )
                                .then((v) => setState(() {})),
                            label: '${storage.getInt('cursor_precision')}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('packet_queue_limit', 'Packet Queue Limit (KB/s)') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 50.w,
                          height: 5.h,
                          child: Slider(
                            value: storage.getInt("packet_queue_limit")!.toDouble(),
                            min: 1000,
                            max: 5000000,
                            divisions: 5000,
                            onChanged: (v) => storage
                                .setInt(
                                  "packet_queue_limit",
                                  (v + 0.5).toInt(),
                                )
                                .then((v) => setState(() {})),
                            label: '${storage.getInt('packet_queue_limit')! ~/ 1000} KB/s',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ListView(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${lang('update_delay', 'Update Delay')}: ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          child: TextBox(
                            style: textBoxStyle,
                            controller: _delayController,
                            onChanged: (str) {
                              if (num.tryParse(str) != null) {
                                storage
                                    .setDouble(
                                      "delay",
                                      max(min(num.tryParse(str)!.toDouble(), 5), 0.001),
                                    )
                                    .then(
                                      (e) => setState(
                                        () {},
                                      ),
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    checkboxSetting(
                      'subtick',
                      'subticking',
                      'Subticking',
                      false,
                    ),
                    checkboxSetting(
                      'background_rect',
                      'background_rect',
                      'Replace Background Image with Rectangle',
                      false,
                    ),
                    Row(
                      children: [
                        Text(
                          lang('min_node_size', 'Minimum Node Size') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: (QuadChunk.minSize).toDouble(),
                            min: 1,
                            max: 100,
                            onChanged: (v) => storage
                                .setInt(
                                  "min_node_size",
                                  v.toInt(),
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${QuadChunk.minSize}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('chunk_size', 'Chunk Size') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: (storage.getInt("chunk_size") ?? 25).toDouble(),
                            min: 1,
                            max: 100,
                            onChanged: (v) => storage
                                .setInt(
                                  "chunk_size",
                                  v.toInt(),
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getInt("chunk_size") ?? 25}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          lang('benchmark_length', 'Benchmark Length (Ticks)') + ': ',
                          style: textStyle,
                        ),
                        SizedBox(
                          width: 20.w,
                          height: 5.h,
                          child: Slider(
                            value: (storage.getInt("benchmark_length") ?? 100).toDouble(),
                            min: 10,
                            max: 1000,
                            onChanged: (v) => storage
                                .setInt(
                                  "benchmark_length",
                                  v.toInt(),
                                )
                                .then(
                                  (v) => setState(() {}),
                                ),
                            label: '${storage.getInt("benchmark_length") ?? 100}',
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        child: Button(
                          child: Text(lang("benchmark", "Benchmark"), style: textStyle),
                          onPressed: () {
                            final f = benchmarkOnThread(BenchmarkSettings(storage.getInt("benchmark_length") ?? 100, storage));
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return LoadingDialog(future: f, completionMessage: "%value", title: lang("benchmark", "Benchmark"));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Text(
              lang(
                'clear_storage',
                'Clear Storage',
              ),
              style: fontSize(7.sp),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return ContentDialog(
                    title: Text(lang('warning_storage_del', 'Warning: This will delete all save files!')),
                    content: Text(lang('warning_del_msg',
                        'This will erase your save files. This means your settings will reset, your worlds will be deleted, the server list will be erased. This will also apply to all installations since they share the save files')),
                    actions: [
                      Button(
                        child: Text(lang('erase', 'Erase')),
                        onPressed: () {
                          storage.clear().then((v) {
                            fixStorage().then((v) => setState(() {}));
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                      Button(
                        child: Text(lang('cancel', 'Cancel')),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
