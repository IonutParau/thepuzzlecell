import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors;
import '../../logic/logic.dart'
    show getVersion, higherVersion, lang, versionToCheck;
import '../../utils/ScaleAssist.dart';

class UpdateUI extends StatefulWidget {
  const UpdateUI({Key? key}) : super(key: key);

  @override
  State<UpdateUI> createState() => _UpdateUIState();
}

class _UpdateUIState extends State<UpdateUI> {
  Future<String>? _versionFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(
              lang('update', 'Update'),
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Builder(
          builder: (ctx) {
            final updateBtn = MaterialButton(
              child: Padding(
                padding: EdgeInsets.all(1.w),
                child: Text(
                  lang(
                    'update_check',
                    'Check For Updates',
                  ),
                  style: TextStyle(
                    fontSize: 6.sp,
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _versionFuture = getVersion();
                });
              },
              color: Colors.blue,
            );

            if (_versionFuture != null) {
              return FutureBuilder<String>(
                future: _versionFuture,
                builder: (ctx, snap) {
                  if (snap.hasData) {
                    final higherV = higherVersion(snap.data!, versionToCheck);

                    if (higherV) {
                      return MaterialButton(
                        child: Text(
                          lang(
                            'version_out_of_date',
                            'Your current version is out of date',
                          ),
                          style: TextStyle(
                            fontSize: 5.sp,
                          ),
                        ),
                        onPressed: () {
                          print("Pretend you went to itch.io");
                        },
                        color: Colors.red,
                      );
                    } else {
                      return MaterialButton(
                        child: Text(
                          lang(
                            'version_ok',
                            'You are up to date',
                          ),
                          style: TextStyle(
                            fontSize: 5.sp,
                          ),
                        ),
                        onPressed: () {},
                        color: Colors.green,
                      );
                    }
                  }

                  if (snap.hasError) {
                    return Column(
                      children: [
                        Spacer(),
                        Text(
                          lang(
                            'versionError',
                            'Version Check Error: ${snap.error.toString()}',
                            {
                              "error": snap.error.toString(),
                            },
                          ),
                        ),
                        updateBtn,
                        Spacer(),
                      ],
                    );
                  }

                  return CircularProgressIndicator.adaptive();
                },
              );
            }

            return updateBtn;
          },
        ),
      ),
    );
  }
}
