import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

import 'package:the_puzzle_cell/logic/logic.dart';

class AchievementsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final completed = achievementData.keys
        .where((id) => AchievementManager.hasAchievement(id))
        .toList();
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              lang("achievements", "Achievements"),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: ListView.builder(
        itemCount: completed.length,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        itemBuilder: (ctx, i) {
          final id = completed[i];
          final data = achievementData[id]!;
          return Container(
            height: 9.h,
            color: Colors.grey[100],
            margin: EdgeInsets.symmetric(vertical: 1.h),
            child: ListTile(
              title: Text(
                data.title,
                style: TextStyle(
                  fontSize: 7.sp,
                ),
              ),
              subtitle: Text(
                data.description,
                style: TextStyle(
                  fontSize: 4.sp,
                ),
              ),
              trailing: data.prize == 0
                  ? null
                  : Text(
                      data.prize < 0 ? data.prize.toString() : "+${data.prize}",
                      style: TextStyle(
                        fontSize: 5.sp,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
