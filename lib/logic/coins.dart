part of logic;

class CoinManager {
  static int get amount => storage.getInt('coins')!;

  static Future setAmount(int amount) => storage.setInt('coins', amount);

  static Future<bool> cost(int amount) async {
    if (CoinManager.amount >= amount) {
      await setAmount(CoinManager.amount - amount);
      return true;
    } else {
      return false;
    }
  }

  static Future buy(int price, void Function(bool successful) callback) async {
    var enough = await cost(price);
    callback(enough);
  }

  static Future give(int amount) async {
    await setAmount(CoinManager.amount + amount);
  }
}
