part of layout;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _delayController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _delayController.text = (storage.getDouble("delay") ?? 0.15).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ScaleAssist(
        builder: (context, constraints) {
          final tooltipBox = BoxDecoration(
            color: Colors.grey[900],
          );
          final tooltipText = TextStyle(
            color: Colors.white,
            fontSize: 3.sp,
          );
          return Center(
            child: Container(
              width: 60.w,
              height: 60.h,
              color: Colors.grey[900],
              child: Column(
                children: [
                  Spacer(),
                  Row(
                    children: [
                      Tooltip(
                        message: "The time in seconds inbetween grid updates",
                        decoration: tooltipBox,
                        textStyle: tooltipText,
                        child: Text(
                          "Update Delay: ",
                          style: fontSize(
                            7.sp,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                        child: TextField(
                          controller: _delayController,
                          onChanged: (str) {
                            if (num.tryParse(str) != null) {
                              storage
                                  .setDouble(
                                    "delay",
                                    max(num.tryParse(str)!.toDouble(), 0.01),
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
                      Tooltip(
                        message:
                            "Toggling it will make only the cells visible on screen to update",
                        decoration: tooltipBox,
                        textStyle: tooltipText,
                        child: Text(
                          "Only update visible: ",
                          style: fontSize(
                            7.sp,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: storage.getBool("update_visible") ?? false,
                        onChanged: (newValue) {
                          storage
                              .setBool(
                                "update_visible",
                                newValue ?? false,
                              )
                              .then((e) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Tooltip(
                        message:
                            "Toggling it will make the game apply special effects to make the rendering seem more realistic, at the cost of FPS",
                        decoration: tooltipBox,
                        textStyle: tooltipText,
                        child: Text(
                          "Realistic Rendering: ",
                          style: fontSize(
                            7.sp,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: storage.getBool("realistic_render") ?? true,
                        onChanged: (newValue) {
                          storage
                              .setBool(
                                "realistic_render",
                                newValue ?? false,
                              )
                              .then((e) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Tooltip(
                        message:
                            "Toggling it will make cells update on their own ticks, which can improve performance and battery life",
                        decoration: tooltipBox,
                        textStyle: tooltipText,
                        child: Text(
                          "Subticking: ",
                          style: fontSize(
                            7.sp,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: storage.getBool("subtick") ?? false,
                        onChanged: (newValue) {
                          storage
                              .setBool(
                                "subtick",
                                newValue ?? false,
                              )
                              .then((e) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
