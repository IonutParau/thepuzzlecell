part of layout;

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final TextEditingController _delayController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _delayController.text = (storage.getDouble("delay") ?? 0.15).toString();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 9.sp,
    );
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              lang("shop", "In-Game Shop"),
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
            Text(
              "Puzzle Points: ${CoinManager.amount}",
              style: textStyle,
            ),
            SkinTile(
              skin: 'hands',
              title: 'Hands-On!',
              price: 253,
              purchaseCallback: rerender,
            ),
            SkinTile(
              skin: 'christmas',
              title: 'Christmas',
              price: 1025,
              purchaseCallback: rerender,
            ),
            SkinTile(
              skin: 'computer',
              title: 'Computer Skin!',
              price: 2650,
              purchaseCallback: rerender,
            ),
          ],
        ),
      ),
    );
  }

  void rerender() => setState(() {});
}

class SkinTile extends StatefulWidget {
  final String skin;
  final String title;
  final int price;
  final void Function() purchaseCallback;

  const SkinTile({
    Key? key,
    required this.skin,
    required this.title,
    required this.price,
    required this.purchaseCallback,
  }) : super(key: key);

  @override
  State<SkinTile> createState() => _SkinTileState();
}

class _SkinTileState extends State<SkinTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.w),
      child: SizedBox(
        width: 50.w,
        height: 5.w,
        child: ListTile(
          title: Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 5.sp,
                ),
              ),
              Spacer(),
              MaterialButton(
                child: Text(
                  SkinManager.hasSkin(widget.skin)
                      ? (SkinManager.skinEnabled(widget.skin)
                          ? lang("disequip", "Disequip")
                          : lang("equip", "Equip"))
                      : lang("unlock", "Unlock"),
                  style: TextStyle(
                    fontSize: 5.sp,
                    color: Colors.white,
                  ),
                ),
                color: Colors.green,
                onPressed: () {
                  if (SkinManager.hasSkin(widget.skin)) {
                    if (SkinManager.skinEnabled(widget.skin)) {
                      SkinManager.disableSkin(widget.skin);
                    } else {
                      SkinManager.enableSkin(widget.skin);
                    }
                    setState(() {});
                  } else {
                    CoinManager.buy(
                      widget.price,
                      (s) {
                        if (s) {
                          widget.purchaseCallback();
                          SkinManager.addSkin(widget.skin);
                        } else {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return ContentDialog(
                                title: Text('Not enough coins'),
                                content: Text(
                                  'You do not have enough coins to unlock this skin. Solving puzzles will give you puzzle points',
                                ),
                                actions: [
                                  Button(
                                    child: Text('Ok'),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
          subtitle: Text(
            lang('price', 'Price: ${widget.price} Puzzle Points',
                {"price": "${widget.price} Puzzle Points"}),
            style: TextStyle(
              fontSize: 4.sp,
            ),
          ),
          tileColor: Colors.grey[130],
        ),
      ),
    );
  }
}
