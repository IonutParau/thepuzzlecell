part of logic;

class QueueManager {
  static Map<String, List<void Function()>> _queue = {};

  static void add(String key, void Function() callback) {
    if (!_queue.containsKey(key)) {
      _queue[key] = [];
    }
    _queue[key]!.add(callback);
  }

  static void create(String key) {
    if (!_queue.containsKey(key)) {
      _queue[key] = [];
    }
  }

  static void delete(String key) {
    if (_queue.containsKey(key)) {
      _queue.remove(key);
    }
  }

  static void runQueue(String key, [int? limit]) {
    if (_queue.containsKey(key)) {
      var i = 0;
      while (_queue[key]!.isNotEmpty) {
        _queue[key]!.removeAt(0)();
        i++;
        if (limit != null && i >= limit) return;
      }
    }
  }
}
