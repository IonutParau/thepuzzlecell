part of layout;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _delayController = TextEditingController();
  final TextEditingController _clientIDController = TextEditingController();

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
    final textStyle = TextStyle(
      fontSize: 9.sp,
    );

    final textBoxStyle = TextStyle(
      fontSize: 7.sp,
    );
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
            Row(
              children: [
                Text(
                  '${lang('realistic_render', 'Realistic Rendering')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("realistic_render") ?? true,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "realistic_render",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${lang('subticking', 'Subticking')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("subtick") ?? false,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "subtick",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  lang('titles_descriptions', 'Titles & Descriptions') + ': ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("show_titles") ?? true,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "show_titles",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
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
                  '${lang('debug_mode', 'Debug Mode')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("debug") ?? false,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "debug",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${lang('interpolation', 'Interpolation')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("interpolation") ?? true,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "interpolation",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${lang('cellbar', 'Cell Bar')}: ',
                  style: textStyle,
                ),
                SizedBox(
                  width: 3.w,
                  height: 5.h,
                  child: Align(
                    child: ToggleSwitch(
                      checked: storage.getBool("cellbar") ?? false,
                      onChanged: (newValue) {
                        storage
                            .setBool(
                              "cellbar",
                              newValue,
                            )
                            .then((e) => setState(() {}));
                      },
                    ),
                  ),
                ),
              ],
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
            if (storage.getBool('debug') == true)
              Row(
                children: [
                  Text(
                    '${lang('alt_render', 'Alternative Rendering')}: ',
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 3.w,
                    height: 5.h,
                    child: Align(
                      child: ToggleSwitch(
                        checked: storage.getBool("alt_render") ?? false,
                        onChanged: (newValue) {
                          storage
                              .setBool(
                                "alt_render",
                                newValue,
                              )
                              .then((e) => setState(() {}));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            // Row(
            //   children: [
            //     Text(
            //       lang('render_chunk', 'Render Chunk Size') + ': ',
            //       style: textStyle,
            //     ),
            //     SizedBox(
            //       width: 20.w,
            //       height: 5.h,
            //       child: Slider(
            //         value: (storage.getInt("render_size") ?? 25).toDouble(),
            //         min: 1,
            //         max: 100,
            //         onChanged: (v) => storage
            //             .setInt(
            //               "render_size",
            //               v.floor(),
            //             )
            //             .then((v) => setState(() {})),
            //         label:
            //             '${(storage.getInt('render_size') ?? 25)} cell units',
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Settings"),
    //   ),
    //   body: ScaleAssist(
    //     builder: (context, constraints) {
    //       final tooltipBox = BoxDecoration(
    //         color: Colors.grey[800],
    //       );
    //       final tooltipText = TextStyle(
    //         color: Colors.white,
    //         fontSize: 3.sp,
    //       );
    //       return Center(
    //         child: Container(
    //           width: 60.w,
    //           height: 60.h,
    //           color: Colors.grey[900],
    //           child: ListView(
    //             children: [
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message: "The time in seconds inbetween grid updates",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Update Delay: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10.w,
    //                     child: TextField(
    //                       controller: _delayController,
    //                       onChanged: (str) {
    //                         if (num.tryParse(str) != null) {
    //                           storage
    //                               .setDouble(
    //                                 "delay",
    //                                 max(num.tryParse(str)!.toDouble(), 0.01),
    //                               )
    //                               .then(
    //                                 (e) => setState(
    //                                   () {},
    //                                 ),
    //                               );
    //                         }
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message:
    //                         "Toggling it will make only the cells visible on screen to update",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Only update visible: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   Checkbox(
    //                     value: storage.getBool("update_visible") ?? false,
    //                     onChanged: (newValue) {
    //                       storage
    //                           .setBool(
    //                             "update_visible",
    //                             newValue ?? false,
    //                           )
    //                           .then((e) => setState(() {}));
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message:
    //                         "Toggling it will make the game apply special effects to make the rendering seem more realistic, at the cost of FPS",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Realistic Rendering: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   Checkbox(
    //                     value: storage.getBool("realistic_render") ?? true,
    //                     onChanged: (newValue) {
    //                       storage
    //                           .setBool(
    //                             "realistic_render",
    //                             newValue ?? false,
    //                           )
    //                           .then((e) => setState(() {}));
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message:
    //                         "Toggling it will make cells update on their own ticks, which can improve performance and battery life",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Subticking: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   Checkbox(
    //                     value: storage.getBool("subtick") ?? false,
    //                     onChanged: (newValue) {
    //                       storage
    //                           .setBool(
    //                             "subtick",
    //                             newValue ?? false,
    //                           )
    //                           .then((e) => setState(() {}));
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message:
    //                         "Toggling it will show titles and descriptions to the buttons in the UI of the game",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Show titles: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   Checkbox(
    //                     value: storage.getBool("show_titles") ?? true,
    //                     onChanged: (newValue) {
    //                       storage
    //                           .setBool(
    //                             "show_titles",
    //                             newValue ?? true,
    //                           )
    //                           .then((e) => setState(() {}));
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message: "The scale of the UI buttons",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "UI scale: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 30.w,
    //                     child: Slider(
    //                       value: storage.getDouble("ui_scale")!,
    //                       min: 0.1,
    //                       max: 5,
    //                       onChanged: (v) {
    //                         storage
    //                             .setDouble("ui_scale", floor(v * 50) / 50)
    //                             .then((b) => setState(() {}));
    //                       },
    //                     ),
    //                   ),
    //                   Text(
    //                     "${storage.getDouble("ui_scale")! * 100}%",
    //                     style: fontSize(
    //                       7.sp,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message: "The volume of the background music",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Music Volume: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 30.w,
    //                     child: Slider(
    //                       value: storage.getDouble("music_volume")!,
    //                       min: 0,
    //                       max: 1,
    //                       onChanged: (v) {
    //                         storage
    //                             .setDouble("music_volume", floor(v * 10) / 10)
    //                             .then(
    //                               (b) => setState(
    //                                 () {
    //                                   setLoopSoundVolume(
    //                                     floatMusic,
    //                                     storage.getDouble('music_volume')!,
    //                                   );
    //                                 },
    //                               ),
    //                             );
    //                       },
    //                     ),
    //                   ),
    //                   Text(
    //                     "${storage.getDouble("music_volume")! * 100}%",
    //                     style: fontSize(
    //                       7.sp,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 children: [
    //                   Tooltip(
    //                     message:
    //                         "Enabling it will shift categories around and move the sandbox UI to make it closer to Mystic Mod",
    //                     decoration: tooltipBox,
    //                     textStyle: tooltipText,
    //                     child: Text(
    //                       "Alternative UI: ",
    //                       style: fontSize(
    //                         7.sp,
    //                       ),
    //                     ),
    //                   ),
    //                   Checkbox(
    //                     value: storage.getBool("mystic") ?? false,
    //                     onChanged: (newValue) {
    //                       storage
    //                           .setBool(
    //                             "mystic",
    //                             newValue ?? false,
    //                           )
    //                           .then((e) => setState(() {}));
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
