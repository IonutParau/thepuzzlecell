import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:the_puzzle_cell/logic/logic.dart';

import "package:flutter_markdown/flutter_markdown.dart";

class HelpUI extends StatefulWidget {
  @override
  State<HelpUI> createState() => _HelpUIState();
}

class _HelpUIState extends State<HelpUI> {
  MarkdownData? currentPage;

  Widget get helpBody {
    if (currentPage != null) {
      return Markdown(
        data: currentPage!.content,
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
        styleSheet: MarkdownStyleSheet(
          blockSpacing: 3.2.h,
          textScaleFactor: 2.3,
        ),
      );
    }

    return ListView.builder(
      itemCount: markdownManager.docs.length,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      itemBuilder: (ctx, i) {
        final doc = markdownManager.docs[i];
        return Container(
          height: 7.h,
          color: Colors.grey[100],
          margin: EdgeInsets.symmetric(vertical: 1.h),
          child: ListTile(
            title: Text(
              doc.title,
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
            onPressed: () => setState(() => currentPage = doc),
          ),
        );
      },
    );
  }

  Widget get backBtn {
    return Row(
      children: [
        Spacer(),
        Button(
          child: Text(
            lang('back', 'Back'),
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
          onPressed: () => setState(() => currentPage = null),
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
              lang("help", "Help"),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: helpBody,
      bottomBar: currentPage != null ? backBtn : null,
    );
  }
}
