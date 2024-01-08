import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/scripts/scripts.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';

class SearchFilter {
  String name;
  String content;

  SearchFilter(this.name, this.content);
}

class SearchQueryResult {
  String cell;
  String categoryPath;

  SearchQueryResult(this.cell, this.categoryPath);

  bool get isVanilla => !isModded;
  bool get isModded => modded.contains(cell);

  bool fromModID(String modID) {
    return scriptingManager.modOrigin(cell).toLowerCase() == modID.toLowerCase();
  }

  bool fromModName(String name) {
    return scriptingManager.modName(scriptingManager.modOrigin(cell)).toLowerCase() == name.toLowerCase();
  }
}

class SearchCellDialog extends StatefulWidget {
  final String? currentSelection;
  final void Function(String selection)? onChanged;
  final List<String> extras;

  @override
  State<StatefulWidget> createState() => _SearchCellDialogState(currentSelection: currentSelection, extras: extras);

  const SearchCellDialog({this.currentSelection, this.onChanged, this.extras = const []}) : super();
}

final referenceCells = {
  "nuke",
  "bread",
  "cellua",
  "poly",
  "mystic_x",
  "quantum_tomato",
};

List<SearchQueryResult> handleCellQuery(String data, List<String> extras) {
  final parts = fancySplit(data, ' ');

  final results = <SearchQueryResult>[];
  final visited = <String>[];

  for (var cat in categories) {
    if (cat.title != "Tools") {
      for (var item in cat.items) {
        if (item is String) {
          if (!visited.contains(item)) {
            visited.add(item);
            results.add(SearchQueryResult(item, cat.title));
          }
        } else if (item is CellCategory) {
          for (var subitem in item.items) {
            if (!visited.contains(subitem)) {
              visited.add(subitem);
              results.add(SearchQueryResult(subitem, '${cat.title}/${item.title}'));
            }
          }
        }
      }
    }
  }

  for (var ref in referenceCells) {
    results.add(SearchQueryResult(ref, "References"));
  }

    for(var extra in extras) {
        results.add(SearchQueryResult(extra, "Extras"));
    }

  if (parts.first == "") {
    return results;
  }

  final filters = <SearchFilter>[];

  while (true) {
    if (parts.isEmpty) {
      break;
    }
    if (parts.first.startsWith('@')) {
      final str = parts.first.substring(1);

      if (str.contains('(') && str.endsWith(')')) {
        final i = str.indexOf('(');

        final name = str.substring(0, i);
        final content = str.substring(i + 1, str.length - 1);

        filters.add(SearchFilter(name, content));
      } else {
        filters.add(SearchFilter(str, ""));
      }
      parts.removeAt(0);
    } else {
      break;
    }
  }

  if (parts.isEmpty) {
    parts.add("");
  }

  var i = 0;
  var descs = <String>[];
  while (true) {
    if (i >= parts.length) {
      break;
    }
    if (parts[i].startsWith('"') && parts[i].endsWith('"')) {
      descs.add(parts.removeAt(i));
    } else {
      i++;
    }
  }

  if (parts.isEmpty) {
    parts.add("");
  }

  results.retainWhere((result) {
    final desc = idToDesc(result.cell).toLowerCase();

    for (var d in descs) {
      if (desc.contains(d.toLowerCase())) {
        return true;
      }
    }

    return descs.isEmpty;
  });

  final name = parts.join(" ");
  if (name.replaceAll(' ', '') != "") {
    results.retainWhere(
      (result) => idToString(
        result.cell,
      ).toLowerCase().contains(
            name.toLowerCase(),
          ),
    );
  }
  for (var filter in filters) {
    if (filter.name == "modded") {
      results.retainWhere((result) => result.isModded);
    }
    if (filter.name == "vanilla") {
      results.retainWhere((result) => result.isVanilla);
    }
    if (filter.name == "category" || filter.name == "cat" || filter.name == "categories" || filter.name == "cats") {
      final stuff = fancySplit(filter.content, ',').map((e) {
        var s = e;

        while (s.startsWith(' ')) {
          s = s.substring(1);
        }
        while (s.endsWith(' ')) {
          s = s.substring(0, s.length - 1);
        }

        if (s.startsWith('"') && s.endsWith('"')) {
          s = s.substring(1, s.length - 1);
        }

        return s;
      }).toList();
      results.retainWhere((result) {
        for (var thing in stuff) {
          if (result.categoryPath.contains(thing)) {
            return true;
          }
        }

        return stuff.isEmpty;
      });
    }

    if (filter.name == "mod") {
      final stuff = fancySplit(filter.content, ',').map((e) {
        var s = e;

        while (s.startsWith(' ')) {
          s = s.substring(1);
        }
        while (s.endsWith(' ')) {
          s = s.substring(0, s.length - 1);
        }

        if (s.startsWith('"') && s.endsWith('"')) {
          s = s.substring(1, s.length - 1);
        }

        return s;
      }).toList();
      results.retainWhere((result) => stuff.every((modStuff) => modStuff.startsWith('"') && modStuff.endsWith('"') ? result.fromModName(modStuff) : result.fromModID(modStuff)));
    }
  }

  return results;
}

class _SearchCellDialogState extends State<SearchCellDialog> {
  final _searchController = TextEditingController();
  var searchResults = <SearchQueryResult>[];
  var extras = <String>[];
  String? currentSelection;

  _SearchCellDialogState({this.currentSelection, this.extras = const []}) : super();

  @override
  void initState() {
    searchResults = handleCellQuery("", extras);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("search-cell-btn.title", "Search Cell")),
      content: SizedBox(
        height: 30.h,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 3.h,
                  child: TextBox(
                    controller: _searchController,
                    onChanged: (value) {
                      searchResults = handleCellQuery(value, extras);
                      setState(() {});
                    },
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: constraints.maxWidth,
                  height: 25.h,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (ctx, i) {
                      final result = searchResults[i];
                      final isSelected = currentSelection == null ? (game.currentSelection == result.cell) : (currentSelection == result.cell);

                      return SizedBox(
                        width: constraints.maxWidth * 0.8,
                        child: ListTile(
                          leading: Image.asset(
                            idToTexture(result.cell),
                            width: 5.h,
                            height: 5.h,
                            filterQuality: FilterQuality.none,
                            fit: BoxFit.cover,
                          ),
                          title: Text(idToString(result.cell)),
                          subtitle: Text(idToDesc(result.cell)),
                          tileColor: isSelected ? ConstantColorButtonState(Colors.successPrimaryColor) : ConstantColorButtonState(Colors.grey[130]),
                          onPressed: () {
                            if(currentSelection == null) {
                              game.currentSelection = result.cell;
                            }
                            currentSelection = result.cell;
                            widget.onChanged?.call(result.cell);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        Button(
          child: Text("Ok"),
          onPressed: () {
            Navigator.pop(context, currentSelection);
          },
        ),
      ],
    );
  }
}
