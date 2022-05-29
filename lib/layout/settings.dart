part of layout;

String encodeColor(Color color) {
  return "${color.red}:${color.green}:${color.blue}:${color.alpha}";
}

Color decodeColor(String string) {
  final parts = string.split(":");
  return Color.fromARGB(int.parse(parts[3]), int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _delayController = TextEditingController();
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
            child: Text(lang('choose_color', 'Choose a color'), style: textBoxStyle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(lang('choose_color', 'Choose a color')),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: decodeColor(storage.getString(id) ?? encodeColor(defaultValue)),
                        onColorChanged: (color) {
                          setState(() {
                            storage.setString(id, encodeColor(color));
                          });
                        },
                      ),
                    ),
                    actions: [
                      Button(
                        child: Text('Restore to Default'),
                        onPressed: () {
                          setState(() {
                            storage.setString(id, encodeColor(defaultValue));
                          });
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
    _clientIDController.text = storage.getString("clientID") ?? "@uuid";
  }

  @override
  void dispose() {
    _delayController.dispose();
    _clientIDController.dispose();

    super.dispose();
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
              lang("settings", "Settings"),
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: Container(
        padding: EdgeInsets.all(2.w),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  '${lang('update_delay', 'Update Delay')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 20.w,
                  height: 5.h,
                  child: TextBox(
                    style: textBoxStyle,
                    controller: _delayController,
                    onChanged: (str) {
                      if (num.tryParse(str) != null) {
                        storage
                            .setDouble(
                              "delay",
                              max(min(num.tryParse(str)!.toDouble(), 1), 0.01),
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
              'realistic_render',
              'realistic_render',
              'Realistic Rendering',
              true,
            ),
            checkboxSetting(
              'subtick',
              'subticking',
              'Subticking',
              false,
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
                    onChanged: (v) => storage
                        .setDouble(
                          "music_volume",
                          (v * 100 ~/ 1) / 100,
                        )
                        .then(
                          (v) => setState(
                            () => setLoopSoundVolume(
                              flightMusic,
                              storage.getDouble("music_volume")!,
                            ),
                          ),
                        ),
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
            checkboxSetting(
              'debug',
              'debug_mode',
              'Debug Mode',
              false,
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
            checkboxSetting(
              'invert_zoom_scroll',
              'invert_zoom_scroll',
              'Invert Zoom Scrolling',
              true,
            ),
            checkboxSetting(
              'fullscreen',
              'fullscreen',
              'Fullscreen Window',
              false,
              (v) {
                windowManager.setFullScreen(v);
              },
            ),
            SizedBox(
              width: 60.w,
              child: Row(
                children: [
                  DropDownButton(
                    leading: Icon(FluentIcons.speakers),
                    title: Text(
                      lang(
                        'audioDevice',
                        'Audio Device: ${getAudioDevice().name} (changing device may require restart)',
                        {
                          'device': getAudioDevice().name,
                        },
                      ),
                    ),
                    placement: FlyoutPlacement.start,
                    items: [
                      for (var device in Devices.all)
                        // ignore: deprecated_member_use
                        DropDownButtonItem(
                          title: Text(device.name),
                          leading: Icon(FluentIcons.speakers),
                          onTap: () => setState(() => setSoundDevice(device)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTile {
  String settingID;
  String langKey;
  String title;
  int width;
  int height;

  SettingTile({
    required this.settingID,
    required this.langKey,
    required this.title,
    required this.width,
    required this.height,
  });

  Widget renderField(void Function() rerender) {
    return Text("Raw setting tile");
  }

  Widget renderRaw(void Function() rerender) {
    return Row(
      children: [
        Text(
          lang(langKey, title),
          style: TextStyle(
            fontSize: 9.sp,
          ),
        ),
        SizedBox(
          width: width.w,
          height: height.h,
          child: renderField(rerender),
        ),
      ],
    );
  }

  void dispose() {}
}
